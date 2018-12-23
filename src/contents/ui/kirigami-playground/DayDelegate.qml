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
 * Expects a model that provides:
 * 
 * 1. dayNumber
 * 2. monthNumber
 * 3. yearNumber
 */
Rectangle {
    id: dayDelegate
    
    property date currentDate
    property int delegateWidth
    property date selectedDate
    property bool highlight: (model.yearNumber == selectedDate.getFullYear())  &&  (model.monthNumber == selectedDate.getMonth() + 1) &&  (model.dayNumber == root.selectedDate.getDate())
    property int todosCount
    
    signal dayClicked
    
    width: childrenRect.width
    height: childrenRect.height
    opacity:(dayButton.isCurrentDate || highlight )  ? 0.4 : 1
    color: dayButton.isCurrentDate ? Kirigami.Theme.textColor : ( highlight ? Kirigami.Theme.selectionBackgroundColor : Kirigami.Theme.backgroundColor )                   
    border.color: Kirigami.Theme.disabledTextColor
    
    Item {
        width: dayDelegate.delegateWidth
        height: width
        
        Rectangle {
            anchors {
                bottom: parent.bottom
                bottomMargin: parent.width/15
                right: parent.right
                rightMargin: parent.width/15
                
            }
            
            width: parent.width/10
            height: width
            radius: 50
            color: Kirigami.Theme.selectionFocusColor            
            visible: todosCount > 0
        }
        
        Controls2.ToolButton {
            id: dayButton
                        
            property bool isCurrentDate: ( Qt.formatDate(dayDelegate.currentDate, "yyyy") ==  model.yearNumber ) && ( Qt.formatDate(dayDelegate.currentDate, "MM") ==  model.monthNumber ) && ( Qt.formatDate(dayDelegate.currentDate, "dd") ==  model.dayNumber )
            property bool isCurrentMonth: model.monthNumber == Qt.formatDate(plasmaCalendar.displayedDate, "MM")
                                    
            anchors.fill: parent
            text: model.dayNumber
            enabled: isCurrentMonth
            
            onClicked: dayDelegate.dayClicked()                        
        }
    }
    
}
