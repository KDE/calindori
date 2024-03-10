/*
* SPDX-FileCopyrightText: 2021 Dimitris Kardarakos <dimkard@posteo.net>
*
* SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.7
import QtQuick.Controls 2.14 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.12 as Kirigami
import org.kde.calindori 0.1 as Calindori

ColumnLayout {
    id: root

    property var alarmsModel

    Controls2.ToolButton {
        text: i18n("Add")
        icon.name: 'list-add'

        onClicked: reminderEditor.open()
    }

    Kirigami.Separator {
        Layout.fillWidth: true
    }

    Repeater {
        id: alarmsList

        model: alarmsModel

        delegate: Kirigami.SwipeListItem {
            contentItem: Controls2.Label {
                text: model.display
                wrapMode: Text.WordWrap
            }

            Layout.fillWidth: true

            actions: [
                Kirigami.Action {
                    id: deleteAlarm

                    icon.name: "delete"
                    onTriggered: alarmsModel.removeAlarm(model.index)
                }
            ]
        }
    }

    Kirigami.PlaceholderMessage {
        width: parent.width - (Kirigami.Units.largeSpacing * 4)
        visible: alarmsList.count === 0
        icon.name: "appointment-reminder"
        text: i18n("No reminders yet")
    }


    ReminderEditor {
        id: reminderEditor

        onOffsetSelected: alarmsModel.addAlarm(offset)
    }
}
