/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import org.kde.kirigami 2.0 as Kirigami

Controls2.ToolButton {
    id: root

    property string selectorTitle
    property date selectorDate
    property int selectorHour
    property int selectorMinutes
    property bool selectorPm

    contentItem: Controls2.Label {
        leftPadding: Kirigami.Units.largeSpacing
        rightPadding: Kirigami.Units.largeSpacing
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: {
            if(!isNaN(root.selectorDate)) {
                var textDt = root.selectorDate;
                textDt.setHours(root.selectorHour + (root.selectorPm ? 12 : 0));
                textDt.setMinutes(root.selectorMinutes);
                textDt.setSeconds(0);

                return textDt.toLocaleTimeString(_appLocale, "HH:mm");
            }
            else {
                return "";
            }
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
