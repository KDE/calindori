/*
 * SPDX-FileCopyrightText: 2018 Dimitris Kardarakos <dimkard@posteo.net>
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

    property alias calendarName: nameInput.text
    property alias activeCalendar: isactive.checked
    property string mode: "add"
    property url fileToImport

    signal calendarAdded
    signal calendarAddCanceled

    title: i18n("New calendar")

    function importCalendar() {
        if(root.fileToImport == "") {
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

            Kirigami.FormData.label: i18n("Name:")
        }

        Controls2.CheckBox {
            id: isactive

            Kirigami.FormData.label: i18n("Active:")
        }

        Controls2.Label {
            id: fileName

            visible: root.mode == "import" && root.fileToImport != ""
            Kirigami.FormData.label: i18n("File:")
            text: (root.mode == "import" && root.fileToImport != "") ? calendarController.fileNameFromUrl(root.fileToImport) : ""
        }
    }

    actions {

        left: Kirigami.Action {
            id: cancelAction

            text: i18n("Cancel")
            icon.name : "dialog-cancel"

            onTriggered: {
                calendarAddCanceled();
            }
        }

        main: Kirigami.Action {
            id: saveAction

            text: i18n("Save")
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

        right: Kirigami.Action {
            id: addFile

            visible: root.mode == "import"
            text: i18n("Import")
            icon.name: "list-add"

            onTriggered: fileChooser.open()
        }

    }

    FileChooser {
        id: fileChooser

        onAccepted: root.fileToImport = fileUrl
    }

    Calindori.LocalCalendar {
        id: calendarController
    }

}
