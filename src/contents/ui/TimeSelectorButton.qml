/*
 *   Copyright 2020 Dimitris Kardarakos <dimkard@posteo.net>
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

Controls2.ToolButton {
    id: root

    property date selectorDate
    property int selectorHour
    property int selectorMinutes
    property bool selectorPm

    text: !isNaN(selectorDate) ? (new Date(root.selectorDate.getFullYear(), root.selectorDate.getMonth() , root.selectorDate.getDate(), selectorHour + (selectorPm ? 12 : 0), selectorMinutes)).toLocaleTimeString(Qt.locale(), "HH:mm") : "00:00"

    onClicked: {
        timePickerSheet.hours = selectorHour;
        timePickerSheet.minutes = selectorMinutes;
        timePickerSheet.pm = selectorPm;
        timePickerSheet.open();
    }

    TimePickerSheet {
        id: timePickerSheet

        onDatePicked: {
            root.selectorHour = timePickerSheet.hours;
            root.selectorMinutes = timePickerSheet.minutes;
            root.selectorPm = timePickerSheet.pm;
        }
    }    
}
