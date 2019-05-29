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

ColumnLayout {
    id: root
    
    property date headerDate
    property int headerTodosCount
    property int headerEventsCount
    
    RowLayout {
        id: selectedDayHeading
        
        spacing:  Kirigami.Units.largeSpacing
        
        Controls2.Label {              
            font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 4
            text: root.headerDate.getDate()
            opacity: 0.6
        }
        
        ColumnLayout {
            spacing:  Kirigami.Units.smallSpacing
        
            Controls2.Label {                   
                text: root.headerDate.toLocaleDateString(Qt.locale(), "dddd")
                font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
            }
            
            Controls2.Label {                    
                text: root.headerDate.toLocaleDateString(Qt.locale(), "MMMM") + " " + root.headerDate.getFullYear()
                font.pointSize: Kirigami.Units.fontMetrics.font.pointSize 
            }
        }
    }
    
    Controls2.Label {
        text: ((root.headerTodosCount > 0) ? i18np("%1 task", "%1 tasks",root.headerTodosCount) : "") +
                ((root.headerTodosCount > 0 && root.headerEventsCount > 0) ? " and " : "") +
                    ((root.headerEventsCount > 0) ? i18np("%1 event", "%1 events",root.headerEventsCount) : "")
        opacity: 0.6
    }
}
