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
    property alias startDate: weekView.startDate

    title: weekView.selectedDate.toLocaleDateString(Qt.locale(), Locale.LongFormat)

    actions {
        left: Kirigami.Action {
            iconName: "go-down"
            text: i18n("Previous week")

            onTriggered: weekView.previousWeek()
        }

        main: Kirigami.Action {
            iconName: "view-calendar-day"
            text: i18n("Current week")

            onTriggered: weekView.goCurrentWeek()
        }

        right: Kirigami.Action {
            iconName: "go-up"
            text: i18n("Next week")

            onTriggered: weekView.nextWeek()
        }

        contextualActions: [
            Kirigami.Action {
                icon.name: "tag-events"
                text: i18n("Add Event")
                onTriggered: weekView.addEvent()
            },

            Kirigami.Action {
                icon.name: "view-calendar-tasks"
                text: i18n("Add Task")
                onTriggered: weekView.addTodo()
            }
        ]
    }

    WeekView {
        id: weekView

        cal: localCalendar
        anchors.fill: parent

        onSelectedWeekDateChanged: {
            if (pageStack.depth > 1) {
                pageStack.pop(null);
            }
        }
    }
}
