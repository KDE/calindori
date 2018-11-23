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

/**
* Month Day Delegate
* 
* Controls the display of each day of a months' grid
* 
*/
Rectangle {
    id: dayDelegate

    property date currentDate
    property int delegateWidth
    property int selectedYear
    property int selectedMonth
    property int selectedDay
    property bool highlight:  (model.yearNumber == selectedYear)  &&  (model.monthNumber == selectedMonth) &&  (model.dayNumber == selectedDay) 

    signal dayClicked

    width: childrenRect.width
    height: childrenRect.height
    opacity:(dayButton.isCurrentDate || highlight )  ? 0.4 : 1
    color: dayButton.isCurrentDate ? Kirigami.Theme.textColor : ( highlight ? Kirigami.Theme.selectionBackgroundColor : Kirigami.Theme.backgroundColor )                   
    border.color: Kirigami.Theme.disabledTextColor
    
//     onHighlightChanged: { 
// //         //DEBUG
//         console.log("*** highlight: " +  highlight + ", selectedDate: " + dayDelegate.selectedYear + "-" + dayDelegate.selectedMonth + "-" + dayDelegate.selectedDay  + ", delegateDate: " + model.yearNumber + "-" + model.monthNumber + "-" + model.dayNumber + " ***")        
//     }

    Controls2.ToolButton {
        id: dayButton
        
        property bool isCurrentDate: ( Qt.formatDate(dayDelegate.currentDate, "yyyy") ==  model.yearNumber ) && ( Qt.formatDate(dayDelegate.currentDate, "MM") ==  model.monthNumber ) && ( Qt.formatDate(dayDelegate.currentDate, "dd") ==  model.dayNumber )
        property bool isCurrentMonth: model.monthNumber == Qt.formatDate(plasmaCalendar.displayedDate, "MM")
        
        onClicked: dayDelegate.dayClicked()
        
        width: dayDelegate.delegateWidth
        height: width
        text: model.dayNumber
        enabled: isCurrentMonth
    }
    
}
