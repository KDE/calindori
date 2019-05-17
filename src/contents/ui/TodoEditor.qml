
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
    property alias completed: completed.checked
    property var calendar
    property var todoData

    signal taskeditcompleted

    title: qsTr("Task")

    ColumnLayout {

        anchors.centerIn: parent

        Controls2.Label {
            visible: root.startdt != undefined && !isNaN(root.startdt)
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.2
            text: todoData && !isNaN(todoData.dtstart) ? todoData.dtstart.toLocaleDateString(Qt.locale()) : (!isNaN(root.startdt) ? root.startdt.toLocaleDateString(Qt.locale()) : "")
        }

        Kirigami.FormLayout {
            id: todoCard

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
                text: todoData ? todoData.summary : ""

            }

            RowLayout {
                Kirigami.FormData.label: qsTr("Start time:")
                enabled: root.startdt != undefined && !isNaN(root.startdt)

                Controls2.ToolButton {
                    id: startTimeSelector

                    property int startHour : root.todoData ? root.todoData.dtstart.toLocaleTimeString(Qt.locale(), "hh") % 12 : 0
                    property int startMinutes: root.todoData ? root.todoData.dtstart.toLocaleTimeString(Qt.locale(), "mm") : 0
                    property bool startPm: (root.todoData && root.todoData.dtstart.toLocaleTimeString(Qt.locale("en_US"), "AP")  == "PM") ? true : false
                    property date startTime: root.startdt

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

            Controls2.CheckBox {
                id: allDaySelector

                enabled: !isNaN(root.startdt)
                checked: todoData ? todoData.allday: false
                text: qsTr("All day")
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
            }

            Controls2.TextField {
                id: location

                Layout.fillWidth: true
                Kirigami.FormData.label: qsTr("Location:")
                text: todoData ? todoData.location : ""
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
            text: todoData ? todoData.description : ""
            placeholderText:  qsTr("Description")
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls2.CheckBox {
            id: completed

            text: qsTr("Completed")
            checked: todoData ? todoData.completed: false
        }
    }

    actions {

        left: Kirigami.Action {
            id: cancelAction

            text: qsTr("Cancel")
            icon.name : "dialog-cancel"

            onTriggered: {
                taskeditcompleted();
            }
        }


        main: Kirigami.Action {
            id: info

            text: qsTr("Info")
            icon.name : "documentinfo"

            onTriggered: {
                showPassiveNotification("Please save or cancel this task");
            }
        }

        right: Kirigami.Action {
            id: saveAction

            text: qsTr("Save")
            icon.name : "dialog-ok"

            onTriggered: {
                if(summary.text) {
                    console.log("Saving task");
                    var controller = todoController.createObject(parent, { calendar: root.calendar });
                    controller.vtodo = { "uid": root.uid, "summary":root.summary, "startDate": root.startdt , "startHour": root.startHour + (root.startPm ? 12 : 0), "startMinute": root.startMinute, "allDay": root.allDay, "description":  root.description,"location":  root.location, "completed": root.completed};
                    controller.addEdit();
                    taskeditcompleted();
                }
                else {
                    showPassiveNotification("Summary should not be empty");
                }
            }
        }

        //TODO
//         contextualActions: [
//             Kirigami.Action {
//                 iconName:"editor"
//                 text: "Edit Start Date"
//
//                 onTriggered: showPassiveNotification("Edit start date")
//
//             }
//             ,
//             Kirigami.Action { //TODO: Do we needed it?
//                 iconName:"delete"
//                 text: "Clear Start Date"
//
//                 onTriggered: {
//                     root.startdt = new Date("No Date");
//                 }
//             }
//         ]
    }

    TimePickerSheet {
        id: startTimePickerSheet
    }

    Component {
        id: todoController

        Calindori.TodoController {}
    }

}
