/*
 *   Copyright 2020 Dimitris Kardarakos <dimkard@posteo.net>
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
import org.kde.kirigami 2.6 as Kirigami

Kirigami.Page {
    id: root

    property alias selectedDate: calendarMonthView.selectedDate
    property var calendar

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

                onTriggered: pageStack.push(todosCardView)
            },

            Kirigami.Action {
                iconName: "tag-events"
                text: i18n("Events")

                onTriggered: pageStack.push(eventsCardView)
            }
        ]
    }

    CalendarMonthView {
        id: calendarMonthView

        anchors.fill: parent
        cal: root.calendar

        anchors.centerIn: parent
        showHeader: true
        showMonthName: false
        showYear: false

        onSelectedDateChanged: {
            if (Kirigami.Settings.isMobile && pageStack.depth > 1) {
                pageStack.pop(null);
            }
        }
    }

    Component {
        id: todosCardView

        TodosCardView {
            calendar: localCalendar
            todoDt: root.selectedDate
        }
    }

    Component {
        id: eventsCardView

        EventsCardView {
            calendar: localCalendar
            eventStartDt: root.selectedDate
        }
    }
}
