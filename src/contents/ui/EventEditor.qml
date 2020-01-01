
/*
 *   Copyright 2019 Dimitris Kardarakos <dimkard@posteo.net>
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

    property string uid
    property alias summary: summary.text
    property alias description: description.text
    property alias startDt: startDateSelector.selectorDate
    property alias startHour: startTimeSelector.startHour
    property alias startMinute: startTimeSelector.startMinutes
    property alias startPm: startTimeSelector.startPm
    property alias allDay: allDaySelector.checked
    property alias location: location.text
    property var calendar
    property var eventData
    property alias endDt: endDateSelector.selectorDate
    property alias endHour: endTimeSelector.endHour
    property alias endMinute: endTimeSelector.endMinutes
    property alias endPm: endTimeSelector.endPm
    property alias repeatType: repeatSelector.repeatType
    property alias repeatEvery: repeatSelector.repeatEvery
    property alias repeatStopAfter: repeatSelector.stopAfter

    signal editcompleted

    /**
     * Function taht checks that the user input is valid
     *
     * Returns an object with success status and reason
     */
    function validate()
    {
        var result = { success: false, reason: "" };

        var endDtTime = new Date(root.endDt.getFullYear(), root.endDt.getMonth(), root.endDt.getDate(), root.endHour + (root.endPm ? 12 : 0), root.endMinute);

        var startDtTime = new Date(root.startDt.getFullYear(), root.startDt.getMonth(), root.startDt.getDate(), root.startHour + (root.startPm ? 12 : 0), root.startMinute);

        if(!(root.allDay) && (endDtTime < startDtTime)) {
            result.reason = "End date time should be after start date time";
            return result;
        }

        result.success = true;
        return result;
    }

    title: uid == "" ? i18n("Add event") : i18n("Edit event")

    ColumnLayout {

        anchors.centerIn: parent

        Kirigami.FormLayout {
            id: eventCard

            enabled: !root.completed

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
                text: eventData ? eventData.summary : ""

            }

            RowLayout {
                Kirigami.FormData.label: i18n("Start:")
                spacing: 0

                DateSelectorButton {
                    id: startDateSelector
                }

                Controls2.ToolButton {
                    id: startTimeSelector

                    property int startHour:  root.eventData ? root.eventData.dtstart.toLocaleTimeString(Qt.locale(), "hh") % 12 : 0
                    property int startMinutes: root.eventData ? root.eventData.dtstart.toLocaleTimeString(Qt.locale(), "mm") : 0
                    property bool startPm: (root.eventData && root.eventData.dtstart.toLocaleTimeString(Qt.locale("en_US"), "AP")  == "PM") ? true : false

                    text: (new Date(root.startDt.getFullYear(), root.startDt.getMonth() , root.startDt.getDate(), startHour + (startPm ? 12 : 0), startMinutes)).toLocaleTimeString(Qt.locale(), "HH:mm")
                    enabled: !allDaySelector.checked

                    onClicked: {
                        startTimePickerSheet.hours = startTimeSelector.startHour;
                        startTimePickerSheet.minutes = startTimeSelector.startMinutes;
                        startTimePickerSheet.pm = startTimeSelector.startPm;
                        startTimePickerSheet.open();
                    }
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("End:")
                spacing: 0

                DateSelectorButton {
                    id: endDateSelector

                    enabled: !allDaySelector.checked

                    Component.onCompleted: selectorDate = root.eventData ? root.eventData.dtend : root.startDt // Do not bind, just initialize
                }

                Controls2.ToolButton {
                    id: endTimeSelector

                    property int endHour: root.eventData ? root.eventData.dtend.toLocaleTimeString(Qt.locale(), "hh") % 12 : 0
                    property int endMinutes: root.eventData ? root.eventData.dtend.toLocaleTimeString(Qt.locale(), "mm") : 0
                    property bool endPm: (root.eventData && root.eventData.dtend.toLocaleTimeString(Qt.locale("en_US"), "AP")  == "PM") ? true : false

                    text: !isNaN(endDt) ? (new Date(endDt.getFullYear(), endDt.getMonth() , endDt.getDate(), endHour + (endPm ? 12 : 0), endMinutes)).toLocaleTimeString(Qt.locale(), "HH:mm"): "00:00"
                    enabled: !allDaySelector.checked && (root.endDt != undefined && !isNaN(root.endDt))

                    onClicked: {
                        endTimePickerSheet.hours = endTimeSelector.endHour;
                        endTimePickerSheet.minutes = endTimeSelector.endMinutes;
                        endTimePickerSheet.pm = endTimeSelector.endPm;
                        endTimePickerSheet.open();
                    }
                }
            }

            Controls2.CheckBox {
                id: allDaySelector

                enabled: !isNaN(root.startDt)
                checked: eventData ? eventData.allday: false
                text: i18n("All day")
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
            }

            Controls2.TextField {
                id: location

                Layout.fillWidth: true
                Kirigami.FormData.label: i18n("Location:")
                text: eventData ? eventData.location : ""
            }

            Controls2.ToolButton {
                id: repeatSelector

                property int repeatType: eventData != null && eventData.isRepeating ? eventData.repeatType : _repeatModel.noRepeat
                property int repeatEvery: eventData != null && eventData.isRepeating ? eventData.repeatEvery : 1
                property string repeatDescription: _repeatModel.periodDecription(repeatType)
                property int stopAfter: eventData != null && eventData.isRepeating ? eventData.repeatStopAfter: -1

                text: _repeatModel.repeatDescription(repeatType, repeatEvery, stopAfter)
                Kirigami.FormData.label: i18n("Repeat:")

                onClicked: recurPickerSheet.init(repeatType, repeatEvery, stopAfter )
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
            placeholderText: i18n("Description")
        }

        RowLayout {
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

            model: incidenceAlarmsModel

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
                        onTriggered: incidenceAlarmsModel.removeAlarm(model.index)
                    }
                ]
            }
        }

    }

    actions {

        left: Kirigami.Action {
            id: cancelAction

            text: i18n("Cancel")
            icon.name : "dialog-cancel"
            shortcut: "Esc"

            onTriggered: editcompleted()
        }

        main: Kirigami.Action {
            text: i18n("Save")
            icon.name: "dialog-ok"
            enabled: summary.text

            onTriggered: {
                var validation = validate();

                if(validation.success) {
                    console.log("Saving event, root.startDt:" + startDt);
                    var vevent = { "uid" : root.uid, "startDate": root.startDt, "summary": root.summary, "description": root.description, "startHour": root.startHour + (root.startPm ? 12 : 0), "startMinute": root.startMinute, "allDay": root.allDay, "location": root.location, "endDate": (root.allDay ? root.startDt : root.endDt), "endHour": root.endHour + (root.endPm ? 12 : 0), "endMinute": root.endMinute, "alarms": incidenceAlarmsModel.alarms(), "periodType": root.repeatType, "repeatEvery": root.repeatEvery, "stopAfter": root.repeatStopAfter};

                    _eventController.addEdit(root.calendar, vevent);
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

        onDatePicked: {
            startTimeSelector.startHour = startTimePickerSheet.hours;
            startTimeSelector.startMinutes = startTimePickerSheet.minutes;
            startTimeSelector.startPm = startTimePickerSheet.pm;
        }
    }

    TimePickerSheet {
        id: endTimePickerSheet

        onDatePicked: {
            endTimeSelector.endHour = endTimePickerSheet.hours;
            endTimeSelector.endMinutes = endTimePickerSheet.minutes;
            endTimeSelector.endPm = endTimePickerSheet.pm;
        }
    }

    Calindori.IncidenceAlarmsModel {

        id: incidenceAlarmsModel

        alarmProperties: { "calendar" : root.calendar, "uid": root.uid }
    }

    RecurrencePickerSheet {
        id: recurPickerSheet

        onRecurrencePicked: {
            repeatSelector.repeatType = recurPickerSheet.selectedRepeatType;
            repeatSelector.repeatEvery = recurPickerSheet.selectedRepeatEvery
            repeatSelector.stopAfter = recurPickerSheet.selectedStopAfter;
        }
    }

    ReminderEditor {
        id: reminderEditor

        onOffsetSelected: incidenceAlarmsModel.addAlarm(offset)
    }
}
