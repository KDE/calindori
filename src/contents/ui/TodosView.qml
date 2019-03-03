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
import org.kde.phone.calindori 0.1 as Calindori

Kirigami.Page {
    id: root
    
    property date todoDt
    property var calendar
    
    signal editTask(var modelData)
    signal taskDeleted
    signal refreshNeeded
    
    function reloadModel() {
        cardsListview.model.reloadTasks();
    }
    
    function setModel() {
        var todosModelObj = todosModelComponent.createObject(root,  {"filterdt": root.todoDt, "memorycalendar": root.calendar.memorycalendar });
        cardsListview.model = todosModelObj;
        cardsListview.model.reloadTasks();
    }
        
    onTodoDtChanged: setModel()
    onRefreshNeeded: reloadModel()
    
    title: qsTr("Tasks")
    
    Component {
        id: todosModelComponent
        
        Calindori.TodosModel {}
    }
    
    Kirigami.CardsListView {
        id: cardsListview
        anchors.fill: parent
       
        delegate: Kirigami.Card {               
            header: Kirigami.Heading {
                text: model.summary
                level: 3
            }
            
            actions: [
                Kirigami.Action {
                    text: qsTr("Delete")
                    icon.name: "delete"
                    
                    onTriggered: {
                        root.calendar.deleteTask(model.uid);
                        taskDeleted();
                    }                    
                },
                
                Kirigami.Action {
                    text: qsTr("Edit")
                    icon.name: "editor"
                    
                    onTriggered: root.editTask(model)
                }            
            ]
            
            contentItem: ColumnLayout {
                
                Controls2.Label {
                    wrapMode: Text.WordWrap
                    text: model.description
                }
                
                RowLayout {
                    visible: model.dtstart.toLocaleTimeString(Qt.locale()) != ""
                    
                    Controls2.Label {
                        wrapMode: Text.WordWrap
                        text: model.dtstart.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                    }
                } 
                
                RowLayout {
                    visible: model.location != ""
                    
                    Controls2.Label {
                        wrapMode: Text.WordWrap
                        text: model.location
                    }    
                }                
            }
        }
    }    
}

