
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
import org.kde.kirigami 2.4 as Kirigami

Kirigami.Page {
    id: root
    
    property alias calendarName: name.text
    property alias activeCalendar: isactive.checked
    
    signal calendarAdded;
    signal calendarAddCanceled;
    
    
    title: qsTr("New calendar")

    Kirigami.FormLayout { 
        id: calendarInputPage
        
        anchors.centerIn: parent
        
        Controls2.TextField {
            id: name
            
            Kirigami.FormData.label: qsTr("Name:")           
        } 
        
        Controls2.CheckBox {
            id: isactive
            
            Kirigami.FormData.label: qsTr("Active:")
        }        
    }

    actions {
        
        left: Kirigami.Action {
            id: cancelAction
            
            text: qsTr("Cancel")
            icon.name : "dialog-cancel"
            
            onTriggered: {
                calendarAddCanceled();
            }
        }
        
        
        main: Kirigami.Action {
            id: info
            
            text: qsTr("Info")
            icon.name : "documentinfo"
            
            onTriggered: {
                showPassiveNotification("Please save or cancel the creation of the new calendar");
            }
        }
        
        right: Kirigami.Action {
            id: saveAction
            
            text: qsTr("Save")            
            icon.name : "dialog-ok"
            
            onTriggered: {
                calendarAdded();
            }
        }
    }
}
