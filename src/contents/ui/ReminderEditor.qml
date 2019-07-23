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

import QtQuick 2.0
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.4 as Kirigami
import org.kde.phone.calindori 0.1 as Calindori

Kirigami.OverlaySheet {
    id: reminderEditorSheet

    property alias secondsOffset: seconds.value
    property alias minutesOffset: minutes.value
    property alias hoursOffset: hours.value
    property alias daysOffset: days.value
    
    property int offset: seconds.value + minutes.value*60 + hours.value*3600 + days.value*86400

    signal offsetSelected

    rightPadding: 0
    leftPadding: 0

    contentItem: ColumnLayout {
            Kirigami.Heading {
                level:2
                text: i18n("Time before start")
                Layout.alignment : Qt.AlignHCenter
            }

            Kirigami.FormLayout {
            id: alarmOffsetPicker
            
            Controls2.SpinBox {
                id: seconds
                
                from: 0
                to: 60
                value: 0
                
                Kirigami.FormData.label: i18n("Seconds:")
            }        
            Controls2.SpinBox {
                id: minutes
                
                from: 0
                to: 60
                value: 0
                
                Kirigami.FormData.label: i18n("Minutes:")
            }
            
            Controls2.SpinBox {
                id: hours
                
                from: 0
                to: 24
                value: 0
                
                Kirigami.FormData.label: i18n("Hours:")
            }
            
            Controls2.SpinBox {
                id: days
                
                from: 0
                value: 0
                
                Kirigami.FormData.label: i18n("Days:")
            }
        }
    }
        

    footer: RowLayout {

        Item {
            Layout.fillWidth: true
        }

        Controls2.ToolButton {
            text: i18n("OK")
            onClicked: {
                reminderEditorSheet.offsetSelected();
                reminderEditorSheet.close();
            }
        }

        Controls2.ToolButton {
            text: i18n("Cancel")
            onClicked: {
                reminderEditorSheet.close();
            }
        }
    }
}
