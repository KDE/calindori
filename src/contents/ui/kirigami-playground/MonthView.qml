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

import QtQuick 2.0
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.0 as Kirigami

/*
 * Component that displays the days of a month as a 6x7 table
 * 
 * Optionally, it may display:
 * - a header on top of the table showing the current date
 * - inside each day cell, a small indicator in case that tasks 
 *   exist for this day
 */
Item {
    id: root
    
    property int days: 7
    property int weeks: 6
    property date currentDate: new Date()
    property int dayRectWidth: Kirigami.Units.gridUnit*2.5
    property date selectedDate: new Date()
    property int selectedDayTodosCount: 0
    /**
     * A model that provides:
     * 
     * 1. dayNumber
     * 2. monthNumber
     * 3. yearNumber
     */
    property var daysModel
    /**
     * Function that returns the amount of tasks of each day
     * 
     * If implemented, a small indicator will be displayed
     * into the cell of each day. Default implementation returns 0,
     * so no indicator is displayed.
     */
    property var todosCount: function (todosDate) {
        return 0;
    }
    property bool showHeader: false

    function reloadSelectedDate() {
        root.selectedDayTodosCount = root.todosCount(root.selectedDate)
    }
    
    onSelectedDateChanged: reloadSelectedDate()

    ColumnLayout {
        anchors.centerIn: parent
        
        spacing:  Kirigami.Units.gridUnit / 4
        
        /**
         * Optional header on top of the table
         * that displays the current date and 
         * the amount of the day's tasks
         */
        CalendarHeader {
            id: calendarHeader
            
            Layout.bottomMargin: Kirigami.Units.gridUnit / 2
            headerDate: root.selectedDate
            headerTodosCount: root.selectedDayTodosCount
            visible: root.showHeader
        }
        
        /**
         * Styled week day names of the days' calendar grid
         * E.g.
         * Mon Tue Wed ...
         */
        RowLayout {
            spacing: 0           
            
            Repeater {
                model: root.days
                delegate: 
                    Rectangle {
                        width: root.dayRectWidth
                        height: width
                        color: Kirigami.Theme.disabledTextColor
                        opacity: 0.8
                        
                        Controls2.Label {                
                            anchors.centerIn: parent
                            color: Kirigami.Theme.textColor
                            text: Qt.locale(Qt.locale().uiLanguages[0]).dayName(((model.index + Qt.locale().firstDayOfWeek) % root.days), Locale.ShortFormat) 
                        }            
                }
            }
        }
        
        /**
         * Grid that displays the days of a month (normally 6x7)
         */        
        Grid {        
            Layout.fillWidth: true            
            columns: root.days
            rows: root.weeks
            
            Repeater {               
                model: root.daysModel
                delegate: DayDelegate {                    
                    currentDate: root.currentDate
                    delegateWidth: root.dayRectWidth
                    selectedDate: root.selectedDate
                    todosCount: root.todosCount(new Date(model.yearNumber, model.monthNumber -1, model.dayNumber))
                    
                    onDayClicked: root.selectedDate = new Date(model.yearNumber, model.monthNumber -1, model.dayNumber)                    
                }                
            }
        }        
    }
}