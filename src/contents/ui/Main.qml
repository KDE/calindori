/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import org.kde.kirigami 2.12 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.ApplicationWindow {
    id: root

    signal switchToMonthPage(var sDate, var cActionIndex)

    /**
     * Starting from the last page in the stack, remove every page of the stack
     */
    function popAll()
    {
        while (pageStack.depth > 0) {
            pageStack.pop();
        }
    }

    /**
     * Starting from the last layer in the stack, remove every layer keeping only the first one
     */
    function popExtraLayers()
    {
        while (pageStack.layers.depth > 1) {
            pageStack.layers.pop();
        }
    }

    globalDrawer: CalindoriGlobalDrawer {
        id: globalDrawer

        wideScreen: root.wideScreen
        monthView: calendarMonthPage
        calendar: localCalendar
        applicationFooter: messageFooter
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer

        property var contextIconName: (pageStack && pageStack.currentItem && pageStack.currentItem.hasOwnProperty('contextIconName')) ?  pageStack.currentItem.contextIconName : null
        handleOpenIcon.source: contextIconName
        handleClosedIcon.source: contextIconName

        title: (pageStack.currentItem && pageStack.currentItem.hasOwnProperty("selectedDate") && !isNaN(pageStack.currentItem.selectedDate)) ? pageStack.currentItem.selectedDate.toLocaleDateString(_appLocale, Locale.ShortFormat) : ""
    }

    pageStack {
        initialPage: [calendarMonthPage]
        defaultColumnWidth: Kirigami.Units.gridUnit * 35
    }

    Calindori.LocalCalendar {
        id: localCalendar

        name: _calindoriConfig.activeCalendar
    }

    Component {
        id: calendarMonthPage

        CalendarMonthPage {
            appContextDrawer: contextDrawer
            calendar: localCalendar
            dayRectangleWidth: Kirigami.Settings.isMobile ? Kirigami.Units.gridUnit * 2.5 : Kirigami.Units.gridUnit * 3.5
            loadWithAction: Kirigami.Settings.isMobile ? -1 : 1

            onPageEnd: switchToMonthPage(lastDate, lastActionIndex)
        }
    }

    footer: MessageBoard {
        id: messageFooter

        leftPadding: (globalDrawer.drawerOpen ? globalDrawer.width : 0) + Kirigami.Units.smallSpacing
        activeCalendar: localCalendar

        Connections {
            target: Calindori.CalendarController
            function onStatusMessageChanged (statusMessage, messageType) {
                messageFooter.text = statusMessage;
                messageFooter.footerMode = (messageType === 0) ? MessageBoard.FooterMode.StartImport : (messageType === 1 ? MessageBoard.FooterMode.EndImportSuccess : MessageBoard.FooterMode.EndImportFailure);
            }
        }
    }

    onSwitchToMonthPage: {
        popAll();
        pageStack.push(calendarMonthPage, {selectedDate: sDate, loadWithAction: (!Kirigami.Settings.isMobile && root.wideScreen) ? cActionIndex : -1});
    }

}
