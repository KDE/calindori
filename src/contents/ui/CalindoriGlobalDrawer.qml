/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.14
import QtQuick.Layouts 1.14
import org.kde.kirigami 2.6 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.OverlayDrawer {
    id: drawer
    
    property var monthView
    property var calendar
    property bool wideScreen: false
    property var applicationFooter
    
    modal: !wideScreen
    width: 200
    height: applicationWindow().height
    
    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.inherit: false
    
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    
    handleClosedIcon.source: modal ? null : "sidebar-expand-left"
    handleOpenIcon.source: modal ? null : "sidebar-collapse-left"
    handleVisible: applicationWindow().pageStack.depth <= 1 && applicationWindow().pageStack.layers.depth <= 1
    
    property var checkedSidebarItem: monthViewButton
    
    contentItem: ColumnLayout {
        spacing: 0
        
        // sidebar header
        ToolBar {
            visible: !drawer.modal
            Layout.fillWidth: true
            implicitHeight: applicationWindow().pageStack.globalToolBar.preferredHeight

            Item {
                anchors.fill: parent
                Kirigami.Heading {
                    level: 1
                    text: i18n("Calendar")
                    anchors.left: parent.left
                    anchors.leftMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
        
        Kirigami.Heading {
            visible: drawer.modal
            text: i18n("Calendar")
            type: Kirigami.Heading.Secondary
            Layout.margins: Kirigami.Units.gridUnit
        }
        
        // sidebar content
        ColumnLayout {
            id: column
            spacing: 0
            Layout.margins: Kirigami.Units.smallSpacing
            
            SidebarButton {
                id: monthViewButton
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 2
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                
                text: i18n("Month View")
                icon.name: "view-calendar-month"
                checked: pageActive
                property bool pageActive: checkedSidebarItem === monthViewButton
                
                onClicked: {
                    popExtraLayers();
                    pageStack.clear();
                    pageStack.push(monthView);
                    
                    checkedSidebarItem = monthViewButton;
                    checked = Qt.binding(() => pageActive);
                    
                    if (drawer.modal) drawer.close();
                }
            }
            
            SidebarButton {
                id: weekViewButton
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 2
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                
                text: i18n("Week View")
                icon.name: "view-calendar-week"
                checked: pageActive
                property bool pageActive: checkedSidebarItem === weekViewButton
                
                onClicked: {
                    popExtraLayers();
                    pageStack.clear();
                    pageStack.push(weekView, { startDate: Calindori.CalendarController.localSystemDateTime() } );
                    
                    checkedSidebarItem = weekViewButton;
                    checked = Qt.binding(() => pageActive);
                    
                    if (drawer.modal) drawer.close();
                }
            }
            
            SidebarButton {
                id: dayViewButton
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 2
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                
                text: i18n("Day View")
                icon.name: "view-calendar-day"
                checked: pageActive
                property bool pageActive: checkedSidebarItem === dayViewButton
                
                onClicked: {
                    popExtraLayers();
                    pageStack.clear();
                    pageStack.push(dayView);
                    
                    checkedSidebarItem = dayViewButton;
                    checked = Qt.binding(() => pageActive);
                    
                    if (drawer.modal) drawer.close();
                }
            }
            
            SidebarButton {
                id: tasksListButton
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 2
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                
                text: i18n("Tasks List")
                icon.name: "view-calendar-list"
                checked: pageActive
                property bool pageActive: checkedSidebarItem === tasksListButton
                
                onClicked: {
                    popExtraLayers();
                    pageStack.clear();
                    pageStack.push(incidenceView, { incidenceType: 1, filterMode: 9 });
                    
                    checkedSidebarItem = tasksListButton;
                    checked = Qt.binding(() => pageActive);
                    
                    if (drawer.modal) drawer.close();
                }
            }
            
            SidebarButton {
                id: eventsListButton
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 2
                
                text: i18n("Events List")
                icon.name: "view-calendar-agenda"
                checked: pageActive
                property bool pageActive: checkedSidebarItem === eventsListButton
                
                onClicked: {
                    popExtraLayers();
                    pageStack.clear();
                    pageStack.push(incidenceView, { incidenceType: 0, filterMode: 8 });
                    
                    checkedSidebarItem = eventsListButton;
                    checked = Qt.binding(() => pageActive);
                    
                    if (drawer.modal) drawer.close();
                }
            }
            
            Kirigami.Separator { 
                Layout.fillWidth: true 
                Layout.margins: Kirigami.Units.smallSpacing
            }
            
            Kirigami.Heading {
                Layout.fillWidth: true
                Layout.margins: Kirigami.Units.smallSpacing
                Layout.leftMargin: Kirigami.Units.largeSpacing
                text: i18n("Calendars")
                level: 3
                type: Kirigami.Heading.Secondary
            }
            
            // calendar selection
            Repeater {
                model: Calindori.CalindoriConfig && Calindori.CalindoriConfig.internalCalendars
                delegate: calendarButton
            }
            Repeater {
                model: Calindori.CalindoriConfig && Calindori.CalindoriConfig.externalCalendars
                delegate: calendarButton
            }
            
            Component {
                id: calendarButton
                SidebarButton {
                    Layout.fillWidth: true
                    Layout.minimumHeight: Kirigami.Units.gridUnit * 2
                    property string calendarName: modelData
                    property bool calendarActive: Calindori.CalindoriConfig !== null ? (Calindori.CalindoriConfig.activeCalendar === calendarName) : false
                    
                    text: calendarName
                    icon.name: calendarActive ? "checkmark" : "view-calendar"
                    checked: false
                    
                    onClicked: {
                        if (!checked) {
                            Calindori.CalindoriConfig.activeCalendar = calendarName;
                            popExtraLayers();
                            showPassiveNotification(i18n("Calendar %1 has been activated", calendarName));
                            checked = false;
                        }
                    }
                }
            }
            
            Item { Layout.fillHeight: true }
            Kirigami.Separator { 
                Layout.fillWidth: true 
                Layout.margins: Kirigami.Units.smallSpacing
            }
            
            SidebarButton {
                id: settingsButton
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 2
                
                text: i18n("Settings")
                icon.name: "settings-configure"
                checked: pageActive
                property bool pageActive: checkedSidebarItem === settingsButton
                
                onClicked: {
                    popExtraLayers();
                    pageStack.clear();
                    pageStack.push(settingsPage);
                    
                    checkedSidebarItem = settingsButton;
                    checked = Qt.binding(() => pageActive);
                    
                    if (drawer.modal) drawer.close();
                }
            }
        }
    }
    
    Component {
        id: dayView
        DayPage {
            wideScreen: root.wideScreen
        }
    }

    Component {
        id: weekView
        WeekPage {
            wideScreen: root.wideScreen
        }
    }

    Component {
        id: incidenceView
        IncidenceListView {
            calendar: root.calendar
        }
    }

    Component {
        id: settingsPage
        SettingsPage {
            applicationFooter: drawer.applicationFooter
        }
    }
}
