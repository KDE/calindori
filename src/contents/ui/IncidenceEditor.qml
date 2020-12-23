/*
* SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
*
* SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.3 as Kirigami
import org.kde.calindori 0.1 as Calindori

ColumnLayout {
    id: root

    property date startDt
    property var alarmsModel
    property var incidenceData
    property alias description: description.text

    Controls2.TextArea {
        id: description

        Layout.fillWidth: true
        Layout.minimumWidth: Kirigami.Units.gridUnit * 4
        Layout.minimumHeight: Kirigami.Units.gridUnit * 4
        Layout.maximumWidth: root.width
        wrapMode: Text.WrapAnywhere
        text: incidenceData ? incidenceData.description : ""
        placeholderText: i18n("Description")
    }

    RowLayout {
        enabled: root.startDt != undefined && !isNaN(root.startDt)

        Controls2.Label {
            id: remindersLabel

            Layout.fillWidth: true
            text: i18n("Reminders")
        }

        Controls2.ToolButton {
            text: i18n("Add")

            onClicked: reminderEditor.open()
        }
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

                    iconName: "delete"
                    onTriggered: alarmsModel.removeAlarm(model.index)
                }
            ]
        }
    }

    ReminderEditor {
        id: reminderEditor

        onOffsetSelected: alarmsModel.addAlarm(offset)
    }
}

