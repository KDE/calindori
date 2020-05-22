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

    property int fstDayOfWeek: Qt.locale().firstDayOfWeek
    property date startDate
    property date selectedWeekDate: new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() - startDate.getDay() + (startDate.getDay() >= fstDayOfWeek ? fstDayOfWeek : fstDayOfWeek-7), startDate.getHours(), 0)
    property date selectedDate: startDate
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
        selectedWeekDate = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() - startDate.getDay() + (startDate.getDay() >= fstDayOfWeek ? fstDayOfWeek : fstDayOfWeek - 7), startDate.getHours(), 0);
        selectedDate = startDate;
        currentIndex = selectedDate.getDay() >= fstDayOfWeek ? selectedDate.getDay() - fstDayOfWeek : 7 - (selectedDate.getDay() +  fstDayOfWeek)
    }

    onAddEvent: pageStack.push(eventEditor, { startDt: new Date(root.selectedDate.getTime() - root.selectedDate.getMinutes()*60000 + 3600000) })

    onAddTodo: pageStack.push(todoEditor, { startDt: selectedDate })

    onCurrentIndexChanged: {
        if (pageStack.depth > 1) {
            pageStack.pop(null);
        }
    }

    model: 7
    currentIndex: selectedDate.getDay() >= fstDayOfWeek ? selectedDate.getDay() - fstDayOfWeek : 7 - (selectedDate.getDay() +  fstDayOfWeek)

    delegate: Kirigami.AbstractListItem {
        id: dayListItem

        property var weekDay: model.index

        contentItem: RowLayout {
            spacing: Kirigami.Units.largeSpacing * 3

            Controls2.Label {
                font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
                text: Qt.locale().dayName(model.index + fstDayOfWeek, Locale.NarrowFormat)
                Layout.minimumWidth: Kirigami.Units.gridUnit * 3
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
