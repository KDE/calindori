/*
 *   Copyright 2018 Dimitris Kardarakos <dimkard@posteo.net>
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
    
    signal dayClicked
    
    width: childrenRect.width
    height: childrenRect.height
    opacity:(isToday || highlight )  ? 0.4 : 1
    color: isToday ? Kirigami.Theme.textColor : ( highlight ? Kirigami.Theme.selectionBackgroundColor : Kirigami.Theme.backgroundColor )
    border.color: Kirigami.Theme.disabledTextColor
    
    Item {
        width: dayDelegate.delegateWidth
        height: width
        
        /**
         * Display a tiny indicator in case that 
         * todos or events exist for the day of the model
         */
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
            visible: incidenceCount > 0
        }
        
        Controls2.ToolButton {
            id: dayButton
                        
            anchors.fill: parent
            enabled: isCurrentMonth
            
            text: model.dayNumber

            onClicked: dayDelegate.dayClicked()                        
        }
    }
    
}
