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
    property int todosCount
    
    RowLayout {
        id: selectedDayHeading
        
        spacing:  Kirigami.Units.gridUnit / 2
        
        Controls2.Label {              
            font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 4
            text: root.headerDate.getDate()
            opacity: 0.6
        }
        
        ColumnLayout {
            
            spacing:  Kirigami.Units.gridUnit / 6
            
            Controls2.Label {                   
                text: root.headerDate.toLocaleDateString(Qt.locale(), "dddd");
                font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
            }
            
            Controls2.Label {                    
                text: root.currentMonthName + " " + root.headerDate.getFullYear()
            }
        }
    }
    
    Controls2.Label {
        text: (root.todosCount) ? i18np("%1 task for today", "%1 tasks for today",root.todosCount) : ""
        opacity: 0.6
        bottomPadding: Kirigami.Units.gridUnit / 2
    }
}
