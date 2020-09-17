/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami
import org.kde.calindori 0.1

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
    function removeEditorPage(editor)
    {
        var incidencePageExists = pageStack.items[pageStack.depth-2] && pageStack.items[pageStack.depth - 2].hasOwnProperty("isIncidencePage");
        pageStack.pop(eventEditor);
        if(incidencePageExists)
        {
            pageStack.pop(incidencePage);
        }
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

    onAddEvent: {
        var newEventStartDt = root.selectedDate;
        newEventStartDt.setHours(newEventStartDt.getHours() + 1);
        newEventStartDt.setMinutes(0);
        newEventStartDt.setSeconds(0);

        pageStack.push(eventEditor, { startDt: newEventStartDt })
    }

    onAddTodo: pageStack.push(todoEditor, { startDt: selectedDate })

    onCurrentIndexChanged: {
        if (pageStack.depth > 1) {
            pageStack.pop(null);
        }
    }

    model: 7
    currentIndex: selectedDate.getDay() >= fstDayOfWeek ? selectedDate.getDay() - fstDayOfWeek : 7 - (selectedDate.getDay() +  fstDayOfWeek)

    delegate: Kirigami.AbstractListItem {
        id: dayListItem

        property var weekDay: model.index
        property color incidenceColor: ListView.isCurrentItem ? Qt.darker(Kirigami.Theme.highlightColor, 1.1) : Kirigami.Theme.backgroundColor

        contentItem: RowLayout {
            spacing: Kirigami.Units.largeSpacing * 3

            Controls2.Label {
                font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
                text: _appLocale.dayName(model.index + fstDayOfWeek, Locale.NarrowFormat)
                Layout.minimumWidth: Kirigami.Units.gridUnit * 3
                Layout.minimumHeight: Kirigami.Units.gridUnit * 3
            }

            GridLayout {
                columns: wideScreen ? -1 : 1
                rows: wideScreen ? 1 : -1

                Repeater {
                    model: IncidenceModel {
                        appLocale: _appLocale
                        calendar: root.cal
                        filterDt: moveDate(root.selectedWeekDate, dayListItem.weekDay)
                        filterMode: 4
                    }

                    IncidenceItemDelegate {
                        itemBackgroundColor: dayListItem.incidenceColor
                        label: "%1\n%2\n%3".arg(model.displayType).arg(model.type == 0 ? model.displayStartEndTime : (model.displayDueTime || model.displayStartTime)).arg(model.summary)

                        Layout.fillWidth: true

                        onClicked: pageStack.push(incidencePage, { incidence: model })
                    }
                }
            }
        }

        onClicked: { root.selectedDate = moveDate(root.selectedWeekDate, model.index) }
    }

    Component {
        id: incidencePage

        IncidencePage {
            calendar: root.cal

            actions.left: Kirigami.Action {
                text: i18n("Delete")
                icon.name: "delete"

                onTriggered: {
                    deleteSheet.incidenceData = { uid: incidence.uid, summary: incidence.summary, type: incidence.type };
                    deleteSheet.open();
                }
            }

            actions.main: Kirigami.Action {
                text: i18n("Close")
                icon.name: "window-close-symbolic"

                onTriggered: pageStack.pop(null)
            }

            actions.right: Kirigami.Action {
                text: i18n("Edit")
                icon.name: "document-edit-symbolic"

                onTriggered: pageStack.push(incidence.type == 0 ? eventEditor : todoEditor, { startDt: incidence.dtstart, uid: incidence.uid, incidenceData: incidence })
            }
        }
    }

    Component {
        id: eventEditor

        EventEditor {
            calendar: root.cal

            onEditcompleted: removeEditorPage(eventEditor)
        }
    }

    Component {
        id: todoEditor

        TodoEditor {
            calendar: root.cal

            onEditcompleted: removeEditorPage(todoEditor)
        }
    }

    ConfirmationSheet {
        id: deleteSheet

        property var incidenceData

        message: i18n("%1 will be deleted. Proceed?", incidenceData && incidenceData.summary);
        operation: function() {
            if(incidenceData.type == 0)
            {
                _eventController.remove(root.cal, incidenceData);
            }
            else
            {
                _todoController.remove(root.cal, incidenceData);
            }
            pageStack.pop(incidencePage);
        }
    }
}
