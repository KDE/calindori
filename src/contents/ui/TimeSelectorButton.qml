/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Controls 2.4 as Controls2

Controls2.ToolButton {
    id: root

    property string selectorTitle
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

        headerText: root.selectorTitle

        onDatePicked: {
            root.selectorHour = timePickerSheet.hours;
            root.selectorMinutes = timePickerSheet.minutes;
            root.selectorPm = timePickerSheet.pm;
        }
    }
}
