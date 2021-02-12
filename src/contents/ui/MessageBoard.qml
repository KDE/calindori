/*
 * SPDX-FileCopyrightText: 2021 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import org.kde.kirigami 2.6 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.InlineMessage {
    id: root

    property var activeCalendar
    property string targetCalendarName
    property var targetFolder
    property int footerMode: MessageBoard.FooterMode.NoDisplay

    enum FooterMode {
        StartImport,
        EndImportSuccess,
        EndImportFailure,
        EndExportSuccess,
        EndExportFailure,
        NoDisplay
    }

    actions: [
        Kirigami.Action {
            id: proceedAction
            icon.name: "dialog-ok"
            text: i18n("Proceed")

            onTriggered: {
                root.footerMode = MessageBoard.FooterMode.NoDisplay;
                if( (targetCalendarName === "") || (activeCalendar && (activeCalendar.name === root.targetCalendarName)) ) {
                    Calindori.CalendarController.importFromBuffer(activeCalendar);
                }
                else {
                    Calindori.CalendarController.importFromBuffer(targetCalendarName);
                }
            }
        },

        Kirigami.Action {
            id: cancelAction
            icon.name: "dialog-cancel"
            text: i18n("Cancel")

            onTriggered: {
                root.footerMode = MessageBoard.FooterMode.NoDisplay;
                Calindori.CalendarController.abortImporting();
            }
        },

        Kirigami.Action {
            id: openFolderAction
            text: i18n("Open folder")
            icon.name: "folder-open"

            onTriggered: {
                root.footerMode = MessageBoard.FooterMode.NoDisplay;
                Qt.openUrlExternally(root.targetFolder);
            }
        }
    ]

    states: [
        State {
            when: root.footerMode === MessageBoard.FooterMode.StartImport
            PropertyChanges { target: root; visible: true }
            PropertyChanges { target: root; type: Kirigami.MessageType.Information }
            PropertyChanges { target: root; showCloseButton: false }
            PropertyChanges { target: proceedAction; visible: true }
            PropertyChanges { target: cancelAction; visible: true }
            PropertyChanges { target: openFolderAction; visible: false }
        },

        State {
            when: root.footerMode === MessageBoard.FooterMode.EndImportSuccess
            PropertyChanges { target: root; visible: true }
            PropertyChanges { target: root; type: Kirigami.MessageType.Positive }
            PropertyChanges { target: root; showCloseButton: true }
            PropertyChanges { target: proceedAction; visible: false }
            PropertyChanges { target: cancelAction; visible: false }
            PropertyChanges { target: openFolderAction; visible: false }
        },

        State {
            when: root.footerMode === MessageBoard.FooterMode.EndImportFailure
            PropertyChanges { target: root; visible: true }
            PropertyChanges { target: root; type: Kirigami.MessageType.Warning }
            PropertyChanges { target: root; showCloseButton: true }
            PropertyChanges { target: proceedAction; visible: false }
            PropertyChanges { target: cancelAction; visible: false }
            PropertyChanges { target: openFolderAction; visible: false }
        },

        State {
            when: root.footerMode === MessageBoard.FooterMode.EndExportSuccess
            PropertyChanges { target: root; visible: true }
            PropertyChanges { target: root; type: Kirigami.MessageType.Positive }
            PropertyChanges { target: root; showCloseButton: true }
            PropertyChanges { target: proceedAction; visible: false }
            PropertyChanges { target: cancelAction; visible: false }
            PropertyChanges { target: openFolderAction; visible: true }
        },

        State {
            when: root.footerMode === MessageBoard.FooterMode.EndExportFailure
            PropertyChanges { target: root; visible: true }
            PropertyChanges { target: root; type: Kirigami.MessageType.Warning }
            PropertyChanges { target: root; showCloseButton: true }
            PropertyChanges { target: proceedAction; visible: false }
            PropertyChanges { target: cancelAction; visible: false }
            PropertyChanges { target: openFolderAction; visible: false }
        },

        State {
            when: root.footerMode === MessageBoard.FooterMode.NoDisplay
            PropertyChanges { target: root; visible: false }
            PropertyChanges { target: proceedAction; visible: false }
            PropertyChanges { target: cancelAction; visible: false }
            PropertyChanges { target: openFolderAction; visible: false }
        }

    ]
}

