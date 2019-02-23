/*
 *   Copyright 2019 Dimitris Kardarakos <dimkard@posteo.net>
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

import QtQuick 2.12
import QtQuick.Controls 2.5 as Controls2
import org.kde.kirigami 2.0 as Kirigami
import QtQuick.Layouts 1.11

ColumnLayout {
    
    id: root
    
    property int hours
    property int minutes
    
    implicitWidth: clock.width
    implicitHeight: clock.height
    
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        
        Controls2.Label {
            text: root.hours + ":" + root.minutes
        }
        
        //TODO: Handle AM/PM
//         Controls2.ToolButton {
//             id: pm
//             
//             checkable: true
//            
//             text: checked ? "PM" : "AM"
//         }
    }
    
    Item {
        id: clock
        width: Kirigami.Units.gridUnit * 22
        height: Kirigami.Units.gridUnit * 22
        
        //Hours clock
        PathView {
            id: hoursClock
            
            delegate: ClockElement {
                type: "hours"
                selectedValue: root.hours
                onClicked: root.hours = index 
            }
            model: 12
            path: Path {
                PathAngleArc {
                    centerX: Kirigami.Units.gridUnit * 10
                    centerY: Kirigami.Units.gridUnit * 10
                    radiusX: Kirigami.Units.gridUnit * 5
                    radiusY: Kirigami.Units.gridUnit * 5
                    startAngle: -90
                    sweepAngle: 360
                }   
            }
        }
        
        PathView {
            Path {     
                startX: 0
                startY: Kirigami.Units.gridUnit * 10        
                PathArc {
                    x: 0
                    y: Kirigami.Units.gridUnit * 10
                    radiusX: Kirigami.Units.gridUnit * 5
                    radiusY: Kirigami.Units.gridUnit * 5
                    useLargeArc: true
                }  
            }
        }
        
        //Minutes clock
        PathView {
            id: minutesClock
            
            model: 60
            
            delegate: ClockElement {
                type: "minutes"
                selectedValue: root.minutes
                onClicked: root.minutes = index 
            }
            
            path: Path {
                PathAngleArc {
                    centerX: Kirigami.Units.gridUnit * 10
                    centerY: Kirigami.Units.gridUnit * 10
                    radiusX: Kirigami.Units.gridUnit * 8
                    radiusY: Kirigami.Units.gridUnit * 8
                    startAngle: -90
                    sweepAngle: 360
                }           
            }
        }
    }
}
