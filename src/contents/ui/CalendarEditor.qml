/*
 * SPDX-FileCopyrightText: 2018 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.4 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.Page {
    id: root

    property alias calendarName: nameInput.text
    property alias activeCalendar: isactive.checked
    property string mode: "add"
    property alias fileToImport: importFilePath.text

    signal calendarAdded
    signal calendarAddCanceled

    title: qsTr("New calendar")

    function importCalendar() {
        if(root.fileToImport.text == "") {
            showPassiveNotification(i18n("Please import a calendar file"));
            return;
        }

        var canAddResult = _calindoriConfig.canAddCalendar(root.calendarName);

        if(!(canAddResult.success)) {
            showPassiveNotification(canAddResult.reason);
            return;
        }

        var importResult = calendarController.importCalendar(root.calendarName, root.fileToImport);

        if(!(importResult.success)) {
            showPassiveNotification(i18n("Calendar not imported. %1",importResult.reason));
            return;
        }

        addCalendarToConfig(false);
    }

    function addCalendarToConfig(validateEntry=true) {
        var canAddResult = validateEntry ? _calindoriConfig.canAddCalendar(root.calendarName) : null;

        if(canAddResult && !(canAddResult.success)) {
            showPassiveNotification(canAddResult.reason);
            return;
        }

        var insertResult = _calindoriConfig.addCalendar(root.calendarName);

        if(!(insertResult.success)) {
            showPassiveNotification(insertResult.reason);
            return;
        }

        if(root.activeCalendar) {
            _calindoriConfig.activeCalendar = root.calendarName;
        }

        calendarAdded();
    }

    Kirigami.FormLayout {
        id: calendarInputPage

        anchors.centerIn: parent

        Controls2.TextField {
            id: nameInput

            Kirigami.FormData.label: qsTr("Name:")
        }

        Controls2.CheckBox {
            id: isactive

            Kirigami.FormData.label: qsTr("Active:")
        }

        Controls2.TextField {
            id: importFilePath

            visible: (mode == "import")
            Kirigami.FormData.label: qsTr("File:")
        }
    }

    actions {

        left: Kirigami.Action {
            id: cancelAction

            text: qsTr("Cancel")
            icon.name : "dialog-cancel"

            onTriggered: {
                calendarAddCanceled();
            }
        }

        main: Kirigami.Action {
            id: info

            text: (mode == "import") ? qsTr("Import") : qsTr("Info")
            icon.name : (mode == "import") ? "list-add" : "documentinfo"

            onTriggered: {
                onClicked: (mode == "import") ? fileChooser.open() : showPassiveNotification("Please save or cancel the creation of the new calendar")
            }
        }

        right: Kirigami.Action {
            id: saveAction

            text: qsTr("Save")
            icon.name : "dialog-ok"

            onTriggered: {
                if(root.calendarName == "") {
                    showPassiveNotification("Please enter a calendar name");
                    return;
                }

                if(mode == "import") {
                    importCalendar();
                }
                else {
                    addCalendarToConfig();
                }
            }
        }
    }

    FileChooser {
        id: fileChooser

        onAccepted: root.fileToImport = fileUrl.toString().replace('qrc:','')
    }

    Calindori.LocalCalendar {
        id: calendarController
    }

}
