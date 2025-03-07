/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.12 as Kirigami
import org.kde.calindori 0.1 as Calindori

ListView {
    id: root

    property int fstDayOfWeek: _appLocale.firstDayOfWeek
    property date startDate
    property date selectedWeekDate: firstDateOfWeek(startDate)
    property date selectedDate: startDate
    property var cal
    property bool wideScreen

    signal nextWeek
    signal previousWeek
    signal goCurrentWeek
    signal addEvent
    signal addTodo

    /**
    * @brief Get the date of the first day of a week, given a date in the week
    *
    */

    function firstDateOfWeek(inputDate)
    {
        var t = inputDate;
        t.setDate(inputDate.getDate() - inputDate.getDay() + (inputDate.getDay() >= fstDayOfWeek ? fstDayOfWeek : fstDayOfWeek-7));
        t.setHours(inputDate.getHours())
        t.setMinutes(0);
        t.setSeconds(0);

        return t;
    }

    /**
    * @brief Remove the editor page from the stack. If an incidence page exists in the page stack, remove it as well
    *
    */
    function removeEditorPage() {
        pageStack.pop(0);
    }

    function moveDate(startDt, offset)
    {
        var movedDt = startDt;
        movedDt.setDate(startDt.getDate() + offset);

        return movedDt;
    }

    onNextWeek: {
        selectedWeekDate = moveDate(selectedWeekDate, 7);
        selectedDate = selectedWeekDate;
        currentIndex = 0;
    }

    onPreviousWeek: {
        selectedWeekDate = moveDate(selectedWeekDate, -7);
        selectedDate = selectedWeekDate;
        currentIndex = 0;
    }

    onGoCurrentWeek: {
        selectedWeekDate = firstDateOfWeek(startDate);
        selectedDate = startDate;
        currentIndex = selectedDate.getDay() >= fstDayOfWeek ? selectedDate.getDay() - fstDayOfWeek : 7 - (selectedDate.getDay() +  fstDayOfWeek)
    }

    onCurrentIndexChanged: {
        if (pageStack.depth > 1) {
            pageStack.pop(null);
        }
    }

    model: 7
    currentIndex: selectedDate.getDay() >= fstDayOfWeek ? selectedDate.getDay() - fstDayOfWeek : 7 - (selectedDate.getDay() +  fstDayOfWeek)

    delegate: Kirigami.SwipeListItem {
        id: dayListItem

        property var weekDay: model.index
        property var itemDate: {
                    var dt = root.selectedWeekDate;
                    dt.setDate(dt.getDate() + index);
                    dt.setHours(dt.getHours() + 1);
                    dt.setMinutes(0);
                    dt.setSeconds(0);
                    dt.setMilliseconds(0);

                    return dt;
        }

        alwaysVisibleActions: false

        contentItem: RowLayout {
            spacing: Kirigami.Units.largeSpacing * 2

            ColumnLayout  {
                Layout.minimumWidth: Kirigami.Units.gridUnit * 2

                Controls2.Label {
                    text: _appLocale.dayName(model.index + fstDayOfWeek, Locale.ShortFormat)
                    Layout.alignment: Qt.AlignHCenter
                }

                Controls2.Label {
                    font: Kirigami.Theme.smallFont
                    text: itemDate.toLocaleDateString(_appLocale, "d MMM")
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            ColumnLayout {

                Repeater {
                    model: Calindori.IncidenceModel {
                        appLocale: _appLocale
                        filterDt: moveDate(root.selectedWeekDate, dayListItem.weekDay)
                        filterMode: 4
                    }

                    IncidenceItemDelegate {
                        itemBackgroundColor: model.type === 0 ? Kirigami.Theme.backgroundColor : Qt.darker(Kirigami.Theme.backgroundColor, 1.1)
                        text: model.summary
                        subtitle: (model.type == 0 ? model.displayStartEndTime : (model.displayDueTime || model.displayStartTime))
                        Layout.fillWidth: true

                        onClicked: {
                            if(pageStack.lastItem && pageStack.lastItem.hasOwnProperty("isIncidencePage")) {
                                pageStack.pop();
                            }

                            pageStack.push(incidencePage, { incidence: model })
                        }
                    }
                }
            }
        }

        actions: [
            Kirigami.Action {
                icon.name: "resource-calendar-insert"
                text: i18n("Create Event")

                onTriggered: pageStack.push(eventEditor, { startDt: itemDate })
            },

            Kirigami.Action {
                icon.name: "task-new"
                text: i18n("Create Task")

                onTriggered: pageStack.push(todoEditor, { startDt: itemDate })}
        ]

        onClicked: { root.selectedDate = moveDate(root.selectedWeekDate, model.index) }

    }

    Component {
        id: incidencePage

        IncidencePage {
            calendar: root.cal
        }
    }

    Component {
        id: eventEditor

        EventEditorPage {
            calendar: root.cal

            onEditcompleted: removeEditorPage()
        }
    }

    Component {
        id: todoEditor

        TodoEditorPage {
            onEditcompleted: removeEditorPage()
        }
    }
}
