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

    property date startDate
    property date selectedWeekDate: new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() - startDate.getDay() + Qt.locale().firstDayOfWeek)
    property date selectedDate: new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() - startDate.getDay() + Qt.locale().firstDayOfWeek)
    property var cal

    signal nextWeek
    signal previousWeek
    signal goCurrentWeek
    signal addEvent
    signal addTodo

    function moveDate(startDt, offset)
    {
        var movedDt = startDt;
        movedDt.setDate(startDt.getDate() + offset);

        return movedDt;
    }

    onNextWeek: {
        selectedWeekDate = moveDate(selectedWeekDate, 7);
        selectedDate = selectedWeekDate;
        currentIndex = 0;
    }

    onPreviousWeek: {
        selectedWeekDate = moveDate(selectedWeekDate, -7);
        selectedDate = selectedWeekDate;
        currentIndex = 0;
    }

    onGoCurrentWeek: {
        selectedWeekDate = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() - startDate.getDay() + 1);
        selectedDate = selectedWeekDate;
        currentIndex = 0;
    }

    onAddEvent: pageStack.push(eventEditor, { startDt: selectedDate })

    onAddTodo: pageStack.push(todoEditor, { startDt: selectedDate })

    model: 7
    currentIndex: 0

    delegate: Kirigami.AbstractListItem {
        id: dayListItem

        property var weekDay: model.index

        contentItem: RowLayout {
            spacing: Kirigami.Units.largeSpacing * 3

            Controls2.Label {
                font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
                text: Qt.locale().dayName(model.index + Qt.locale().firstDayOfWeek, Locale.NarrowFormat)
            }

            ColumnLayout {
                spacing: 0

                Repeater {
                    model: IncidenceModel {
                        calendar: root.cal
                        filterDt: moveDate(root.selectedWeekDate, dayListItem.weekDay)
                        filterMode: 4
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

        onClicked: { root.selectedDate = moveDate(root.selectedWeekDate, model.index) }
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
