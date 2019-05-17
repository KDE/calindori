
/*
 *   Copyright 2019 Dimitris Kardarakos <dimkard@gmail.com>
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
    property alias enddt: endDateSelector.endDate
    property alias endHour: endTimeSelector.endHour
    property alias endMinute: endTimeSelector.endMinutes
    property alias endPm: endTimeSelector.endPm

    signal editcompleted

    /**
     * Function taht checks that the user input is valid
     *
     * Returns an object with success status and reason
     */
    function validate()
    {
        var result = { success: false, reason: "" };

        if(!(root.summary)) {
            result.reason = "Summary should not be empty";
            return result;
        }

        var endDtTime = new Date(root.enddt.getFullYear(), root.enddt.getMonth(), root.enddt.getDate(), root.endHour + (root.endPm ? 12 : 0), root.endMinute);

        var startDtTime = new Date(root.startdt.getFullYear(), root.startdt.getMonth(), root.startdt.getDate(), root.startHour + (root.startPm ? 12 : 0), root.startMinute);

        if(!(root.allDay) && (endDtTime < startDtTime)) {
            result.reason = "End date time should be after start date time";
            return result;
        }

        result.success = true;
        return result;
    }

    title: qsTr("Event")

    ColumnLayout {

        anchors.centerIn: parent

        Kirigami.FormLayout {
            id: eventCard

            enabled: !root.completed

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
                Kirigami.FormData.label: qsTr("Start:")
                spacing: 0

                Controls2.ToolButton {
                    Layout.fillWidth: true
                    text: root.startdt.toLocaleDateString(Qt.locale(),Locale.NarrowFormat)

                    onClicked: showPassiveNotification("Start date cannot be changed")
                }

                Controls2.ToolButton {
                    id: startTimeSelector

                    property int startHour:  root.eventData ? root.eventData.dtstart.toLocaleTimeString(Qt.locale(), "hh") % 12 : 0
                    property int startMinutes: root.eventData ? root.eventData.dtstart.toLocaleTimeString(Qt.locale(), "mm") : 0
                    property bool startPm: (root.eventData && root.eventData.dtstart.toLocaleTimeString(Qt.locale("en_US"), "AP")  == "PM") ? true : false

                    text: (new Date(root.startdt.getFullYear(), root.startdt.getMonth() , root.startdt.getDate(), startHour + (startPm ? 12 : 0), startMinutes)).toLocaleTimeString(Qt.locale(), "HH:mm")
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
                Kirigami.FormData.label: "End:"
                spacing: 0

                Controls2.ToolButton {
                    id: endDateSelector

                    property date endDate: root.eventData ? root.eventData.dtend : root.startdt

                    text: endDateSelector.endDate.toLocaleDateString(Qt.locale(),Locale.NarrowFormat)
                    enabled: !allDaySelector.checked

                    onClicked: {
                        endDatePickerSheet.selectedDate = endDateSelector.endDate
                        endDatePickerSheet.open()
                    }

                    Connections {
                        target: endDatePickerSheet

                        onDatePicked: {
                            endDateSelector.endDate = endDatePickerSheet.selectedDate
                        }
                    }
                }

                Controls2.ToolButton {
                    id: endTimeSelector

                    property int endHour: root.eventData ? root.eventData.dtend.toLocaleTimeString(Qt.locale(), "hh") % 12 : 0
                    property int endMinutes: root.eventData ? root.eventData.dtend.toLocaleTimeString(Qt.locale(), "mm") : 0
                    property bool endPm: (root.eventData && root.eventData.dtend.toLocaleTimeString(Qt.locale("en_US"), "AP")  == "PM") ? true : false

                    text: !isNaN(enddt) ? (new Date(enddt.getFullYear(), enddt.getMonth() , enddt.getDate(), endHour + (endPm ? 12 : 0), endMinutes)).toLocaleTimeString(Qt.locale(), "HH:mm"): "00:00"
                    enabled: !allDaySelector.checked && (root.enddt != undefined && !isNaN(root.enddt))

                    onClicked: {
                        endTimePickerSheet.hours = endTimeSelector.endHour
                        endTimePickerSheet.minutes = endTimeSelector.endMinutes
                        endTimePickerSheet.pm = endTimeSelector.endPm
                        endTimePickerSheet.open()
                    }

                    Connections {
                        target: endTimePickerSheet

                        onDatePicked: {
                            endTimeSelector.endHour = endTimePickerSheet.hours
                            endTimeSelector.endMinutes = endTimePickerSheet.minutes
                            endTimeSelector.endPm = endTimePickerSheet.pm
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
            Layout.maximumWidth: eventCard.width
            wrapMode: Text.WrapAnywhere
            text: eventData ? eventData.description : ""
            placeholderText: qsTr("Description")
        }
    }

    actions {

        left: Kirigami.Action {
            id: cancelAction

            text: qsTr("Cancel")
            icon.name : "dialog-cancel"

            onTriggered: editcompleted()
        }

        main: Kirigami.Action {
            id: info

            text: qsTr("Info")
            icon.name : "documentinfo"

            onTriggered: showPassiveNotification("Please save or cancel this event")
        }

        right: Kirigami.Action {
            id: saveAction

            text: qsTr("Save")
            icon.name : "dialog-ok"

            onTriggered: {
                var validation = validate();

                if(validation.success) {
                    console.log("Saving event, root.startdt:" + startdt);
                    var controller = eventController.createObject(parent, {calendar: root.calendar});
                    controller.vevent = { "uid" : root.uid, "startDate": root.startdt, "summary": root.summary, "description": root.description, "startHour": root.startHour + (root.startPm ? 12 : 0), "startMinute": root.startMinute, "allDay": root.allDay, "location": root.location, "endDate": (root.allDay ? root.startdt : root.enddt), "endHour": root.endHour + (root.endPm ? 12 : 0), "endMinute": root.endMinute };
                    controller.addEdit();
                    editcompleted();
                }
                else {
                    showPassiveNotification(validation.reason);
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

    DatePickerSheet {
        id: endDatePickerSheet
    }

    Component {
        id: eventController

        Calindori.EventController {
        }
    }
}
