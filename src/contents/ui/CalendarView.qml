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
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4 as Controls2
import org.kde.kirigami 2.5 as Kirigami


Item {
    
    ColumnLayout {
        spacing: 10
        
//         Controls2.Label {
//             Layout.preferredHeight: 40 
//             Layout.preferredWidth: 40
//             
//             text:  "Plasma Mobile Calendar"
//             color: Kirigami.Theme.textColor
//             font.pixelSize: Kirigami.Units.gridUnit            
//         }
        
        PlayMonthView {
            Layout.preferredHeight: 350
            Layout.preferredWidth: 350
        }
    }
}

