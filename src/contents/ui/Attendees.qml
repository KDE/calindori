/*
* SPDX-FileCopyrightText: 2021 Dimitris Kardarakos <dimkard@posteo.net>
*
* SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.7
import QtQuick.Controls 2.14 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami as Kirigami
import org.kde.calindori 0.1 as Calindori

ColumnLayout {
    id: root

    property var attendeesModel
    property var incidenceData

    Controls2.ToolButton {
        text: i18n("Add")
        icon.name: 'contact-new-symbolic'

        onClicked: {
            if (!Calindori.CalendarController.activeCalendar.isExternal) {
                msg.text = i18n("Attendee management is available only in external calendars that are synchronized online");
                msg.visible = true;
                return;
            }

            if (!Calindori.CalendarController.activeCalendar.ownerName || !Calindori.CalendarController.activeCalendar.ownerEmail) {
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

    RowLayout {
        visible: attendeesList.count !== 0
        Kirigami.Icon {
            source: "meeting-organizer"
        }

        Controls2.Label {
            text: incidenceData ? incidenceData.organizerName : Calindori.CalendarController.activeCalendar.ownerName
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }

    Kirigami.Separator {
        visible: attendeesList.count !== 0
        Layout.fillWidth: true
    }

    Repeater {
        id: attendeesList

        model: attendeesModel

        delegate: Kirigami.SwipeListItem {
            contentItem: RowLayout {
                Kirigami.Icon {
                    source: model.statusIcon
                }

                Controls2.Label {
                    text: model.name
                    wrapMode: Text.WordWrap
                }
            }

            Layout.fillWidth: true

            actions: [
                Kirigami.Action {
                    id: removeAttendee

                    icon.name: "delete"
                    enabled: Calindori.CalendarController.activeCalendar.isExternal && Calindori.CalendarController.activeCalendar.ownerName && Calindori.CalendarController.activeCalendar.ownerEmail

                    onTriggered: attendeesModel.removeItem(model.index)
                },

                Kirigami.Action {
                    id: editAttendee

                    icon.name: "document-edit"
                    enabled: Calindori.CalendarController.activeCalendar.isExternal && Calindori.CalendarController.activeCalendar.ownerName && Calindori.CalendarController.activeCalendar.ownerEmail

                    onTriggered: {
                        infoEditor.attendeeModelRow = model;
                        infoEditor.open();
                    }
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

    AttendeePicker {
        id: attendeeEditor

        onEditorCompleted: attendeesModel.addPersons(selectedUris)
    }

    Kirigami.InlineMessage {
        id: msg

        showCloseButton: true
        visible: false
        Layout.fillWidth: true
    }

    Kirigami.PromptDialog {
        id: infoEditor

        property var attendeeModelRow

        title: infoEditor.attendeeModelRow && infoEditor.attendeeModelRow.name ? infoEditor.attendeeModelRow.name : ""

        AttendeeRoleEditor {
            attendeeModelRow: infoEditor.attendeeModelRow
        }
    }
}
