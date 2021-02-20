/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami
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
    function removeEditorPage(editor)
    {
        var incidencePageExists = pageStack.items[pageStack.depth-2] && pageStack.items[pageStack.depth - 2].hasOwnProperty("isIncidencePage");
        pageStack.pop(eventEditor);
        if(incidencePageExists)
        {
            pageStack.pop(incidencePage);
        }
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
        property color incidenceColor: ListView.isCurrentItem ? Qt.darker(Kirigami.Theme.highlightColor, 1.1) : Kirigami.Theme.backgroundColor

        alwaysVisibleActions: false

        RowLayout {
            spacing: Kirigami.Units.largeSpacing * 2

            Controls2.Label {
                font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
                text: model.index < 10 ? "0" + model.index : model.index
                Layout.minimumWidth: Kirigami.Units.gridUnit * 2
                Layout.minimumHeight: Kirigami.Units.gridUnit * 3
            }

            GridLayout {
                columns: root.wideScreen ? -1 : 1
                rows: root.wideScreen ? 1 : -1

                Repeater {
                    model: Calindori.IncidenceModel {
                        appLocale: _appLocale
                        calendar: root.cal
                        filterDt: root.selectedDate
                        filterHour: hourListItem.hour
                        filterMode: 1
                    }

                    IncidenceItemDelegate {
                        itemBackgroundColor: hourListItem.incidenceColor
                        label: "%1\n%2".arg(model.displayType).arg(model.summary)
                        Layout.fillWidth: true

                        onClicked: {
                            if(pageStack.lastItem && pageStack.lastItem.hasOwnProperty("isIncidencePage")) {
                                pageStack.pop(incidencePage);
                            }

                            pageStack.push(incidencePage, { incidence: model });
                        }
                    }
                }
            }
        }

        actions: [
            Kirigami.Action {
                iconName: "resource-calendar-insert"
                text: i18n("New event")

                onTriggered: {
                    var eventDt = selectedDate;
                    eventDt.setHours(index);
                    eventDt.setMinutes(0);
                    eventDt.setSeconds(0);

                    pageStack.push(eventEditor, { startDt: eventDt });
                }
            },

            Kirigami.Action {
                iconName: "task-new"
                text: i18n("New task")

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

            onEditcompleted: removeEditorPage(eventEditor)
        }
    }

    Component {
        id: todoEditor

        TodoEditorPage {
            calendar: root.cal

            onEditcompleted: removeEditorPage(todoEditor)
        }
    }
}
