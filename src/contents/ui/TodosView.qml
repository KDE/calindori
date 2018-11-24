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
import Qt.labs.platform 1.0 


Kirigami.ScrollablePage {
    id: root
    
    property date todoDt
    property alias calendar: todosModel.calendar
    property alias todosmodel: cardsListview.model
    title: qsTr("Tasks")
    
    
    Kirigami.CardsListView {
        id: cardsListview

        model: 
            MobileCalendar.TodosModel {
                id: todosModel
                
                filterdt: todoDt
                calendar:  Qt.resolvedUrl( StandardPaths.standardLocations(StandardPaths.DataLocation)[0] + "/localcalendar")
            }
        
        delegate: Kirigami.AbstractCard {               
            header: Kirigami.Heading {
                text: model.summary
                level: 2
            }
            
            contentItem: Controls2.Label {
                wrapMode: Text.WordWrap
                    text: model.description
            }
        }
    }
}

