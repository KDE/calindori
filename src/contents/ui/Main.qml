/*
 *   Copyright 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.0 as Kirigami
import QtQuick.Controls 2.4 as Controls2
import org.kde.phone.calindori 0.1 as Calindori
import "Utils.js" as Utils

Kirigami.ApplicationWindow {
    id: root

    /**
     * To be emitted when data displayed should be refreshed
     */
    signal refreshNeeded;

    globalDrawer: Kirigami.GlobalDrawer {
        id: drawer

        isMenu: true
        title: "Calindori"
        actions: [
            Kirigami.Action {
                id: calendarActions

                text: i18n("Calendars")
                iconName: "view-calendar"

                Kirigami.Action {
                    text: i18n("Create")
                    iconName: "list-add"
                    onTriggered: root.pageStack.push(calendarEditor, {mode: "add"})
                }

                Kirigami.Action {
                    text: i18n("Import")
                    iconName: "document-import"

                    onTriggered: root.pageStack.push(calendarEditor, {mode: "import"})
                }

                Kirigami.Action {
                    separator: true
                }
            },

            Kirigami.Action {
                id: show

                text: i18n("Show")
                iconName: "view-choose"

                Kirigami.Action {
                    text: "Calendar"
                    iconName: "view-calendar-day"
                    onTriggered: {
                        pageStack.clear();
                        pageStack.push(calendarDashboardComponent);
                    }
                }

                Kirigami.Action {
                    text: i18n("Tasks (%1)", localCalendar.name)
                    iconName: "view-calendar-tasks"
                    onTriggered: {
                        pageStack.clear();
                        pageStack.push(todosView, { todoDt: localCalendar.nulldate });
                    }
                }

                Kirigami.Action {
                    text: i18n("Events (%1)", localCalendar.name)
                    iconName: "view-calendar-upcoming-events"
                    onTriggered: {
                        pageStack.clear();
                        pageStack.push(eventsView, {eventStartDt: ""});
                    }
                }
            }
        ]

        Component.onCompleted: Utils.loadGlobalActions(calindoriConfig.calendars, calendarActions, calendarAction)
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer

        title: (pageStack.currentItem && pageStack.currentItem.hasOwnProperty("selectedDate") && !isNaN(pageStack.currentItem.selectedDate)) ? pageStack.currentItem.selectedDate.toLocaleDateString(Qt.locale()) : ""
    }

    pageStack {
        initialPage: [calendarDashboardComponent]
        separatorVisible: false
    }

    Calindori.Config {
        id: calindoriConfig

        onActiveCalendarChanged: Utils.loadGlobalActions(calindoriConfig.calendars, calendarActions, calendarAction)
        onCalendarsChanged: Utils.loadGlobalActions(calindoriConfig.calendars, calendarActions, calendarAction)
    }

    Calindori.LocalCalendar {
        id: localCalendar

        name: calindoriConfig.activeCalendar

        onNameChanged: {
            root.refreshNeeded();
            if (root.pageStack.depth > 1) {
                root.pageStack.pop(null);
                root.pageStack.push(calendarDashboardComponent);
            }
        }
    }

    /**
     * Action that represents a calendar configuration entry
     * It is added dynamically to the global drawer
     */
    Component {
        id: calendarAction

        CalendarAction {
            configuration: calindoriConfig

            onDeleteCalendar: {
                deleteSheet.calendar = text;
                deleteSheet.open();
            }
        }
    }

    Component {
        id: calendarDashboardComponent


        Kirigami.Page {

            property alias selectedDate: calendarMonthView.selectedDate

            title: calendarMonthView.displayedMonthName + " " + calendarMonthView.displayedYear

            actions {
                left: Kirigami.Action {
                    iconName: "go-down"

                    onTriggered: calendarMonthView.previousMonth()
                }

                main: Kirigami.Action {
                    iconName: "view-calendar-day"

                    onTriggered: calendarMonthView.goToday()
                }

                right: Kirigami.Action {
                    iconName: "go-up"

                    onTriggered: calendarMonthView.nextMonth()
                }

                contextualActions: [
                    Kirigami.Action {
                        iconName: "view-calendar-tasks"
                        text: i18n("Tasks")

                        onTriggered: root.pageStack.push(todosView, { todoDt: calendarMonthView.selectedDate })
                    },

                    Kirigami.Action {
                        iconName: "tag-events"
                        text: i18n("Events")

                        onTriggered: root.pageStack.push(eventsView, { eventStartDt: calendarMonthView.selectedDate })
                    }
                ]
            }

            CalendarMonthView {
                id: calendarMonthView

                anchors.fill: parent
                showHeader: true
                showMonthName: false
                showYear: false

                todosCount: function (todosDate) {
                    return localCalendar.todosCount(todosDate);
                }

                eventsCount: function (eventsDate) {
                    return localCalendar.eventsCount(eventsDate);
                }

                onSelectedDateChanged: {
                    if (root.pageStack.depth > 1) {
                        root.pageStack.pop(null);
                    }
                }

                Connections {
                    target: root

                    onRefreshNeeded: calendarMonthView.refresh()
                }
            }
        }
    }

    Component {
        id: todosView

        TodosView {

            calendar: localCalendar

            onTasksUpdated: root.refreshNeeded()

            Connections {
                target: root

                onRefreshNeeded: reload()
            }
        }
    }

    Component {
        id: eventsView

        EventsView {
            calendar: localCalendar

            onEventsUpdated: root.refreshNeeded()

            Connections {
                target: root

                onRefreshNeeded: reload()
            }
        }
    }

    Component {
        id: calendarEditor

        CalendarEditor {

            configuration: calindoriConfig

            onCalendarAdded: {
                root.refreshNeeded();
                root.pageStack.pop(calendarEditor);
            }

            onCalendarAddCanceled: {
                root.pageStack.pop(calendarEditor);
            }

        }
    }

    ConfirmationSheet {
        id: deleteSheet

        configuration: calindoriConfig
    }
}

