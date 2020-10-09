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

    enum Mode {
        Create,
        AddExisting,
        Import
    }
    property alias calendarName: nameInput.text
    property alias activeCalendar: isactive.checked
    property int mode: CalendarEditor.Mode.Create
    property url calendarFile

    signal calendarAdded
    signal calendarAddCanceled

    title: i18n("New calendar")

    function importCalendar() {
        var importResult = calendarController.importCalendar(root.calendarName, root.calendarFile);

        if(!(importResult.success)) {
            showPassiveNotification(i18n("Calendar not imported. %1",importResult.reason));
            return;
        }

        addLocalCalendarCfgEntry();
    }

    function addLocalCalendarCfgEntry() {
        var insertResult = _calindoriConfig.addInternalCalendar(root.calendarName);

        if(!(insertResult.success)) {
            showPassiveNotification(insertResult.reason);
            return;
        }

        if(root.activeCalendar) {
            _calindoriConfig.activeCalendar = root.calendarName;
        }

        calendarAdded();
    }

    function addSharedCalendarCfgEntry() {
        var addSharedResult = _calindoriConfig.addExternalCalendar(root.calendarName, calendarFile);

        if(!(addSharedResult.success)) {
            showPassiveNotification(addSharedResult.reason);
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

            property bool showFileName: ( (root.mode == CalendarEditor.Mode.Import) || (root.mode == CalendarEditor.Mode.AddExisting)) && (root.calendarFile != "")

            visible: showFileName
            Kirigami.FormData.label: i18n("File:")
            text: showFileName ? calendarController.fileNameFromUrl(root.calendarFile) : ""
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
            enabled: ((mode == CalendarEditor.Mode.AddExisting) || (mode == CalendarEditor.Mode.Import)) ? (root.calendarName != "" && root.calendarFile != "") : (root.calendarName != "")

            icon.name : "dialog-ok"

            onTriggered: {
                var canAddResult = _calindoriConfig.canAddCalendar(root.calendarName);

                if(canAddResult && !(canAddResult.success)) {
                    showPassiveNotification(canAddResult.reason);
                    return;
                }

                switch(mode) {
                    case CalendarEditor.Mode.Import:
                        importCalendar();
                        break;
                    case CalendarEditor.Mode.AddExisting:
                        addSharedCalendarCfgEntry();
                        break;
                    case CalendarEditor.Mode.Create:
                        addLocalCalendarCfgEntry();
                        break;
                    default:
                        return;
                }
            }
        }

        right: Kirigami.Action {
            id: addFile

            visible: (root.mode == CalendarEditor.Mode.Import) || (root.mode == CalendarEditor.Mode.AddExisting)
            text: (root.mode == CalendarEditor.Mode.Import) ? i18n("Import") : i18n("Add")
            icon.name: "list-add"

            onTriggered: fileChooser.open()
        }

    }

    FileChooser {
        id: fileChooser

        onAccepted: root.calendarFile = fileUrl
    }

    Calindori.LocalCalendar {
        id: calendarController
    }

}
