/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.OverlaySheet {
    id: timePickerSheet

    property string headerText
    property alias hours: timePicker.hours
    property alias minutes: timePicker.minutes
    property alias pm: timePicker.pm

    signal datePicked
    header: Kirigami.Heading {
        level:1
        text: timePickerSheet.headerText
    }

    contentItem: TimePicker {
        id: timePicker

        height: Kirigami.Units.gridUnit * 25
        width: childrenRect.width + timePickerSheet.rightPadding + timePickerSheet.leftPadding
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
