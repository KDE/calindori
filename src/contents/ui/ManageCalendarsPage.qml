/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import QtQml.Models 2.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.ScrollablePage {
    id: root
    
    property var applicationFooter
    property var calendarModel
    property bool isExternal: false
    
    mainAction: Kirigami.Action {
        text: root.isExternal ? i18n("Add") : i18n("Create")
        iconName: root.isExternal ? "resource-calendar-child-insert" : "resource-calendar-insert"
        onTriggered: {
            applicationWindow().pageStack.push(calendarEditor, 
                                               {mode: root.isExternal ? CalendarEditor.Mode.AddExisting : CalendarEditor.Mode.Create});
        }
    }
    
    ListView {
        id: listView
        model: calendarModel
        currentIndex: -1
        
        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            visible: listView.count === 0
            
            icon.name: "view-calendar"
            text: root.isExternal ? i18n("No external calendars found") : 
                                    i18n("No calendars found") 
            explanation: root.isExternal ? i18n("Import an existing calendar file.") : 
                                           i18n("Add a new calendar.")
            helpfulAction: root.mainAction
        }
        
        // create new calendar editor
        Component {
            id: calendarEditor

            CalendarEditor {
                loadedCalendar: root.calendar
                onCalendarEditorSaved: pageStack.pop()
                onCalendarEditorCancelled: pageStack.pop()
            }
        }
        
        // dialog that pops up for editing
        Kirigami.MenuDialog {
            id: modifyDialog
            property var calendarName: ""
            property bool calendarActive: Calindori.CalindoriConfig !== null ? (Calindori.CalindoriConfig.activeCalendar === calendarName) : false
            
            title: i18n("Modify " + calendarName)
            actions: [
                Kirigami.Action {
                    text: i18n("Activate")
                    iconName: "dialog-ok"
                    visible: !modifyDialog.calendarActive
                    
                    onTriggered: {
                        modifyDialog.close();
                        Calindori.CalindoriConfig.activeCalendar = modifyDialog.calendarName;
                        popExtraLayers();
                        showPassiveNotification(i18n("Calendar %1 has been activated", modifyDialog.calendarName));
                    }
                },
                
                Kirigami.Action {
                    text: i18n("Delete")
                    iconName: "entry-delete"
                    visible: !Calindori.CalindoriConfig.isExternal(modifyDialog.calendarName)
                    onTriggered: {
                        modifyDialog.close();
                        if (modifyDialog.calendarActive) {
                            showPassiveNotification(i18n("Calendar must not be active when being deleted."));
                        } else {
                            deleteSheet.calendarName = modifyDialog.calendarName;
                            deleteSheet.timer.restart();
                        }
                    }
                },
                
                Kirigami.Action {
                    text: i18n("Remove")
                    iconName: "edit-delete"
                    visible: Calindori.CalindoriConfig.isExternal(modifyDialog.calendarName)
                    onTriggered: {
                        modifyDialog.close();
                        if (modifyDialog.calendarActive) {
                            showPassiveNotification(i18n("Calendar must not be active when being deleted."));
                        } else {
                            Calindori.CalindoriConfig.removeCalendar(modifyDialog.calendarName);
                        }
                    }
                },
                
                Kirigami.Action {
                    text: i18n("Edit details")
                    iconName: "edit-entry"
                    onTriggered: {
                        modifyDialog.close();
                        applicationWindow().pageStack.push(editor, { calendarName: modifyDialog.calendarName });
                    }
                },
                
                Kirigami.Action {
                    text: i18n("Import calendar file")
                    iconName: "document-import"
                    onTriggered: {
                        modifyDialog.close();
                        root.applicationFooter.targetCalendarName = modifyDialog.calendarName;
                        fileChooser.open();
                    }
                },
                
                Kirigami.Action {
                    text: i18n("Export calendar to file")
                    iconName: "document-export"
                    onTriggered: {
                        modifyDialog.close();
                        var exportResult = Calindori.CalendarController.exportData(modifyDialog.calendarName);
                        root.applicationFooter.text = exportResult.reason;

                        if (!(exportResult.success)) {
                            root.applicationFooter.footerMode = MessageBoard.FooterMode.EndExportFailure;
                            return;
                        }

                        root.applicationFooter.targetFolder = exportResult.targetFolder;
                        root.applicationFooter.footerMode = MessageBoard.FooterMode.EndExportSuccess;
                    }
                }
            ]
        }
        
        // confirmation dialog for deletion        
        Kirigami.PromptDialog {
            id: deleteSheet
            property string calendarName

            title: i18n("Confirm")
            subtitle: i18n("All data included in this calendar will be deleted. Proceed with deletion?")

            standardButtons: Kirigami.Dialog.Yes | Kirigami.Dialog.No
            onAccepted: {
                var toRemoveCalendarComponent = Qt.createQmlObject("import org.kde.calindori 0.1 as Calindori; Calindori.LocalCalendar { name: \"" + calendarName + "\"}",deleteSheet);
                toRemoveCalendarComponent.deleteCalendar();
                Calindori.CalindoriConfig.removeCalendar(calendarName);
            }
            
            // workaround for dialog closing immediately
            property var timer: Timer {
                interval: 50
                running: false
                onTriggered: deleteSheet.open();
            }
        }
        
        // calendar editor
        Component {
            id: editor

            CalendarEditor {
                id: editor
                mode: CalendarEditor.Mode.Edit
                ownerName: Calindori.CalindoriConfig.ownerName(editor.calendarName)
                ownerEmail: Calindori.CalindoriConfig.ownerEmail(editor.calendarName)

                onCalendarEditorCancelled: applicationWindow().pageStack.pop()
                onCalendarEditorSaved: {
                    applicationWindow().pageStack.pop();
                    if (Calindori.CalindoriConfig.activeCalendar && (Calindori.CalindoriConfig.activeCalendar.name === editor.calendarName)) {
                        Calindori.CalindoriConfig.activeCalendar.ownerName = ownerName;
                        Calindori.CalindoriConfig.activeCalendar.ownerEmail = ownerEmail;
                    }
                }
            }
        }

        FileChooser {
            id: fileChooser

            onAccepted: Calindori.DataHandler.importFromUrl(fileUrl)
        }

        // list delegate
        delegate: Kirigami.SwipeListItem {
            property string calendarName: modelData
            
            RowLayout {
                spacing: 0
                
                Kirigami.Icon {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing
                    Layout.alignment: Qt.AlignVCenter
                    source: "view-calendar"
                    implicitHeight: Kirigami.Units.iconSizes.smallMedium
                    implicitWidth: Kirigami.Units.iconSizes.smallMedium
                }
                
                Kirigami.Heading {
                    Layout.fillWidth: true
                    type: Kirigami.Heading.Secondary
                    level: 6
                    text: calendarName
                    elide: Text.ElideRight
                }
            }
            
            onClicked: {
                modifyDialog.calendarName = calendarName
                modifyDialog.open();
            }
            
            actions: [
                Kirigami.Action {
                    text: i18n("Modify")
                    icon.name: "entry-edit"
                    onTriggered: {
                        modifyDialog.calendarName = calendarName
                        modifyDialog.open();
                    }
                }
            ]
        }
        
    }
}
