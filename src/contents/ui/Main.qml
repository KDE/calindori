/*
 *   Copyright 2018 Dimitris Kardarakos <dimkard@gmail.com>
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
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.0 as Kirigami
import QtQuick.Controls 2.4 as Controls2
import org.kde.phone.calindori 0.1 as Calindori
import "Utils.js" as Utils
import org.kube.framework 1.0 as Kube

Kirigami.ApplicationWindow {
    id: root

    /**
     * To be emitted when data displayed should be refreshed
     */
    signal refreshNeeded;

    globalDrawer: Kirigami.GlobalDrawer {
        id: drawer

        title: "Calindori"
        actions: [
            Kirigami.Action {
                id: onlineCalendars

                text: "Online Calendars"
                onTriggered: root.pageStack.push(accountSwitcher);
            },
            Kirigami.Action {
                id: calendarActions

                text: "Calendars"
                iconName: "view-calendar"

                Kirigami.Action {
                    text: "Add calendar..."
                    iconName: "list-add"
                    onTriggered: root.pageStack.push(calendarInputPage);
                }

                Kirigami.Action {
                    separator: true
                }
            },

            Kirigami.Action {
                id: show

                text: "Show"
                iconName: "view-choose"

                Kirigami.Action {
                    text: "Calendar"
                    iconName: "view-calendar-day"
                    onTriggered: {
                        pageStack.clear();
                        pageStack.push(calendarDashboardComponent)
                    }
                }

                Kirigami.Action {
                    text: "Tasks" + " (" + localCalendar.name + ")"
                    iconName: "view-calendar-tasks"
                    onTriggered: {
                        pageStack.clear();
                        pageStack.push(todosView, { todoDt: localCalendar.nulldate });
                    }
                }
            }
        ]

        Component.onCompleted: Utils.loadGlobalActions(calindoriConfig.calendars, calendarActions, calendarAction)
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    pageStack.initialPage: [calendarDashboardComponent]
    pageStack.defaultColumnWidth: pageStack.width

    Calindori.Config {
        id: calindoriConfig

        onActiveCalendarChanged: Utils.loadGlobalActions(calindoriConfig.calendars, calendarActions, calendarAction)
        onCalendarsChanged: Utils.loadGlobalActions(calindoriConfig.calendars, calendarActions, calendarAction)
    }

    Calindori.LocalCalendar {
        id: localCalendar

        name: calindoriConfig.activeCalendar

        onNameChanged: {
            root.refreshNeeded();
            if (root.pageStack.depth > 1) {
                root.pageStack.pop(null);
            }
        }
    }

    /**
     * Action that represents a calendar configuration entry
     * It is added dynamically to the global drawer
     */
    Component {
        id: calendarAction

        CalendarAction {
            configuration: calindoriConfig

            onDeleteCalendar: {
                deleteSheet.calendar = text;
                deleteSheet.open();
            }
        }
    }

    Component {
        id: calendarDashboardComponent

        Kirigami.Page {

            title: calendarMonthView.currentMonthName + " " + calendarMonthView.currentYear

            actions {
                left: Kirigami.Action {
                    iconName: "go-previous"

                    onTriggered: calendarMonthView.previousMonth()
                }

                main: Kirigami.Action {
                    iconName: "view-calendar-day"

                    onTriggered: calendarMonthView.goToday()
                }

                right: Kirigami.Action {
                    iconName: "go-next"

                    onTriggered: calendarMonthView.nextMonth()
                }

                contextualActions: [
                    Kirigami.Action {
                        iconName: "view-calendar-tasks"
                        text: "Show tasks"

                        onTriggered: {
                            if(localCalendar.todosCount(calendarMonthView.selectedDate) > 0) {
                                root.pageStack.push(todosView, { todoDt: calendarMonthView.selectedDate });
                            }
                            else {
                                showPassiveNotification (i18n("There is no task for the day selected"));
                            }
                        }
                    },
                    Kirigami.Action {
                        iconName: "resource-calendar-insert"
                        text: "Add task"

                        onTriggered: root.pageStack.push(todoPage, { startdt: calendarMonthView.selectedDate} )
                    }
                ]
            }

            CalendarMonthView {
                id: calendarMonthView

                anchors.centerIn: parent

                todosCount: function (todosDate) {
                    return localCalendar.todosCount(todosDate);
                }

                onSelectedDateChanged: {
                    if (root.pageStack.depth > 1) {
                        root.pageStack.pop(null);
                    }
                }

                Connections {
                    target: root

                    onRefreshNeeded: calendarMonthView.refresh()
                }
            }
        }
    }

    Component {
        id: todosView

        TodosView {

            calendar: localCalendar

            onEditTask: root.pageStack.push(todoPage, {  startdt: modelData.dtstart, uid: modelData.uid, todoData: modelData })
            onTasksUpdated: root.refreshNeeded()

            Connections {
                target: root

                onRefreshNeeded: reload()
            }
        }
    }

    Component {
        id: todoPage

        TodoPage {
            calendar: localCalendar
            onTaskeditcompleted: {
                root.refreshNeeded();
                root.pageStack.pop(todoPage);
            }
        }
    }

    Component {
        id: calendarInputPage

        CalendarInputPage {

            onCalendarAdded: {
                var calendarAddResult = "";
                calendarAddResult = calindoriConfig.addCalendar(calendarName);

                if(calendarAddResult != "")
                {
                    showPassiveNotification(calendarAddResult);
                    return;
                }

                if(activeCalendar)
                {
                    calindoriConfig.activeCalendar = calendarName;
                }
                root.refreshNeeded();
                root.pageStack.pop(calendarInputPage);
            }

            onCalendarAddCanceled: {
                root.pageStack.pop(calendarInputPage);
            }

        }
    }

    Kube.CheckedEntities {
        id: calendarFilterCollector
    }

    Component {
        id: accountSwitcher

        Kirigami.Page {


        Kube.ListView {
                id: listView

                anchors.fill: parent
                Layout.fillWidth: true
                Layout.maximumHeight: Math.min(contentHeight, parent.height - Kube.Units.gridUnit)
                Layout.preferredHeight: contentHeight
                spacing: Kube.Units.smallSpacing
                model: Kube.CheckableEntityModel {
                    id: calendarModel
                    type: "calendar"
                    roles: ["name", "color", "enabled"]
                    sortRole: "name"
                    filter: {} //root.editMode ? {} : {enabled: true}
                    accountId: ""
                    checkedEntities: calendarFilterCollector
                }
                delegate: Kube.ListDelegate {
                    id: delegate
                    width: listView.availableWidth
                    height: Kube.Units.gridUnit
                    hoverEnabled: true
                    background: Item {}
                    RowLayout {
                        anchors.fill: parent
                        spacing: Kube.Units.smallSpacing
                        Kube.CheckBox {
                            id: checkBox
                            opacity: 0.9
                            visible: root.editMode
                            checked: model.checked || model.enabled
                            onCheckedChanged: {
                                model.checked = checked
                                model.enabled = checked
                            }

                            indicator: Rectangle {
                                width: Kube.Units.gridUnit * 0.8
                                height: Kube.Units.gridUnit * 0.8

                                color: model.color

                                Rectangle {
                                    id: highlight
                                    anchors.fill: parent
                                    visible: checkBox.hovered || checkBox.visualFocus
                                    color: Kube.Colors.highlightColor
                                    opacity: 0.4
                                }

                                Kube.Icon {
                                    anchors.centerIn: parent
                                    height: Kube.Units.gridUnit
                                    width: Kube.Units.gridUnit
                                    visible: checkBox.checked
                                    iconName: Kube.Icons.checkbox_inverted
                                }
                            }

                        }
                        Kube.Label {
                            id: label
                            Layout.fillWidth: true
                            text: model.name
                            color: Kube.Colors.highlightedTextColor
                            elide: Text.ElideLeft
                            clip: true
                        }
                        Rectangle {
                            visible: !root.editMode
                            width: Kube.Units.gridUnit * 0.8
                            height: Kube.Units.gridUnit * 0.8
                            radius: width / 2
                            color: model.color
                        }

                    }
                }
            }
        }
    }

    ConfirmationSheet {
        id: deleteSheet

        configuration: calindoriConfig
    }
}

