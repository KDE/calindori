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
    property alias monthName: plasmaCalendar.displayedDateMonthName
    property alias year: plasmaCalendar.year
    property int selectedYear: currentDate.getFullYear()
    property int selectedMonth: currentDate.getMonth() + 1
    property int selectedDay: currentDate.getDate()
    property string selectedDayName: new Date().toLocaleDateString(Qt.locale(), "dddd");
    property var todosCount: function (dayNumber, monthNumber, yearNumber) {
        return 0;
    }    
    property int selectedDayTodosCount: todosCount(selectedDay, selectedMonth,selectedYear)
    property alias daysModel: plasmaCalendar.daysModel
    
    signal nextMonth
    signal previousMonth
    signal goToday
    signal populateDay(int index, var model, var item)
    
    onPopulateDay: {
        root.selectedYear = model.yearNumber;
        root.selectedMonth = model.monthNumber;
        root.selectedDay = model.dayNumber;
        root.selectedDayName = new Date(model.yearNumber, model.monthNumber -1, model.dayNumber).toLocaleDateString(Qt.locale(), "dddd");
        
        //DEBUG console.log("Selected date: " + " " +  model.yearNumber + model.monthNumber + model.dayNumber + " clicked");
    }
    
    onNextMonth: {
        plasmaCalendar.displayedDate = new Date(plasmaCalendar.displayedDate.setMonth(plasmaCalendar.displayedDate.getMonth() + 1));
    }
    
    onPreviousMonth: {
        plasmaCalendar.displayedDate = new Date(plasmaCalendar.displayedDate.setMonth(plasmaCalendar.displayedDate.getMonth() -1));
    }
    
    onGoToday: {
        plasmaCalendar.displayedDate = root.currentDate;        
    }
    
    // HACK: Added only as a temporary model provider, to be replaced with a real model provider    
    CalendarBackend {
        id: plasmaCalendar
        
        property int displayedDateMonth: Qt.formatDate(plasmaCalendar.displayedDate,"MM")
        property string displayedDateMonthName: Qt.locale(Qt.locale().uiLanguages[0]).monthName(displayedDateMonth-1) 
        
        days: root.days
        weeks: root.weeks
        today: root.currentDate
    }
    
    
    ColumnLayout {
        anchors.centerIn: parent

        spacing:  Kirigami.Units.gridUnit / 4
        
        RowLayout {
            id: selectedDayHeading
            
            spacing:  Kirigami.Units.gridUnit / 2
            
            Controls2.Label {              
                font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 4
                text: root.selectedDay
                opacity: 0.6
            }
            
            ColumnLayout {

                spacing:  Kirigami.Units.gridUnit / 6

                Controls2.Label {                   
                    text: root.selectedDayName
                    font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
                }
            
                Controls2.Label {                    
                    text: root.monthName + " " + root.selectedYear
                }
            }
        }
        
        Controls2.Label {
            text: (root.selectedDayTodosCount) ? i18np("%1 task for today", "%1 tasks for today",root.selectedDayTodosCount) : ""
            opacity: 0.6
            bottomPadding: Kirigami.Units.gridUnit / 2
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
                
                model: plasmaCalendar.daysModel
                delegate: MonthDayDelegate {
                            id: monthDayDelegate    
                            
                            currentDate: root.currentDate
                            delegateWidth: root.dayRectWidth
                            selectedYear: root.selectedYear
                            selectedMonth: root.selectedMonth
                            selectedDay: root.selectedDay
                            todosCount: root.todosCount(model.dayNumber, model.monthNumber, model.yearNumber)
                            
                            onDayClicked: root.populateDay(index, model, monthDayDelegate)
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
                text: Qt.locale(Qt.locale().uiLanguages[0]).dayName(((plasmaCalendar.firstDayOfWeek + model.index) % root.days), Locale.ShortFormat) 
            }            
        }
    }
    
}
