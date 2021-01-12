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

    property var attendeesModel
    property var incidenceData
    property var calendar

    Controls2.ToolButton {
        text: i18n("Add")
        icon.name: 'contact-new-symbolic'

        onClicked: {
            if (!calendar.isExternal) {
                msg.text = i18n("Attendee management is available only in external calendars that are synchronized online");
                msg.visible = true;
                return;
            }

            if (!calendar.ownerName || !calendar.ownerEmail) {
                msg.text = i18n("Please set the calendar owner details in the application settings");
                msg.visible = true;
                return;
            }

            msg.visible = false;
            attendeeEditor.preEditEmails = attendeesModel.emails();
            attendeeEditor.selectedPersons = [];
            attendeeEditor.open();
        }

    }

    Kirigami.Separator {
        Layout.fillWidth: true
    }

    Repeater {
        id: attendeesList

        model: attendeesModel

        delegate: Kirigami.SwipeListItem {
            contentItem: Controls2.Label {
                text: model.name
                wrapMode: Text.WordWrap
            }

            Layout.fillWidth: true

            actions: [
                Kirigami.Action {
                    id: removeAttendee

                    iconName: "delete"
                    enabled: calendar.isExternal && calendar.ownerName && calendar.ownerEmail

                    onTriggered: attendeesModel.removeItem(model.index)
                }
            ]
        }
    }

    Kirigami.PlaceholderMessage {
        width: parent.width - (Kirigami.Units.largeSpacing * 4)
        visible: attendeesList.count === 0
        icon.name: "meeting-attending"
        text: i18n("No attendees yet")
    }

    AttendeeEditor {
        id: attendeeEditor

        onEditorCompleted: attendeesModel.addPersons(selectedUris)
    }

    Kirigami.InlineMessage {
        id: msg

        showCloseButton: true
        visible: false
        Layout.fillWidth: true
    }
}

