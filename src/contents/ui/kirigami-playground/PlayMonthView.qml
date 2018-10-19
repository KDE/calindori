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
import Qt.labs.calendar 1.0 as Labs //TODO: To be removed, added just to provide a model
import org.kde.kirigami 2.0 as Kirigami

Item {
    id: monthview
    
    property int days: 7
    property int weeks: 6
    property date currentDate: new Date()
    
    // HACK: Added only as a temporary model provider, to be replaced with the real model provider
    Labs.AbstractMonthGrid { 
        id: monthModelProvider
    }
    
    //HACK:Added only as a temporary model provider, to be replaced with the real model provider
    Labs.AbstractDayOfWeekRow {
        id: weekModelProvider
    }
    
    ColumnLayout {
        spacing: 0
        
        RowLayout {
            spacing: 10
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: Kirigami.Units.gridUnit/2
            
            Controls2.ToolButton {
                id: previous_month

                width: Kirigami.Units.gridUnit*2
                height: width
                
                
                icon.name: "go-previous"
                onClicked: { 
                    var prv = monthModelProvider.month - 1 ;
                    if (prv == -1 ) {
                        monthModelProvider.month = 11;
                        --monthModelProvider.year;
                    }
                    else {
                        monthModelProvider.month = prv
                    }               
                }
            }
            
            Controls2.Label {                
                color: Kirigami.Theme.textColor
                font.pixelSize: Kirigami.Units.gridUnit    
                text: Qt.formatDate(new Date(monthModelProvider.year, monthModelProvider.month), "MMM yyyy")
            }
            
            Controls2.ToolButton {
                id: next_month
                
                width: Kirigami.Units.gridUnit*2
                height: width
                
                icon.name: "go-next"
                onClicked: { 
                    var nxt = monthModelProvider.month + 1 ;
                    if (nxt == 12) {
                        monthModelProvider.month = 0;
                        ++monthModelProvider.year;
                    }
                    else {
                        monthModelProvider.month = nxt
                    }               
                }
            }
        }
        
        Rectangle {
            height: 1
            Layout.fillWidth: true
            color: Kirigami.Theme.disabledTextColor
        }

        RowLayout {
            spacing: 0           
            
            Repeater {
                model: weekModelProvider.source
                delegate: weekDayDelegate
            }
        }
        
        Grid {        
            Layout.fillWidth: true
            
            columns: monthview.days
            rows: monthview.weeks
            
            Repeater {
                model: monthModelProvider.source
                
                delegate: monthDayDelegate             
            }
        }
    }

    /**
     * Month Day Delegate
     */
    Component {
        id: monthDayDelegate 
        
        Rectangle {
            width: childrenRect.width
            height: childrenRect.height
            opacity: dayButton.currentDate ? 0.4 : 1
            color: dayButton.currentDate ? Kirigami.Theme.textColor : Kirigami.Theme.backgroundColor                    
            border.color: Kirigami.Theme.disabledTextColor

            Controls2.ToolButton {
                id: dayButton
                
                property bool currentDate: Qt.formatDate(model.date, "MM-dd-yyyy") == 
                Qt.formatDate(monthview.currentDate, "MM-dd-yyyy")
                
                width: Kirigami.Units.gridUnit*2
                height: width
                checkable: true
                text: model.day
                
            }

        }
    }

    /**
     * Week Day Delegate
     */
    Component {
        id: weekDayDelegate 
        
        Rectangle {
            width: childrenRect.width
            height: childrenRect.height
            color: Kirigami.Theme.textColor 
            opacity: 0.4
            
            Controls2.ToolButton {
                id: dayButton
                                
                width: Kirigami.Units.gridUnit*2
                height: width
                
                text: model.shortName                
            }

        }
    }

}
