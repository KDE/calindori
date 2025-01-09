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

    property date selectedDate: Calindori.CalendarController.localSystemDateTime()
    property var cal
    property bool wideScreen

    signal nextDay
    signal previousDay
    signal goToday
    signal addEvent
    signal addTodo

    /**
    * @brief Remove the editor page from the stack. If an incidence page exists in the page stack, remove it as well
    *
    */
    function removeEditorPage() {
        pageStack.pop(0);
    }

    onNextDay: {
        var next = selectedDate;
        next.setDate(selectedDate.getDate() + 1)
        selectedDate = next;
    }

    onPreviousDay: {
        var prev = selectedDate;
        prev.setDate(selectedDate.getDate() - 1)
        selectedDate = prev;
    }

    onGoToday: {
        selectedDate = Calindori.CalendarController.localSystemDateTime();
        currentIndex = selectedDate.getHours();
    }

    onCurrentIndexChanged: {
        if (pageStack.depth > 1) {
            pageStack.pop(null);
        }
    }

    model: 24
    currentIndex: selectedDate.getHours()

    delegate: Kirigami.SwipeListItem {
        id: hourListItem

        property var hour: model.index

        alwaysVisibleActions: false

        contentItem: RowLayout {
            spacing: Kirigami.Units.largeSpacing * 2

            Controls2.Label {
                text: model.index < 10 ? "0" + model.index + ":00" : model.index + ":00"
                Layout.minimumWidth: Kirigami.Units.gridUnit * 2
            }

            ColumnLayout {
                Repeater {
                    model: Calindori.IncidenceModel {
                        appLocale: _appLocale
                        filterDt: root.selectedDate
                        filterHour: hourListItem.hour
                        filterMode: 1
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

                            pageStack.push(incidencePage, { incidence: model });
                        }
                    }
                }
            }
        }

        actions: [
            Kirigami.Action {
                icon.name: "resource-calendar-insert"
                text: i18n("Create Event")

                onTriggered: {
                    var eventDt = selectedDate;
                    eventDt.setHours(index);
                    eventDt.setMinutes(0);
                    eventDt.setSeconds(0);

                    pageStack.push(eventEditor, { startDt: eventDt });
                }
            },
            Kirigami.Action {
                icon.name: "task-new"
                text: i18n("Create Task")

                onTriggered: {
                    var todoDt = selectedDate;
                    todoDt.setHours(index);
                    todoDt.setMinutes(0);
                    todoDt.setSeconds(0);

                    pageStack.push(todoEditor, { startDt: todoDt });
                }
            }
        ]
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
