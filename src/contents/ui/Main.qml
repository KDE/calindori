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
import org.kde.phone.mobilecalendar 0.1 as MobileCalendar

Kirigami.ApplicationWindow {
    id: root
       
    globalDrawer: Kirigami.GlobalDrawer {
        id: drawer
        
        title: "Mobile Calendar"       
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
    
    Component {
        id: calendarDashboardComponent
                
        Kirigami.Page {
                    
            title: monthGrid.currentMonthName + " " + monthGrid.currentYear

            actions {                
                left: Kirigami.Action {
                    iconName: "go-previous"
                    
                    onTriggered: monthGrid.previousMonth()
                }
                
                main: Kirigami.Action {
                    iconName: "view-calendar-day"
                    
                    onTriggered: monthGrid.goToday()
                }
                
                right: Kirigami.Action {
                    iconName: "go-next"
                    
                    onTriggered: monthGrid.nextMonth()
                }
                
                contextualActions: [
                        Kirigami.Action {
                            iconName: "view-calendar-tasks"
                            text: "Show tasks"
                    
                            onTriggered: root.pageStack.push(todosView, { todoDt: monthGrid.selectedDate } )                            
                        },
                        Kirigami.Action {
                            iconName: "resource-calendar-insert"
                            text: "Add task"
                            
                            onTriggered: root.pageStack.push(todoPage, { todosmodel: todosView.todosmodel, startdt: monthGrid.selectedDate} )                            
                        }
                    ]
            }
            
            MonthGrid {
                id: monthGrid

                anchors.centerIn: parent

                todosCount: function (todosDate) {
                     var todos = localCalendar.todosCount(todosDate);
                     //console.log(todosDate.toString() + " has " + todos + " todos");

                    return localCalendar.todosCount(todosDate);
                }
                
                Connections {
                    target: root
                    
                    onRefreshNeeded: monthGrid.daysModel.update()
                }
                
            }
          
        }
    }
    
    TodosView {
        id: todosView
        
        calendar: localCalendar
        
        onEditTask: root.pageStack.push(todoPage, { todosmodel: todosView.todosmodel, startdt: modelData.dtstart, uid: modelData.uid, todoData: modelData })
        
        onTaskDeleted: root.refreshNeeded()
        
        Connections {
            target: root
            
            onRefreshNeeded: todosView.todosmodel.reloadTasks()
        }
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
    
    MobileCalendar.LocalCalendar {
        id: localCalendar

        name: "personal"
    }
    
    MobileCalendar.Config {
        id: mobileCalendarConfig;
    }    
}
