/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2

Controls2.ToolButton {
    id: root

    property string selectorTitle
    property date selectorDate
    property int selectorHour
    property int selectorMinutes
    property bool selectorPm

    text: {
        if(!isNaN(selectorDate)) {
            var textDt = selectorDate;
            textDt.setHours(selectorHour + (selectorPm ? 12 : 0));
            textDt.setMinutes(selectorMinutes);
            textDt.setSeconds(0);

            return textDt.toLocaleTimeString(_appLocale, "HH:mm");
        }
        else {
            return "00.00";
        }
    }

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
