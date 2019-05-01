
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
    property alias allDay: allDaySelector.checked
    property string location: "" //location.text
    property alias completed: completed.checked
    property var localCalendar
    property var todoData
    property alias timePicker: timePickerSheet

    signal taskeditcompleted

    title: qsTr("Task")

    ColumnLayout {

        anchors.centerIn: parent

        Controls2.Label {
            visible: root.startdt != undefined && !isNaN(root.startdt)
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.2
            text: todoData && !isNaN(todoData.startDate) ? todoData.startDate.toLocaleDateString(Qt.locale()) : (!isNaN(root.startdt) ? root.startdt.toLocaleDateString(Qt.locale()) : "")
        }

        Kirigami.FormLayout {
            id: todoCard

            enabled: !root.completed

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
            }

            Controls2.Label {
                id: localCalendarName

                Kirigami.FormData.label: qsTr("Calendar:")
                Layout.fillWidth: true
                text: root.localCalendar.name
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

                    property int startHour: timePickerSheet.hours + (timePickerSheet.pm ?  12 : 0)
                    property int startMinutes: timePickerSheet.minutes
                    property date startTime: root.startdt

                    text: !isNaN(startdt) ? (new Date(startdt.getFullYear(), startdt.getMonth() , startdt.getDate(), startHour, startMinutes)).toLocaleTimeString(Qt.locale(), "hh:mm"): "00:00"

                    enabled: !allDaySelector.checked

                    onClicked: timePickerSheet.open()
                }
            }

            Controls2.CheckBox {
                id: allDaySelector

                enabled: !isNaN(root.startdt)
                checked: todoData ? todoData.allday: false
                text: qsTr("All day")
            }

//             Kirigami.Separator {
//                 Kirigami.FormData.isSection: true
//             }
// 
//             Controls2.TextField {
//                 id: location
// 
//                 Layout.fillWidth: true
//                 Kirigami.FormData.label: qsTr("Location:")
//                 text: todoData ? todoData.location : ""
//             }

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
            wrapMode: Controls2.TextArea.WordWrap
            text: todoData ? todoData.description : ""
            placeholderText:  qsTr("Description")
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls2.CheckBox {
            id: completed

            text: qsTr("Completed")
            checked: todoData ? todoData.complete: false
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
                    root.localCalendar.addEditTask(root.uid, root.startdt, root.summary, root.description, root.startHour, root.startMinute, root.allDay, root.location, root.completed); //TODO: Pass a Todo object
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

    Kirigami.OverlaySheet {
        id: timePickerSheet

        property int hours: todoData ? todoData.startDate.toLocaleTimeString(Qt.locale(), "hh") % 12 : 0
        property int minutes: todoData ? todoData.startDate.toLocaleTimeString(Qt.locale(), "mm") : 0
        property bool pm: (todoData && todoData.startDate.toLocaleTimeString(Qt.locale(), "hh") > 12) ? true : false

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
                    timePickerSheet.close()
                }
            }
            Controls2.ToolButton {
                text: qsTr("Cancel")
                onClicked: {
                    timePicker.hours = timePickerSheet.hours
                    timePicker.minutes = timePickerSheet.minutes
                    timePickerSheet.close()
                }
            }
        }
    }

}
