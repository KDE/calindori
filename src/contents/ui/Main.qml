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
import org.kde.phone.calindori 0.1 as Calindori

Kirigami.ApplicationWindow {
    id: root
    
    
    globalDrawer: Kirigami.GlobalDrawer {
        id: drawer
        
        title: "Calindori"       
        contentItem.implicitWidth: Math.min (Kirigami.Units.gridUnit * 15, root.width * 0.8)
        
        topContent: Column {            
            spacing: Kirigami.Units.gridUnit * 2
        }
    }
    
    pageStack.initialPage: [calendarDashboardComponent]
    
    /**
     * To be emitted when data displayed should be refreshed
    */
    signal refreshNeeded;
    
    onRefreshNeeded: todosView.refreshNeeded()

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
                                if(localCalendar.todosCount( calendarMonthView.selectedDate) > 0) {
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

    TodosView {
        id: todosView

        calendar: localCalendar

        onEditTask: root.pageStack.push(todoPage, {  startdt: modelData.dtstart, uid: modelData.uid, todoData: modelData })
        onTaskDeleted: root.refreshNeeded()
    }

    Component {
        id: todoPage
        
        TodoPage {
            calendar: localCalendar
                   
            onTaskeditcompleted: {
                //console.log("Closing todo page");
                root.refreshNeeded();
                root.pageStack.pop(todoPage);                                
            }            
        }
    }
    
    Calindori.LocalCalendar {
        id: localCalendar

        name: "personal"
    }
    
    Calindori.Config {
        id: mobileCalendarConfig;
    }    
}
