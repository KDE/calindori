
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

                    text: !isNaN(root.startdt) ? (new Date(root.startdt.getFullYear(), root.startdt.getMonth() , root.startdt.getDate(), startHour + (startPm ? 12 : 0), startMinutes)).toLocaleTimeString(Qt.locale(), "hh:mm AP"): "00:00"

                    enabled: !allDaySelector.checked

                    onClicked: {
                        startTimePickerSheet.hours = startTimeSelector.startHour
                        startTimePickerSheet.minutes = startTimeSelector.startMinutes
                        startTimePickerSheet.pm = startTimeSelector.startPm

                        startTimePickerSheet.open()
                    }

                    Connections {
                        target: startTimePickerSheet

                        onDatePicked: {
                            startTimeSelector.startHour = startTimePickerSheet.hours
                            startTimeSelector.startMinutes = startTimePickerSheet.minutes
                            startTimeSelector.startPm = startTimePickerSheet.pm
                        }
                    }
                }
            }

            RowLayout {
                Kirigami.FormData.label: qsTr("End time:")
                enabled: root.enddt != undefined && !isNaN(root.enddt)

                Controls2.ToolButton {
                    id: endTimeSelector

                    property int endHour: root.eventData ? root.eventData.dtend.toLocaleTimeString(Qt.locale(), "hh") % 12 : 0
                    property int endMinutes: root.eventData ? root.eventData.dtend.toLocaleTimeString(Qt.locale(), "mm") : 0
                    property bool endPm : (root.eventData && root.eventData.dtend.toLocaleTimeString(Qt.locale("en_US"), "AP")  == "PM") ? true : false

                    text: !isNaN(enddt) ? (new Date(enddt.getFullYear(), enddt.getMonth() , enddt.getDate(), endHour + (endPm ? 12 : 0), endMinutes)).toLocaleTimeString(Qt.locale(), "hh:mm AP"): "00:00"

                    enabled: !allDaySelector.checked

                    onClicked: {
                        endTimePickerSheet.hours = endTimeSelector.endHour
                        endTimePickerSheet.minutes = endTimeSelector.endMinutes
                        endTimePickerSheet.pm = endTimeSelector.endPm

                        endTimePickerSheet.open()
                    }

                    Connections {
                        target: endTimePickerSheet

                        onDatePicked: {
                            var endDtTime = root.enddt;
                            endDtTime.setHours(endTimePickerSheet.hours + (endTimePickerSheet.pm ? 12 : 0));
                            endDtTime.setMinutes( endTimePickerSheet.minutes);

                            var startDtTime = root.startdt;
                            startDtTime.setHours(root.startHour + (root.startPm ? 12 : 0));
                            startDtTime.setMinutes(root.startMinute);

                            if(endDtTime >= startDtTime) {
                                endTimeSelector.endHour = endTimePickerSheet.hours
                                endTimeSelector.endMinutes = endTimePickerSheet.minutes
                                endTimeSelector.endPm = endTimePickerSheet.pm
                            }
                            else
                            {
                                showPassiveNotification("End date time should be after start date time");
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
                    var controller = eventController.createObject(parent, {calendar: root.calendar});
                    controller.vevent = { "uid" : root.uid, "startDate": root.startdt, "summary": root.summary, "description": root.description, "startHour": root.startHour + (root.startPm ? 12 : 0), "startMinute": root.startMinute, "allDay": root.allDay, "location": root.location, "endDate": root.enddt, "endHour": root.endHour + (root.endPm ? 12 : 0), "endMinute": root.endMinute };
                    controller.addEdit();
                    editcompleted();
                }
                else {
                    showPassiveNotification("Summary should not be empty");
                }
            }
        }
    }

    TimePickerSheet {
        id: startTimePickerSheet
    }

    TimePickerSheet {
        id: endTimePickerSheet
    }

    Component {
        id: eventController

        Calindori.EventController {
        }
    }
}
