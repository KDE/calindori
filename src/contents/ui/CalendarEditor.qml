/*
 * SPDX-FileCopyrightText: 2018 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.12 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.Page {
    id: root

    enum Mode {
        Create,
        AddExisting,
        Edit
    }

    property var loadedCalendar
    property alias calendarName: nameInput.text
    property alias ownerName: ownerNameInput.text
    property alias ownerEmail: ownerEmail.text
    property int mode: CalendarEditor.Mode.Create
    property url calendarFile

    signal calendarEditorSaved
    signal calendarEditorCancelled

    title: mode === CalendarEditor.Mode.Edit ? calendarName : i18n("New calendar")

    function addLocalCalendarCfgEntry() {
        var insertResult = _calindoriConfig.addInternalCalendar(root.calendarName, root.ownerName, root.ownerEmail);

        if(!(insertResult.success)) {
            validationFooter.text = insertResult.reason;
            validationFooter.visible = true;
            return;
        }

        validationFooter.visible = false;
        calendarEditorSaved();
    }

    function addSharedCalendarCfgEntry() {
        var addSharedResult = _calindoriConfig.addExternalCalendar(root.calendarName, root.ownerName, root.ownerEmail,  root.calendarFile);

        if(!(addSharedResult.success)) {
            validationFooter.text = addSharedResult.reason;
            validationFooter.visible = true;
            return;
        }

        _calindoriConfig.setOwnerInfo(root.calendarName, root.ownerName, root.ownerEmail);

        validationFooter.visible = false;
        calendarEditorSaved();
    }

    Kirigami.FormLayout {
        id: calendarInputPage

        anchors.centerIn: parent

        Controls2.TextField {
            id: nameInput

            visible: root.mode !== CalendarEditor.Mode.Edit
            Kirigami.FormData.label: i18n("Calendar:")
        }

        Controls2.Label {
            id: fileName

            property bool showFileName: (root.mode == CalendarEditor.Mode.AddExisting) && (root.calendarFile != "")

            visible: showFileName
            Kirigami.FormData.label: i18n("File:")
            text: showFileName ? Calindori.CalendarController.fileNameFromUrl(root.calendarFile) : ""
        }

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Owner")
            Kirigami.FormData.isSection: true
        }

        Controls2.TextField {
            id: ownerNameInput

            Kirigami.FormData.label: i18n("Name:")
        }

        Controls2.TextField {
            id: ownerEmail

            Kirigami.FormData.label: i18n("Email:")
        }

    }

    actions {

        left: Kirigami.Action {
            id: cancelAction

            text: i18n("Cancel")
            icon.name : "dialog-cancel"

            onTriggered: {
                calendarEditorCancelled();
            }
        }

        main: Kirigami.Action {
            id: saveAction

            text: i18n("Save")
            enabled: (mode == CalendarEditor.Mode.AddExisting) ? (root.calendarName != "" && root.calendarFile != "") : (root.calendarName != "")

            icon.name : "dialog-ok"

            onTriggered: {
                if ((mode === CalendarEditor.Mode.AddExisting) || (mode === CalendarEditor.Mode.Create))  {
                    var canAddResult = _calindoriConfig.canAddCalendar(root.calendarName);

                    if(canAddResult && !(canAddResult.success)) {
                        validationFooter.text = canAddResult.reason;
                        validationFooter.visible = true;
                        return;
                    }
                }

                switch(mode) {
                    case CalendarEditor.Mode.AddExisting:
                        addSharedCalendarCfgEntry();
                        break;
                    case CalendarEditor.Mode.Create:
                        addLocalCalendarCfgEntry();
                        break;
                    case CalendarEditor.Mode.Edit:
                        _calindoriConfig.setOwnerInfo(root.calendarName, root.ownerName, root.ownerEmail);
                        calendarEditorSaved();
                        break;
                    default:
                        return;
                }
            }
        }

        right: Kirigami.Action {
            id: addFile

            visible: root.mode == CalendarEditor.Mode.AddExisting
            text: i18n("Add")
            icon.name: "list-add"

            onTriggered: fileChooser.open()
        }

    }

    footer: Kirigami.InlineMessage {
        id: validationFooter

        showCloseButton: true
        type: Kirigami.MessageType.Warning
        visible: false
    }

    FileChooser {
        id: fileChooser

        onAccepted: root.calendarFile = fileUrl
    }

}
