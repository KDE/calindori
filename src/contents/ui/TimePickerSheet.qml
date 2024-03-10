/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.Dialog {
    id: timePickerSheet

    property string headerText
    property alias hours: timePicker.hours
    property alias minutes: timePicker.minutes
    property alias pm: timePicker.pm

    signal datePicked
    title: timePickerSheet.headerText
    standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel

    preferredWidth: Kirigami.Units.gridUnit * 25
    preferredHeight: Kirigami.Units.gridUnit * 25

    TimePicker {
        id: timePicker
        width: Kirigami.Units.gridUnit * 20
        height: Kirigami.Units.gridUnit * 25
    }

    onAccepted: {
        timePickerSheet.datePicked();
        timePickerSheet.close();
    }
    onRejected: timePickerSheet.close();
}
