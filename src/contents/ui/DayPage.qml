/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import org.kde.kirigami 2.0 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.ScrollablePage {
    id: root

    property bool wideScreen

    title: dayView.selectedDate.toLocaleDateString(_appLocale, Locale.ShortFormat)

    actions: [
        Kirigami.Action {
            icon.name: "arrow-left"
            text: i18n("Previous day")
            displayHint: Kirigami.Action.IconOnly
            onTriggered: dayView.previousDay()
        },
        Kirigami.Action {
            icon.name: "arrow-right"
            text: i18n("Next day")
            displayHint: Kirigami.Action.IconOnly
            onTriggered: dayView.nextDay()
        },
        Kirigami.Action {
            icon.name: "view-calendar-day"
            text: i18n("Today")

            onTriggered: dayView.goToday()
        }
    ]

    DayView {
        id: dayView

        cal: Calindori.CalendarController.activeCalendar
        wideScreen: root.wideScreen

        onSelectedDateChanged: {
            if (pageStack.depth > 1) {
                pageStack.pop(null);
            }
        }
    }
}
