/*
 *   Copyright 2020 Dimitris Kardarakos <dimkard@posteo.net>
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

import QtQuick 2.7
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.10 as Kirigami
import org.kde.phone.calindori 0.1 as Calindori

Kirigami.Page {
    id: root

    property date incidenceStartDt
    property var calendar
    property var incidenceType : ""

    title: incidenceType == "event" ? i18n("Events") : i18n("Tasks")
    leftPadding: 0
    rightPadding: 0

    actions.main: Kirigami.Action {
        icon.name: "resource-calendar-insert"
        text: i18n("Add")
        onTriggered: {
            var lStartDt = (incidenceType == "event" && (incidenceStartDt == null || isNaN(incidenceStartDt))) ? new Date() : incidenceStartDt;
            pageStack.push(incidenceType == "event" ? eventEditor : todoEditor, { startDt: lStartDt } );
        }
    }

    Controls2.Label {
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        visible: listView.count == 0
        wrapMode: Text.WordWrap
        text: incidenceStartDt.toLocaleDateString() != "" ? i18n("Nothing scheduled for %1", incidenceStartDt.toLocaleDateString(Qt.locale(), Locale.ShortFormat)) : i18n("Nothing scheduled")
        font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
    }

    ListView {
        id: listView

        anchors.fill: parent

        model: (incidenceType == "event") ? eventsModel : todosModel

        section {
            property: "displayDate"
            criteria: ViewSection.FullString
            delegate: Kirigami.ListSectionHeader {
                label: section
            }
        }

        delegate: Kirigami.SwipeListItem {
            id: itemDelegate

            actions: [

                Kirigami.Action {
                    text: i18n("Delete")
                    icon.name: "delete"

                    onTriggered: {
                        deleteSheet.incidence = { uid: model.uid, summary: model.summary };
                        deleteSheet.open();
                    }
                },

                Kirigami.Action {
                    text: i18n("Edit")
                    icon.name: "document-edit-symbolic"

                    onTriggered: pageStack.push(incidenceType == "event" ? eventEditor : todoEditor, { startDt: model.dtstart, uid: model.uid, incidenceData: model })
                },

                Kirigami.Action {
                    text: i18n("Info")
                    icon.name: "documentinfo"

                    onTriggered: pageStack.push(incidencePage, { incidence: model, incidenceType: root.incidenceType })
                }
            ]

            contentItem: RowLayout {
                spacing: Kirigami.Units.largeSpacing * 2
                width: parent.width

                Controls2.Label {
                    visible: model.displayTime != ""
                    width: Kirigami.Units.gridUnit * 20
                    text: model.displayTime
                }

                Controls2.Label {
                    visible: model.summary != ""
                    elide: Text.ElideRight
                    text: model.summary
                    Layout.fillWidth: true
                }
            }
        }
    }

    Calindori.EventModel {
        id: eventsModel

        filterdt: root.incidenceStartDt
        calendar: root.calendar
    }

    Calindori.TodosModel {
        id: todosModel

        filterdt: root.incidenceStartDt
        calendar: root.calendar
    }

    Component {
        id: incidencePage

        IncidencePage {
            calendar: root.calendar
        }
    }

    Component {
        id: eventEditor

        EventEditor {
            calendar: localCalendar

            onEditcompleted: pageStack.pop(eventEditor)
        }
    }


    Component {
        id: todoEditor

        TodoEditor {
            calendar: localCalendar

            onEditcompleted: pageStack.pop(todoEditor)
        }
    }

    ConfirmationSheet {
        id: deleteSheet

        property var incidence
        message: i18n("%1 will be deleted. Proceed?", incidence.summary || "");

        operation: function() {
            if(incidenceType == "event")
            {
                _eventController.remove(root.calendar, incidence);
            }
            else
            {
                _todoController.remove(root.calendar, incidence);
            }
        }
    }

}

