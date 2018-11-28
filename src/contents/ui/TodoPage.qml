
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
import org.kde.kirigami 2.4 as Kirigami
import org.kde.phone.mobilecalendar 0.1 as MobileCalendar

Kirigami.Page {
    id: root
    
    property date startdt;
    property alias summary: summary.text;
    property alias description: description.text;
    property alias startHour: startHourSelector.value;
    property alias startMinute: startMinuteSelector.value;
    property alias allDay: allDaySelector.checked;
    property alias location: location.text;
    property var calendar
    
    signal taskeditcompleted
    
    title: qsTr("Task")
    
    Kirigami.AbstractCard { 
        id: todoCard
        
        anchors.fill: parent
        //         header: Kirigami.Heading {
        //             text: "New Task"
        //         }
        //         
        contentItem: ColumnLayout {
            
            Controls2.Label {
                text: startdt.toLocaleDateString(Qt.locale())
            }
            
            Controls2.TextField {
                id: summary
                
                placeholderText: qsTr("Summary")
            }
            
            RowLayout {
                Controls2.Label {
                    text: "Start time"
                }
            
                Controls2.SpinBox {
                    id: startHourSelector
                    
                    from: 0
                    to: 23
                }
                Controls2.SpinBox {
                    id: startMinuteSelector
                    
                    from: 0
                    to: 59   
                }
            }
            
            Controls2.CheckBox {
                    id: allDaySelector
                    
                    checked: false
                    text: qsTr("All day")
            }
            
            Controls2.TextArea {
                id: description
                
                placeholderText: qsTr("Description")
            }
            
            Controls2.TextArea {
                id: location
                
                placeholderText: qsTr("Location")
            }
            
            RowLayout {
                
                Controls2.Button {
                    id: saveBtn
                    
                    text: "Save"
                    
                    onClicked: {
                        if(summary.text) {
                            console.log("Saving task");
                            root.calendar.addTask(root.startdt, root.summary, root.description, root.startHour, root.startMinute, root.allDay, root.location); //TODO: Pass a Todo object
                            taskeditcompleted();
                        }
                        else {
                            showPassiveNotification("Summary should not be empty");
                        }                                                
                    }
                }
                
                Controls2.Button {
                    id: cancelBtn
                    
                    text: "Cancel"
                    
                    onClicked: {
                        taskeditcompleted();
                    }
                }
            }
        }
    }
}
