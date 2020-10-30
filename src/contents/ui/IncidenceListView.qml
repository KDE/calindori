/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.12 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.ScrollablePage {
    id: root

    property date incidenceStartDt
    property var calendar
    property int incidenceType : -1
    property int filterMode: 0

    title: incidenceType == 0 ? i18n("Events") : i18n("Tasks")
    leftPadding: 0
    rightPadding: 0

    actions.main: Kirigami.Action {
        icon.name: "resource-calendar-insert"
        text: i18n("Add")
        onTriggered: {
            var currentDt = _eventController.localSystemDateTime();
            var lStartDt = (incidenceType == 0 && (incidenceStartDt == null || isNaN(incidenceStartDt))) ? new Date(currentDt.getTime() - currentDt.getMinutes()*60000 + 3600000) : incidenceStartDt;
            pageStack.push(incidenceType == 0 ? eventEditor : todoEditor, { startDt: lStartDt } );
        }
    }

    contextualActions: [
        Kirigami.Action {
            property alias hide: incidenceModel.filterHideCompleted
            icon.name: hide ? "show_table_row" : "hide_table_row"
            visible: incidenceType == 1
            text: hide ? i18n("Show Completed") : i18n("Hide Completed")
            onTriggered: hide = !(hide)
        }
    ]

    Kirigami.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - (Kirigami.Units.largeSpacing * 4)
        visible: listView.count == 0
        text: !isNaN(incidenceStartDt) ? i18n("Nothing scheduled for %1", incidenceStartDt.toLocaleDateString(_appLocale, Locale.ShortFormat)) : i18n("Nothing scheduled")
    }

    ListView {
        id: listView

        anchors.fill: parent
        model: incidenceModel
        spacing: Kirigami.Units.largeSpacing

        section {
            property: incidenceType == 0 ? "displayStartDate" : "displayDueDate"
            criteria: ViewSection.FullString
            delegate: Kirigami.ListSectionHeader {
                label: section
            }
        }

        delegate: Kirigami.BasicListItem {
            id: itemDelegate

            reserveSpaceForIcon: false
            label: "%1\t%2".arg(model.allday ? i18n("All day") : (incidenceType == 0 ? model.displayStartTime : model.displayDueTime)).arg(model.summary)
            topPadding: Kirigami.Units.gridUnit
            bottomPadding: Kirigami.Units.gridUnit

            onClicked: pageStack.push(incidencePage, { incidence: model })
        }
    }

    Calindori.IncidenceModel {
        id: incidenceModel

        calendar: root.calendar
        filterMode: root.filterMode
        filterHideCompleted: true
        appLocale: _appLocale
    }

    Component {
        id: incidencePage

        IncidencePage {
            calendar: root.calendar

            actions.left: Kirigami.Action {
                text: i18n("Delete")
                icon.name: "delete"

                onTriggered: {
                    deleteSheet.incidenceData = { uid: incidence.uid, summary: incidence.summary, type: incidence.type };
                    deleteSheet.open();
                }
            }

            actions.main: Kirigami.Action {
                text: i18n("Close")
                icon.name: "window-close-symbolic"

                onTriggered: pageStack.pop(null)
            }

            actions.right: Kirigami.Action {
                text: i18n("Edit")
                icon.name: "document-edit-symbolic"

                onTriggered: pageStack.push(incidence.type == 0 ? eventEditor : todoEditor, { startDt: incidence.dtstart, uid: incidence.uid, incidenceData: incidence })
            }

            ConfirmationSheet {
                id: deleteSheet

                property var incidenceData
                message: i18n("%1 will be deleted. Proceed?", incidenceData && incidenceData.summary);

                operation: function() {
                    if(incidenceType == 0) {
                        _eventController.remove(root.calendar, incidenceData);
                    } else {
                        _todoController.remove(root.calendar, incidenceData);
                    }
                    pageStack.pop(incidencePage);
                }
            }
        }
    }

    Component {
        id: eventEditor

        EventEditor {
            calendar: localCalendar

            onEditcompleted: pageStack.pop(root)
        }
    }

    Component {
        id: todoEditor

        TodoEditor {
            calendar: localCalendar

            onEditcompleted: pageStack.pop(root)
        }
    }
}

