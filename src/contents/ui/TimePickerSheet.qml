/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.4 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.OverlaySheet {
    id: timePickerSheet

    property alias hours: timePicker.hours
    property alias minutes: timePicker.minutes
    property alias pm: timePicker.pm

    signal datePicked

    contentItem: TimePicker {
        id: timePicker

        Layout.preferredWidth: childrenRect.width + timePickerSheet.rightPadding + timePickerSheet.leftPadding
    }

    footer: RowLayout {

        Item {
            Layout.fillWidth: true
        }

        Controls2.ToolButton {
            text: i18n("OK")
            onClicked: {
                timePickerSheet.datePicked();
                timePickerSheet.close();
            }
        }

        Controls2.ToolButton {
            text: i18n("Cancel")
            onClicked: {
                timePickerSheet.close();
            }
        }
    }
}
