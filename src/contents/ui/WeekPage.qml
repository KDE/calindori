/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import org.kde.kirigami 2.0 as Kirigami

Kirigami.ScrollablePage {
    id: root

    property alias startDate: weekView.startDate
    property bool wideScreen

    title: weekView.selectedDate.toLocaleDateString(_appLocale, Locale.LongFormat)

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

    }

    WeekView {
        id: weekView

        cal: localCalendar
        wideScreen: root.wideScreen

        onSelectedWeekDateChanged: {
            if (pageStack.depth > 1) {
                pageStack.pop(null);
            }
        }
    }
}
