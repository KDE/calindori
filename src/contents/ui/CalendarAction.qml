/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import org.kde.kirigami 2.0 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.Action {
    id: root

    property bool isCalendar: true
    property alias calendarName: root.text
    property var loadedCalendar
    property bool activeCalendar: Calindori.CalindoriConfig !== null ? (Calindori.CalindoriConfig.activeCalendar === root.calendarName) : false
    property var messageFooter

    iconName: activeCalendar ? "object-select-symbolic" : ""

    signal deleteCalendar

    Kirigami.Action {
        text: i18n("Activate")
        iconName: "dialog-ok"
        visible: !root.activeCalendar

        onTriggered: {
            Calindori.CalindoriConfig.activeCalendar = root.calendarName;
            popExtraLayers();
            showPassiveNotification(i18n("Calendar %1 has been activated", root.calendarName));
        }
    }

    Kirigami.Action {
        text: i18n("Delete")
        iconName: "delete"
        visible: !Calindori.CalindoriConfig.isExternal(root.calendarName) && !root.activeCalendar
        onTriggered: {
            deleteSheet.calendarName = root.calendarName;
            deleteSheet.open();
        }
    }

    Kirigami.Action {
        text: i18n("Remove")
        iconName: "remove"
        visible: Calindori.CalindoriConfig.isExternal(root.calendarName) && !root.activeCalendar

        onTriggered: Calindori.CalindoriConfig.removeCalendar(root.calendarName);
    }

    Kirigami.Action {
        text: i18n("Edit")
        iconName: "edit-entry"

        onTriggered: pageStack.layers.push(editor)
    }

    Kirigami.Action {
        id: calendarImportAction

        text: i18n("Import")
        iconName: "document-import"

        onTriggered: {
            messageFooter.targetCalendarName = root.calendarName;
            fileChooser.open();
        }
    }

    Kirigami.Action {
        text: i18n("Export")
        iconName: "document-export"

        onTriggered: {
            var exportResult = Calindori.CalendarController.exportData(root.calendarName);
            messageFooter.text = exportResult.reason;

            if (!(exportResult.success)) {
                messageFooter.footerMode = MessageBoard.FooterMode.EndExportFailure;
                return;
            }

            messageFooter.targetFolder = exportResult.targetFolder;
            messageFooter.footerMode = MessageBoard.FooterMode.EndExportSuccess;
        }
    }

    ConfirmationSheet {
        id: deleteSheet

        property string calendarName
        message: i18n("All data included in this calendar will be deleted. Proceed with deletion?")

        operation: function() {
            var toRemoveCalendarComponent = Qt.createQmlObject("import org.kde.calindori 0.1 as Calindori; Calindori.LocalCalendar { name: \"" + calendarName + "\"}",deleteSheet);
            toRemoveCalendarComponent.deleteCalendar();
            Calindori.CalindoriConfig.removeCalendar(calendarName);
        }
    }

    Component {
        id: editor

        CalendarEditor {
            mode: CalendarEditor.Mode.Edit
            calendarName: root.calendarName
            loadedCalendar: root.loadedCalendar
            ownerName: Calindori.CalindoriConfig.ownerName(root.calendarName)
            ownerEmail: Calindori.CalindoriConfig.ownerEmail(root.calendarName)

            onCalendarEditorCancelled: pageStack.layers.pop()
            onCalendarEditorSaved: {
                pageStack.layers.pop();
                if(root.loadedCalendar && (root.loadedCalendar.name === root.calendarName)) {
                    root.loadedCalendar.ownerName = ownerName;
                    root.loadedCalendar.ownerEmail = ownerEmail;
                }
            }
        }
    }

    FileChooser {
        id: fileChooser

        onAccepted: Calindori.DataHandler.importFromUrl(fileUrl)
    }
}
