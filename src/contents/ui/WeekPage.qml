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

    property alias startDate: weekView.startDate
    property bool wideScreen

    title: weekView.selectedDate.toLocaleDateString(_appLocale, Locale.ShortFormat)

    actions {
        left: Kirigami.Action {
            iconName: "arrow-left"
            text: i18n("Previous week")
            displayHint: Kirigami.Action.IconOnly
            onTriggered: weekView.previousWeek()
        }

        main: Kirigami.Action {
            iconName: "view-calendar-day"
            text: i18n("Current Week")

            onTriggered: weekView.goCurrentWeek()
        }

        right: Kirigami.Action {
            iconName: "arrow-right"
            text: i18n("Next week")
            displayHint: Kirigami.Action.IconOnly
            onTriggered: weekView.nextWeek()
        }

    }

    WeekView {
        id: weekView

        cal: Calindori.CalendarController.activeCalendar
        wideScreen: root.wideScreen

        onSelectedWeekDateChanged: {
            if (pageStack.depth > 1) {
                pageStack.pop(null);
            }
        }
    }
}
