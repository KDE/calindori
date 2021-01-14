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

    property alias startDt: startDateSelector.selectorDate
    property string uid
    property alias summary: summary.text
    property alias description: incidenceEditor.description
    property alias startHour: startTimeSelector.selectorHour
    property alias startMinute: startTimeSelector.selectorMinutes
    property alias startPm: startTimeSelector.selectorPm
    property alias dueDt: dueDateSelector.selectorDate
    property alias dueHour: dueDtTimeSelector.selectorHour
    property alias dueMinute: dueDtTimeSelector.selectorMinutes
    property alias duePm: dueDtTimeSelector.selectorPm
    property alias allDay: allDaySelector.checked
    property alias location: incidenceEditor.location
    property alias completed: incidenceEditor.completed
    property var calendar
    property var incidenceData

    signal editcompleted

    title: uid == "" ? i18n("New task") : root.summary

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Kirigami.Units.smallSpacing

        Kirigami.FormLayout {
            id: basicInfo

            Layout.fillWidth: true

            Controls2.TextField {
                id: summary

                enabled: !root.completed
                text: incidenceData ? incidenceData.summary : ""
                Kirigami.FormData.label: i18n("Summary:")
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Start:")
                spacing: 0
                enabled: !root.completed

                DateSelectorButton {
                    id: startDateSelector

                    selectorTitle: i18n("Start Date")
                }

                TimeSelectorButton {
                    id: startTimeSelector

                    property bool validSelectedDt: startDateSelector.selectorDate != undefined && !isNaN(startDateSelector.selectorDate)

                    selectorDate: startDateSelector.selectorDate
                    selectorTitle: i18n("Start Time")
                    selectorHour: validSelectedDt ? selectorDate.getHours() % 12 : 0
                    selectorMinutes: validSelectedDt ? selectorDate.getMinutes() : 0
                    selectorPm: (validSelectedDt && (selectorDate.toLocaleTimeString(Qt.locale("en_US"), "AP") == "PM")) ? true : false

                    enabled: !allDaySelector.checked && validSelectedDt
                }

                Controls2.ToolButton {
                    id: clearStartDt

                    icon.name: "edit-clear-all"

                    onClicked: {
                        startDateSelector.selectorDate = new Date("invalid");
                        incidenceAlarmsModel.removeAll();
                    }
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Due:")
                spacing: 0
                enabled: !root.completed

                DateSelectorButton {
                    id: dueDateSelector

                    selectorTitle: i18n("Due Date")

                    Component.onCompleted: {
                        // Do not bind, just initialize
                        if (root.incidenceData && root.incidenceData.validDueDt) {
                            selectorDate = root.incidenceData.due;
                        }
                        else if (root.incidenceData == undefined && (root.startDt != undefined) && !isNaN(root.startDt)) {
                            var t = root.startDt;
                            t.setHours(root.startHour + (startPm ? 12 : 0));
                            t.setMinutes(root.startMinute);
                            t.setSeconds(0);
                            selectorDate = t;
                        }
                        else {
                            selectorDate = new Date("invalid");
                        }
                    }
                }

                TimeSelectorButton {
                    id: dueDtTimeSelector

                    property bool validSelectedDt: dueDateSelector.selectorDate != undefined && !isNaN(dueDateSelector.selectorDate)

                    selectorDate: dueDateSelector.selectorDate
                    selectorTitle: i18n("Due Time")
                    selectorHour: validSelectedDt ? selectorDate.getHours() % 12 : 0
                    selectorMinutes: validSelectedDt ? selectorDate.getMinutes() : 0
                    selectorPm: validSelectedDt && (selectorDate.toLocaleTimeString(Qt.locale("en_US"), "AP") == "PM") ? true : false

                    enabled: !allDaySelector.checked && validSelectedDt
                }

                Controls2.ToolButton {
                    id: clearDueDt

                    icon.name: "edit-clear-all"

                    onClicked: dueDateSelector.selectorDate = new Date("invalid")
                }
            }

            Controls2.CheckBox {
                id: allDaySelector

                enabled: (!isNaN(root.startDt) || !isNaN(root.dueDt)) && !root.completed
                checked: incidenceData ? incidenceData.allday: false
                Kirigami.FormData.label: i18n("All day:")
            }

            Item {
                height: Kirigami.Units.largeSpacing
            }
        }

        Controls2.TabBar {
            id: bar

            Controls2.TabButton {
                text: i18n("Details")
            }

            Controls2.TabButton {
                text: i18n("Reminders")
            }
        }

        StackLayout {
            currentIndex: bar.currentIndex

            IncidenceEditor {
                id: incidenceEditor

                calendar: root.calendar
                incidenceData: root.incidenceData
                incidenceType: 1
            }

            Reminders {
                enabled: root.startDt !== undefined && !isNaN(root.startDt) && !root.completed

                alarmsModel: incidenceAlarmsModel
            }
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
                var vtodo = { "uid": root.uid, "summary":root.summary, "startDate": root.startDt , "startHour": root.startHour + (root.startPm ? 12 : 0), "startMinute": root.startMinute, "allDay": root.allDay, "description":  root.description, "location": root.location, "completed": root.completed, "dueDate": root.dueDt, "dueHour": root.dueHour + (root.duePm ? 12 : 0), "dueMinute": root.dueMinute, "alarms": incidenceAlarmsModel.alarms() };

                var validation = Calindori.CalendarController.validateTodo(vtodo);

                if(validation.success) {
                    Calindori.CalendarController.upsertTodo(root.calendar, vtodo);
                    editcompleted();
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

}
