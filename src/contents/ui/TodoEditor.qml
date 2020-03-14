/*
 *   Copyright 2018-2020 Dimitris Kardarakos <dimkard@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.4 as Kirigami
import org.kde.phone.calindori 0.1 as Calindori

Kirigami.Page {
    id: root

    property date startDt
    property string uid
    property alias summary: summary.text
    property alias description: description.text
    property alias startHour: startTimeSelector.selectorHour
    property alias startMinute: startTimeSelector.selectorMinutes
    property alias startPm: startTimeSelector.selectorPm
    property alias allDay: allDaySelector.checked
    property alias location: location.text
    property alias completed: completed.checked
    property var calendar
    property var incidenceData

    signal editcompleted

    title: uid == "" ? i18n("Add task") : i18n("Edit task")

    ColumnLayout {

        anchors.centerIn: parent

        Controls2.Label {
            visible: root.startDt != undefined && !isNaN(root.startDt)
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.2
            text: incidenceData && !isNaN(incidenceData.dtstart) ? incidenceData.dtstart.toLocaleDateString(Qt.locale()) : (!isNaN(root.startDt) ? root.startDt.toLocaleDateString(Qt.locale()) : "")
        }

        Kirigami.FormLayout {
            id: todoCard

            enabled: !root.completed

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
            }

            Controls2.Label {
                id: calendarName

                Kirigami.FormData.label: i18n("Calendar:")
                Layout.fillWidth: true
                text: root.calendar.name
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
            }

            Controls2.TextField {
                id: summary

                Layout.fillWidth: true
                Kirigami.FormData.label: i18n("Summary:")
                text: incidenceData ? incidenceData.summary : ""
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Start time:")
                enabled: root.startDt != undefined && !isNaN(root.startDt)

                TimeSelectorButton {
                    id: startTimeSelector

                    selectorDate: root.startDt
                    selectorHour: root.incidenceData ? root.incidenceData.dtstart.toLocaleTimeString(Qt.locale(), "hh") % 12 : 0
                    selectorMinutes: root.incidenceData ? root.incidenceData.dtstart.toLocaleTimeString(Qt.locale(), "mm") : 0
                    selectorPm: (root.incidenceData && root.incidenceData.dtstart.toLocaleTimeString(Qt.locale("en_US"), "AP")  == "PM") ? true : false
                    enabled: !allDaySelector.checked
                }
            }

            Controls2.CheckBox {
                id: allDaySelector

                enabled: !isNaN(root.startDt)
                checked: incidenceData ? incidenceData.allday: false
                text: i18n("All day")
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
            }

            Controls2.TextField {
                id: location

                Layout.fillWidth: true
                Kirigami.FormData.label: i18n("Location:")
                text: incidenceData ? incidenceData.location : ""
            }

        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls2.TextArea {
            id: description

            enabled: !root.completed
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 4
            Layout.minimumHeight: Kirigami.Units.gridUnit * 4
            Layout.maximumWidth: todoCard.width
            wrapMode: Text.WrapAnywhere
            text: incidenceData ? incidenceData.description : ""
            placeholderText: i18n("Description")
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls2.CheckBox {
            id: completed

            text: i18n("Completed")
            checked: incidenceData ? incidenceData.completed: false
        }
    }

    actions {
        left: Kirigami.Action {
            id: cancelAction

            text: i18n("Cancel")
            icon.name : "dialog-cancel"
            shortcut: "Esc"

            onTriggered: {
                editcompleted();
            }
        }

        main: Kirigami.Action {
            text: i18n("Save")
            icon.name : "dialog-ok"
            enabled: summary.text

            onTriggered: {
                console.log("Saving task");
                var vtodo = { "uid": root.uid, "summary":root.summary, "startDate": root.startDt , "startHour": root.startHour + (root.startPm ? 12 : 0), "startMinute": root.startMinute, "allDay": root.allDay, "description":  root.description,"location":  root.location, "completed": root.completed };
                _todoController.addEdit(root.calendar, vtodo);
                editcompleted();
            }
        }
    }
}
