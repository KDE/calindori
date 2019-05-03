
/*
 *   Copyright 2018 Dimitris Kardarakos <dimkard@gmail.com>
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

    property date startdt
    property string uid
    property alias summary: summary.text
    property alias description: description.text
    property alias startHour: startTimeSelector.startHour
    property alias startMinute: startTimeSelector.startMinutes
    property alias startPm: startTimeSelector.startPm
    property alias allDay: allDaySelector.checked
    property alias location: location.text
    property var calendar
    property var eventData
    property alias timePicker: timePickerSheet
    property date enddt
    property alias endHour: endTimeSelector.endHour
    property alias endMinute: endTimeSelector.endMinutes
    property alias endPm: endTimeSelector.endPm
    signal editcompleted

    title: qsTr("Event")

    ColumnLayout {

        anchors.centerIn: parent

        Controls2.Label {
            visible: root.startdt != undefined && !isNaN(root.startdt)
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.2
            text: eventData && !isNaN(eventData.dtstart) ? eventData.dtstart.toLocaleDateString(Qt.locale()) : (!isNaN(root.startdt) ? root.startdt.toLocaleDateString(Qt.locale()) : "")
        }

        Kirigami.FormLayout {
            id: eventCard

            enabled: !root.completed

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
            }

            Controls2.Label {
                id: calendarName

                Kirigami.FormData.label: qsTr("Calendar:")
                Layout.fillWidth: true
                text: root.calendar.name
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
            }

            Controls2.TextField {
                id: summary

                Layout.fillWidth: true
                Kirigami.FormData.label: qsTr("Summary:")
                text: eventData ? eventData.summary : ""

            }

            RowLayout {
                Kirigami.FormData.label: qsTr("Start time:")
                enabled: root.startdt != undefined && !isNaN(root.startdt)

                Controls2.ToolButton {
                    id: startTimeSelector

                    property int startHour:  root.eventData ? root.eventData.dtstart.toLocaleTimeString(Qt.locale(), "hh") % 12 : 0
                    property int startMinutes: root.eventData ? root.eventData.dtstart.toLocaleTimeString(Qt.locale(), "mm") : 0
                    property bool startPm : (root.eventData && root.eventData.dtstart.toLocaleTimeString(Qt.locale("en_US"), "AP")  == "PM") ? true : false

                    text: !isNaN(startdt) ? (new Date(startdt.getFullYear(), startdt.getMonth() , startdt.getDate(), startHour + (startPm ? 12 : 0), startMinutes)).toLocaleTimeString(Qt.locale(), "hh:mm AP"): "00:00"

                    enabled: !allDaySelector.checked

                    onClicked: {
                        timePickerSheet.hours = startTimeSelector.startHour
                        timePickerSheet.minutes = startTimeSelector.startMinutes
                        timePickerSheet.pm = startTimeSelector.startPm
                        timePickerSheet.type = "start-picker"

                        timePickerSheet.open()
                    }

                    Connections {
                        target: timePickerSheet

                        onDatePicked: {
                            if(timePickerSheet.type ==  "start-picker") {
                                startTimeSelector.startHour = timePickerSheet.hours
                                startTimeSelector.startMinutes = timePickerSheet.minutes
                                startTimeSelector.startPm = timePickerSheet.pm
                            }
                        }
                    }
                }
            }

            RowLayout {
                Kirigami.FormData.label: qsTr("End time:")
                enabled: root.enddt != undefined && !isNaN(root.enddt)

                Controls2.ToolButton {
                    id: endTimeSelector

                    property int endHour:  root.eventData ? root.eventData.dtend.toLocaleTimeString(Qt.locale(), "hh") % 12 : 0
                    property int endMinutes: root.eventData ? root.eventData.dtend.toLocaleTimeString(Qt.locale(), "mm") : 0
                    property bool endPm : (root.eventData && root.eventData.dtend.toLocaleTimeString(Qt.locale("en_US"), "AP")  == "PM") ? true : false

                    text: !isNaN(enddt) ? (new Date(enddt.getFullYear(), enddt.getMonth() , enddt.getDate(), endHour + (endPm ? 12 : 0), endMinutes)).toLocaleTimeString(Qt.locale(), "hh:mm AP"): "00:00"

                    enabled: !allDaySelector.checked

                    onClicked: {
                        timePickerSheet.hours = endTimeSelector.endHour
                        timePickerSheet.minutes = endTimeSelector.endMinutes
                        timePickerSheet.pm = endTimeSelector.endPm
                        timePickerSheet.type = "end-picker"

                        timePickerSheet.open()
                    }

                    Connections {
                        target: timePickerSheet

                        onDatePicked: {
                            if(timePickerSheet.type ==  "end-picker") {
                                endTimeSelector.endHour = timePickerSheet.hours
                                endTimeSelector.endMinutes = timePickerSheet.minutes
                                endTimeSelector.endPm = timePickerSheet.pm
                            }
                        }
                    }
                }
            }

            Controls2.CheckBox {
                id: allDaySelector

                enabled: !isNaN(root.startdt)
                checked: eventData ? eventData.allday: false
                text: qsTr("All day")
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
            }

            Controls2.TextField {
                id: location

                Layout.fillWidth: true
                Kirigami.FormData.label: qsTr("Location:")
                text: eventData ? eventData.location : ""
            }

        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }


        Controls2.TextArea {
            id: description

            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 4
            Layout.minimumHeight: Kirigami.Units.gridUnit * 4
            wrapMode: Controls2.TextArea.WordWrap
            text: eventData ? eventData.description : ""
            placeholderText:  qsTr("Description")
        }

    }

    actions {

        left: Kirigami.Action {
            id: cancelAction

            text: qsTr("Cancel")
            icon.name : "dialog-cancel"

            onTriggered: {
                editcompleted();
            }
        }


        main: Kirigami.Action {
            id: info

            text: qsTr("Info")
            icon.name : "documentinfo"

            onTriggered: {
                showPassiveNotification("Please save or cancel this event");
            }
        }

        right: Kirigami.Action {
            id: saveAction

            text: qsTr("Save")
            icon.name : "dialog-ok"

            onTriggered: {
                if(summary.text) {
                    console.log("Saving event, root.startdt:" + startdt);
                    root.calendar.addEditEvent( { "uid" : root.uid, "startDate": root.startdt, "summary": root.summary, "description": root.description, "startHour": root.startHour + (root.startPm ? 12 : 0), "startMinute": root.startMinute, "allDay": root.allDay, "location": root.location, "endDate": root.enddt, "endHour": root.endHour + (root.endPm ? 12 : 0), "endMinute": root.endMinute, }) ;
                    editcompleted();
                }
                else {
                    showPassiveNotification("Summary should not be empty");
                }
            }
        }
    }

    Kirigami.OverlaySheet {
        id: timePickerSheet

        property int hours
        property int minutes
        property bool pm
        property string type

        signal datePicked

        rightPadding: 0
        leftPadding: 0

        contentItem: TimePicker {
            id: timePicker

            hours: timePickerSheet.hours
            minutes: timePickerSheet.minutes
            pm: timePickerSheet.pm
        }

        footer: RowLayout {
            Item {
                Layout.fillWidth: true
            }
            Controls2.ToolButton {
                text: qsTr("OK")
                onClicked: {
                    timePickerSheet.hours = timePicker.hours
                    timePickerSheet.minutes = timePicker.minutes
                    timePickerSheet.pm = timePicker.pm
                    timePickerSheet.datePicked()
                    timePickerSheet.close()
                }
            }
            Controls2.ToolButton {
                text: qsTr("Cancel")
                onClicked: {
                    timePicker.hours = timePickerSheet.hours
                    timePicker.minutes = timePickerSheet.minutes
                    timePicker.pm = timePickerSheet.pm
                    timePickerSheet.close()
                }
            }
        }
    }

}
