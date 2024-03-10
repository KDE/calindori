/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick
import QtQuick.Controls as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.PromptDialog {
    id: reminderEditorSheet

    property alias secondsOffset: seconds.value
    property alias minutesOffset: minutes.value
    property alias hoursOffset: hours.value
    property alias daysOffset: days.value

    property int offset: seconds.value + minutes.value*60 + hours.value*3600 + days.value*86400

    signal offsetSelected

    title: i18n("New Reminder")

    standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel

    ColumnLayout {
        Controls2.Label {
            text: i18n("Time before start")
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

    onAccepted: {
        reminderEditorSheet.offsetSelected();
        reminderEditorSheet.close();
    }
    onRejected: reminderEditorSheet.close();
}
