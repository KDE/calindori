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

Item {
    id: root
    
    property int days: 7
    property int weeks: 6
    property date currentDate: new Date()
    property int dayRectWidth: Kirigami.Units.gridUnit*2.5
    property var currentMonthName
    property var currentYear
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
        
        CalendarHeader {
            id: calendarHeader
            
            Layout.bottomMargin: Kirigami.Units.gridUnit / 2
            headerDate: root.selectedDate
            headerTodosCount: root.selectedDayTodosCount
            visible: root.showHeader
        }
        
        /**
         * Header of the days' calendar grid
         * E.g.
         * Mon Tue Wed ...
         */
        RowLayout {
            spacing: 0           
            
            Repeater {
                model: root.days
                delegate: weekDayDelegate
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
                id: dayRepeater
                
                model: root.daysModel
                delegate: DayDelegate {
                    id: dayDelegate    
                    
                    currentDate: root.currentDate
                    delegateWidth: root.dayRectWidth
                    selectedDate: root.selectedDate
                    todosCount: root.todosCount(new Date(model.yearNumber, model.monthNumber -1, model.dayNumber))
                    
                    onDayClicked: root.selectedDate = new Date(model.yearNumber, model.monthNumber -1, model.dayNumber)                    
                }                
            }
        }        
    }
    
    /**
     * Week Day Delegate
     * 
     * Controls the display of the elements of the header
     */    
    Component {
        id: weekDayDelegate 
        
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
