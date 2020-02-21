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

Kirigami.ApplicationWindow {
    id: root

    globalDrawer: Kirigami.GlobalDrawer {
        id: drawer

        title: "Calindori"
        actions: [
            Kirigami.Action {
                id: calendarActions

                text: i18n("Calendars")
                iconName: "view-calendar"

                children: [calendarCreateAction, calendarImportAction, actionSeparator]

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

        Instantiator {
            model: _calindoriConfig.calendars.split(_calindoriConfig.calendars.includes(";") ? ";" : null)

            delegate: CalendarAction {
                text: modelData
            }

            onObjectAdded: {
                calendarActions.children.push(object)
            }

            onObjectRemoved: {
                // HACK this is not pretty because onObjectRemoved is called for each calendar, but we cannot remove a single child
                calendarActions.children = []
                calendarActions.children.push(calendarCreateAction)
                calendarActions.children.push(calendarImportAction)
                calendarActions.children.push(actionSeparator)
            }
        }
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer

        title: (pageStack.currentItem && pageStack.currentItem.hasOwnProperty("selectedDate") && !isNaN(pageStack.currentItem.selectedDate)) ? pageStack.currentItem.selectedDate.toLocaleDateString(Qt.locale()) : ""
    }

    pageStack {
        initialPage: [calendarDashboardComponent]
        separatorVisible: false
    }


    Calindori.LocalCalendar {
        id: localCalendar

        name: _calindoriConfig.activeCalendar

        onNameChanged: {
            if (root.pageStack.depth > 1) {
                root.pageStack.pop(null);
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
                    text: i18n("Previous month")

                    onTriggered: calendarMonthView.previousMonth()
                }

                main: Kirigami.Action {
                    iconName: "view-calendar-day"
                    text: i18n("Today")

                    onTriggered: calendarMonthView.goToday()
                }

                right: Kirigami.Action {
                    iconName: "go-up"
                    text: i18n("Next month")

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
                cal: localCalendar

                anchors.centerIn: parent
                showHeader: true
                showMonthName: false
                showYear: false

                onSelectedDateChanged: {
                    if (root.pageStack.depth > 1) {
                        root.pageStack.pop(null);
                    }
                }
            }
        }
    }

    Component {
        id: todosView

        TodosView {

            calendar: localCalendar
        }
    }

    Component {
        id: eventsView

        EventsView {
            calendar: localCalendar
        }
    }

    Component {
        id: calendarEditor

        CalendarEditor {
            onCalendarAdded: root.pageStack.pop(calendarEditor)
            onCalendarAddCanceled: root.pageStack.pop(calendarEditor)
        }
    }

    Kirigami.Action {
        id: calendarCreateAction

        text: i18n("Create")
        iconName: "list-add"
        onTriggered: root.pageStack.push(calendarEditor, {mode: "add"})
    }

    Kirigami.Action {
        id: calendarImportAction

        text: i18n("Import")
        iconName: "document-import"

        onTriggered: root.pageStack.push(calendarEditor, {mode: "import"})
    }

    Kirigami.Action {
        id: actionSeparator

        separator: true
    }
}

