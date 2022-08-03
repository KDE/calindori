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

    property var incidenceData
    property var calendar
    property int incidenceType
    property alias description: description.text
    property alias location: location.text
    property alias incidenceStatus: statusCombo.currentValue
    property alias completed: completed.checked
    readonly property string canceledStatus: i18n("Canceled")
    readonly property string confirmedStatus: i18n("Confirmed")
    readonly property string tentativeStatus: i18n("Tentative")

    Kirigami.FormLayout {
        Layout.fillWidth: true

        Controls2.Label {
            id: calendarName

            text: root.calendar.name
            Kirigami.FormData.label: i18n("Calendar:")
        }

        Controls2.ComboBox {
            id: statusCombo

            visible: incidenceType === 0
            model: [
                {"name": canceledStatus, "code": Calindori.IncidenceModel.StatusCanceled},
                {"name": confirmedStatus, "code": Calindori.IncidenceModel.StatusConfirmed},
                {"name": tentativeStatus, "code": Calindori.IncidenceModel.StatusTentative}
            ]
            textRole: "name"
            valueRole: "code"
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Status:")

            Component.onCompleted: {
                currentIndex = root.incidenceData ? indexOfValue(root.incidenceData.status) : indexOfValue(Calindori.IncidenceModel.StatusConfirmed);
            }
        }

        Controls2.TextField {
            id: location

            enabled: (incidenceType === 1 && root.completed) ? false : true
            text: root.incidenceData ? root.incidenceData.location : ""
            wrapMode: Text.WrapAnywhere
            Kirigami.FormData.label: i18n("Location:")
        }

        Controls2.TextField {
            id: description

            enabled: (incidenceType === 1 && root.completed) ? false : true
            wrapMode: Text.WrapAnywhere
            text: root.incidenceData ? root.incidenceData.description : ""
            Kirigami.FormData.label: i18n("Description:")
        }
        Controls2.CheckBox {
            id: completed

            visible: incidenceType === 1
            checked: root.incidenceData ? root.incidenceData.completed: false
            Kirigami.FormData.label: i18n("Completed:")
        }
    }

}

