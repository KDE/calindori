
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
    property string uid;
    property alias summary: summary.text;
    property alias description: description.text;
    property alias startHour: startHourSelector.value;
    property alias startMinute: startMinuteSelector.value;
    property alias allDay: allDaySelector.checked;
    property alias location: location.text;
    property var calendar;
    property var todoData;
    
    signal taskeditcompleted
    
    title: qsTr("Task")
    
    Kirigami.FormLayout { 
        id: todoCard
        
        anchors.fill: parent
        //         header: Kirigami.Heading {
        //             text: "New Task"
        //         }
        //         
        
        Controls2.Label {
            text: todoData ? todoData.dtstart.toLocaleDateString(Qt.locale()) : startdt.toLocaleDateString(Qt.locale())
        }
        
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
        }

        Controls2.TextField {
            id: summary
            
            Kirigami.FormData.label: qsTr("Summary:")
            text: todoData ? todoData.summary : ""
        }
        
        Controls2.TextArea {
            id: description
            
            Kirigami.FormData.label: qsTr("Description:")            
            text: todoData ? todoData.description : ""
        }
        
        RowLayout {
            Kirigami.FormData.label: qsTr("Start time:")
            
            Controls2.SpinBox {
                id: startHourSelector
                
                enabled: !allDaySelector.checked
                value: allDaySelector.checkedtodoData ? todoData.dtstart.toLocaleTimeString(Qt.locale(), "hh") : 0
                from: 0
                to: 23
            }
            Controls2.SpinBox {
                id: startMinuteSelector
                
                enabled: !allDaySelector.checked
                value: todoData ? todoData.dtstart.toLocaleTimeString(Qt.locale(), "mm") : 0                    
                from: 0
                to: 59   
            }
        }
               
        Controls2.CheckBox {
            id: allDaySelector
            
            checked: todoData ? todoData.allday: false
            text: qsTr("All day")
        }
        
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
        }        
        
        Controls2.TextField {
            id: location
            
            Kirigami.FormData.label: qsTr("Location:")
            text: todoData ? todoData.location : ""
        }
        
        RowLayout {
            
            Controls2.Button {
                id: saveBtn
                
                text: qsTr("Save")
                icon.name : "document-save"
                
                onClicked: {
                    if(summary.text) {
                        console.log("Saving task");
                        root.calendar.addEditTask(root.uid, root.startdt, root.summary, root.description, root.startHour, root.startMinute, root.allDay, root.location); //TODO: Pass a Todo object
                        taskeditcompleted();
                    }
                    else {
                        showPassiveNotification("Summary should not be empty");
                    }                                                
                }
            }
            
            Controls2.Button {
                id: cancelBtn
                
                text: qsTr("Cancel")
                icon.name : "dialog-cancel"
                
                onClicked: {
                    taskeditcompleted();
                }
            }
        }
    }
}
