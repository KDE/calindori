/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import org.kde.kirigami 2.6 as Kirigami
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
        defaultColumnWidth: Kirigami.Units.gridUnit * 35
    }

    Calindori.LocalCalendar {
        id: localCalendar

        name: _calindoriConfig.activeCalendar
    }

    Component {
        id: calendarMonthPage

        CalendarMonthPage {
            calendar: localCalendar
            dayRectangleWidth: Kirigami.Settings.isMobile ? Kirigami.Units.gridUnit * 2.5 : Kirigami.Units.gridUnit * 3.5
            loadWithAction: Kirigami.Settings.isMobile ? -1 : 1

            onPageEnd: switchToMonthPage(lastDate, lastActionIndex)
        }
    }

    footer: Kirigami.InlineMessage {
        id: importMessage

        property bool showActions: false

        visible: false
        showCloseButton: showActions === false
        leftPadding: (globalDrawer.drawerOpen ? globalDrawer.width : 0) + Kirigami.Units.smallSpacing

        actions: [
            Kirigami.Action {
                visible: importMessage.showActions
                icon.name: "dialog-ok"
                text: i18n("Proceed")

                onTriggered: {
                   importMessage.visible = false;
                   Calindori.CalendarController.importFromBuffer(localCalendar);
                }
            },
            Kirigami.Action {
                icon.name: "dialog-cancel"
                text: i18n("Cancel")
                visible: importMessage.showActions

                onTriggered: {
                    importMessage.visible = false;
                    Calindori.CalendarController.abortImporting(localCalendar);
                }
            }
        ]

        Connections {
            target: Calindori.CalendarController
            onStatusMessageChanged: {
                importMessage.text = statusMessage;
                importMessage.visible = true;
                importMessage.type = (messageType === 0) ? Kirigami.MessageType.Information : (messageType === 1 ? Kirigami.MessageType.Positive : Kirigami.MessageType.Warning);
                importMessage.showActions = (messageType === 0);
            }
        }
    }

    onSwitchToMonthPage: {
        popAll();
        pageStack.push(calendarMonthPage, {selectedDate: sDate, loadWithAction: Kirigami.Settings.isMobile ? -1 : cActionIndex});
    }
}
