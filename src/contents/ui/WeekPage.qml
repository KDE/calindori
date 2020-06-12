/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import org.kde.kirigami 2.0 as Kirigami

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
