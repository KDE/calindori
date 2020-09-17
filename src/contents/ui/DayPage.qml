/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import org.kde.kirigami 2.0 as Kirigami

Kirigami.ScrollablePage {
    id: root

    property bool wideScreen

    title: dayView.selectedDate.toLocaleDateString(_appLocale, Locale.LongFormat)

    actions {
        left: Kirigami.Action {
            iconName: "go-down"
            text: i18n("Previous day")

            onTriggered: dayView.previousDay()
        }

        main: Kirigami.Action {
            iconName: "view-calendar-day"
            text: i18n("Today")

            onTriggered: dayView.goToday()
        }

        right: Kirigami.Action {
            iconName: "go-up"
            text: i18n("Next day")

            onTriggered: dayView.nextDay()
        }

        contextualActions: [
            Kirigami.Action {
                icon.name: "tag-events"
                text: i18n("Add Event")
                onTriggered: dayView.addEvent()
            },

            Kirigami.Action {
                icon.name: "view-calendar-tasks"
                text: i18n("Add Task")
                onTriggered: dayView.addTodo()
            }
        ]
    }

    DayView {
        id: dayView

        cal: localCalendar
        wideScreen: root.wideScreen

        onSelectedDateChanged: {
            if (pageStack.depth > 1) {
                pageStack.pop(null);
            }
        }
    }
}
