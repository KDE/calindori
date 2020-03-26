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

import QtQuick 2.0
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.0 as Kirigami
import org.kde.phone.calindori 0.1

ListView {
    id: root

    property date selectedDate: new Date()
    property int selectedHour: 0
    property var cal

    signal nextDay
    signal previousDay
    signal goToday
    signal addEvent
    signal addTodo

    onNextDay: {
        var next = selectedDate;
        next.setDate(selectedDate.getDate() + 1)
        selectedDate = next;
    }

    onPreviousDay: {
        var prev = selectedDate;
        prev.setDate(selectedDate.getDate() - 1)
        selectedDate = prev;
    }

    onGoToday: {
        selectedDate = new Date();
    }

    onAddEvent: pageStack.push(eventEditor, { startDt: selectedDate, startHour: selectedHour % 12, endHour: selectedHour % 12, startPm: selectedHour > 12,  endPm: selectedHour > 12 } )

    onAddTodo: pageStack.push(todoEditor, { startDt: selectedDate, startHour: selectedHour % 12, startPm: selectedHour > 12 } )

    model: 24
    currentIndex: 7

    delegate: Kirigami.AbstractListItem {
        id: hourListItem

        property var hour: model.index

        contentItem: RowLayout {
            spacing: Kirigami.Units.largeSpacing * 2

            Controls2.Label {
                font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
                text: model.index < 10 ? "0" + model.index : model.index
            }

            ColumnLayout {
                spacing: 0

                Repeater {
                    model: IncidenceModel {
                        calendar: root.cal
                        filterDt: root.selectedDate
                        filterHour: hourListItem.hour
                        filterMode: 1
                    }

                    Kirigami.BasicListItem  {
                        leftPadding:  Kirigami.Units.smallSpacing
                        reserveSpaceForIcon: false
                        label: model.summary
                        Layout.fillWidth: true

                        onClicked: pageStack.push(incidencePage, { incidence: model })
                    }
                }
            }
        }

        onClicked: selectedHour = model.index

    }

    Component {
        id: incidencePage

        IncidencePage {
            calendar: root.cal

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
        }
    }

    Component {
        id: eventEditor

        EventEditor {
            calendar: root.cal

            onEditcompleted: {
                pageStack.pop(eventEditor);
                pageStack.flickBack ()
            }
        }
    }

    Component {
        id: todoEditor

        TodoEditor {
            calendar: root.cal

            onEditcompleted: {
                pageStack.pop(todoEditor);
                pageStack.flickBack ()
            }
        }
    }

    ConfirmationSheet {
        id: deleteSheet

        property var incidenceData

        message: i18n("%1 will be deleted. Proceed?", incidenceData.summary || "");
        operation: function() {
            if(incidenceData.type == 0)
            {
                _eventController.remove(root.cal, incidenceData);
            }
            else
            {
                _todoController.remove(root.cal, incidenceData);
            }
            pageStack.pop(incidencePage);
        }
    }
}
