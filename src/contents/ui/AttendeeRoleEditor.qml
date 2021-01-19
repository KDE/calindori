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

Kirigami.FormLayout {
    id: root

    property var attendeeModelRow
    property int incidenceRole: (attendeeModelRow !== undefined) ? attendeeModelRow.attendeeRole : -1

    Controls2.Label {
        text: attendeeModelRow && attendeeModelRow.email ? attendeeModelRow.email : ""

        Kirigami.FormData.label: i18n("Email:")
    }

    Controls2.Label {
        text: attendeeModelRow && attendeeModelRow.displayStatus ? attendeeModelRow.displayStatus : ""

        Kirigami.FormData.label: i18n("Status:")
    }

    ColumnLayout {
        Kirigami.FormData.label: i18n("Role:")

        Controls2.RadioButton {
            text: i18n("Required")
            checked: root.incidenceRole === Calindori.CalendarAttendee.ReqParticipant

            onToggled: if(checked && attendeeModelRow) { attendeeModelRow.attendeeRole = Calindori.CalendarAttendee.ReqParticipant }
        }

        Controls2.RadioButton {
            text: i18n("Optional")
            checked: root.incidenceRole === Calindori.CalendarAttendee.OptParticipant

            onToggled: if(checked && attendeeModelRow) { attendeeModelRow.attendeeRole = Calindori.CalendarAttendee.OptParticipant }
        }

        Controls2.RadioButton {
            text: i18n("Non-participant")
            checked: root.incidenceRole === Calindori.CalendarAttendee.NonParticipant

            onToggled: if(checked && attendeeModelRow) { attendeeModelRow.attendeeRole = Calindori.CalendarAttendee.NonParticipant }
        }

        Controls2.RadioButton {
            text: i18n("Chairperson")
            checked: root.incidenceRole === Calindori.CalendarAttendee.Chair

            onToggled: if(checked && attendeeModelRow) { attendeeModelRow.attendeeRole = Calindori.CalendarAttendee.Chair }
        }
    }
}
