/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import org.kde.kirigami 2.0 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.ApplicationWindow {
    id: root

    signal switchToMonthPage(var sDate, var cActionIndex)

    globalDrawer: CalindoriGlobalDrawer {
        id: globalDrawer

        wideScreen: root.wideScreen
        monthView: calendarMonthPage
        calendar: localCalendar
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer

        title: (pageStack.currentItem && pageStack.currentItem.hasOwnProperty("selectedDate") && !isNaN(pageStack.currentItem.selectedDate)) ? pageStack.currentItem.selectedDate.toLocaleDateString(_appLocale) : ""
    }

    pageStack {
        initialPage: [calendarMonthPage]
        defaultColumnWidth: Kirigami.Units.gridUnit * 40
    }

    Calindori.LocalCalendar {
        id: localCalendar

        name: _calindoriConfig.activeCalendar
    }

    Component {
        id: calendarMonthPage

        CalendarMonthPage {
            calendar: localCalendar
            loadWithAction: Kirigami.Settings.isMobile ? -1 : 1

            onPageEnd: switchToMonthPage(lastDate, lastActionIndex)
        }
    }

    onSwitchToMonthPage: {
        pageStack.clear();
        pageStack.push(calendarMonthPage, {selectedDate: sDate, loadWithAction: Kirigami.Settings.isMobile ? -1 : cActionIndex});
    }
}
