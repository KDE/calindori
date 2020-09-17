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

Kirigami.Page {
    id: root

    property string uid
    property alias summary: summary.text
    property alias description: description.text
    property alias startDt: startDateSelector.selectorDate
    property alias startHour: startTimeSelector.selectorHour
    property alias startMinute: startTimeSelector.selectorMinutes
    property alias startPm: startTimeSelector.selectorPm
    property alias allDay: allDaySelector.checked
    property alias location: location.text
    property var calendar
    property var incidenceData
    property alias endDt: endDateSelector.selectorDate
    property alias endHour: endTimeSelector.selectorHour
    property alias endMinute: endTimeSelector.selectorMinutes
    property alias endPm: endTimeSelector.selectorPm
    property alias repeatType: repeatSelector.repeatType
    property alias repeatEvery: repeatSelector.repeatEvery
    property alias repeatStopAfter: repeatSelector.stopAfter

    signal editcompleted(var vevent)

    Component.onCompleted: {
        if(incidenceData == null && _calindoriConfig.alwaysRemind)
        {
            incidenceAlarmsModel.addAlarm(_calindoriConfig.preEventRemindTime * 60)
        }
    }

    title: uid == "" ? i18n("New event") : root.summary

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
                text: incidenceData ? incidenceData.summary : ""

            }

            RowLayout {
                Kirigami.FormData.label: i18n("Start:")
                spacing: 0

                DateSelectorButton {
                    id: startDateSelector

                    selectorTitle: i18n("Start Date")
                }

                TimeSelectorButton {
                    id: startTimeSelector

                    selectorTitle: i18n("Start Time")
                    selectorDate: root.startDt
                    selectorHour: (root.incidenceData ? root.incidenceData.dtstart.getHours() : root.startDt.getHours() ) % 12
                    selectorMinutes: root.incidenceData ? root.incidenceData.dtstart.getMinutes() : root.startDt.getMinutes()
                    selectorPm: root.incidenceData ? (root.incidenceData.dtstart.getHours() >=12) : (root.startDt.getHours() >=12)
                    enabled: !allDaySelector.checked
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("End:")
                spacing: 0

                DateSelectorButton {
                    id: endDateSelector

                    enabled: !allDaySelector.checked
                    selectorTitle: i18n("End Date")

                    Component.onCompleted: {
                        var newDt;

                        if(root.incidenceData) {
                            newDt = root.incidenceData.dtend;
                        }
                        else {
                            newDt= root.startDt;
                            newDt.setMinutes(newDt.getMinutes() + _calindoriConfig.eventsDuration);
                            newDt.setSeconds(0);
                        }

                        selectorDate = newDt;
                    }
                }

                TimeSelectorButton {
                    id: endTimeSelector

                    selectorTitle: i18n("End Time")
                    selectorDate: root.endDt
                    selectorHour: root.endDt.getHours() % 12
                    selectorMinutes: root.endDt.getMinutes()
                    selectorPm: (root.endDt.getHours() >=12)
                    enabled: !allDaySelector.checked && (root.endDt != undefined && !isNaN(root.endDt))
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

            Controls2.ToolButton {
                id: repeatSelector

                property int repeatType: incidenceData != null && incidenceData.isRepeating ? incidenceData.repeatType : _repeatModel.noRepeat
                property int repeatEvery: incidenceData != null && incidenceData.isRepeating ? incidenceData.repeatEvery : 1
                property string repeatDescription: _repeatModel.periodDecription(repeatType)
                property int stopAfter: incidenceData != null && incidenceData.isRepeating ? incidenceData.repeatStopAfter: -1

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
            text: incidenceData ? incidenceData.description : ""
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

            onTriggered: editcompleted(null)
        }

        main: Kirigami.Action {
            text: i18n("Save")
            icon.name: "dialog-ok"
            enabled: summary.text

            onTriggered: {
                var vevent = { "uid" : root.uid, "startDate": root.startDt, "summary": root.summary, "description": root.description, "startHour": root.startHour + (root.startPm ? 12 : 0), "startMinute": root.startMinute, "allDay": root.allDay, "location": root.location, "endDate": root.endDt, "endHour": root.endHour + (root.endPm ? 12 : 0), "endMinute": root.endMinute, "alarms": incidenceAlarmsModel.alarms(), "periodType": root.repeatType, "repeatEvery": root.repeatEvery, "stopAfter": root.repeatStopAfter};

                var validation = _eventController.validate(vevent);

                if(validation.success) {
                    _eventController.addEdit(root.calendar, vevent);
                    editcompleted(vevent);
                }
                else {
                    showPassiveNotification(validation.reason);
                }
            }
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
