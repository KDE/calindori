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
import QtQuick.Controls 1.4 as QuickControls
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
    
    
    Component {
        id: calendarDashboardComponent
        
        
        Kirigami.ScrollablePage {
            id: monthPage
            
            anchors.fill: parent
            
            title: qsTr("Mobile Calendar")
            
            actions {                
                left: Kirigami.Action {
                    iconName: "go-previous"
                    
                    onTriggered: {
                        var prv = monthView.month - 1 ;
                        if (prv == -1 ) {
                            monthView.month = 11;
                            --monthView.year;
                        }
                        else {
                            monthView.month = prv
                        }               
                    }
                }
                
                right: Kirigami.Action {
                    iconName: "go-next"
                    
                    onTriggered: {                    
                        var nxt = monthView.month + 1 ;
                        if (nxt == 12) {
                            monthView.month = 0;
                            ++monthView.year;
                        }
                        else {
                            monthView.month = nxt
                        }                                   
                    }
                }
            }
            
            
            mainItem: PlayMonthView {
                id: monthView
                
                height: monthPage.height
                width: monthPage.width
            }
            
        }
    }
    
    MobileCalendar.Config {
        id: mobileCalendarConfig;
    }
}
