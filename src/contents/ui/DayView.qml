/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.0 as Kirigami
import org.kde.phone.calindori 0.1

ListView {
    id: root

    property date selectedDate: new Date()
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
        currentIndex = selectedDate.getHours();
    }

    onAddEvent: {
        var eventDt = selectedDate;
        eventDt.setHours(currentIndex);
        eventDt.setMinutes(0);

        pageStack.push(eventEditor, { startDt: eventDt });
    }

    onAddTodo: pageStack.push(todoEditor, { startDt: selectedDate, startHour: currentIndex % 12, startPm: currentIndex > 12 } )

    onCurrentIndexChanged: {
        if (pageStack.depth > 1) {
            pageStack.pop(null);
        }
    }

    model: 24
    currentIndex: selectedDate.getHours()

    delegate: Kirigami.AbstractListItem {
        id: hourListItem

        property var hour: model.index

        contentItem: RowLayout {
            spacing: Kirigami.Units.largeSpacing * 2

            Controls2.Label {
                font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
                text: model.index < 10 ? "0" + model.index : model.index
                Layout.minimumWidth: Kirigami.Units.gridUnit * 2
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

        message: i18n("%1 will be deleted. Proceed?", incidenceData && incidenceData.summary);
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
