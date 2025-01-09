/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami as Kirigami
import org.kde.calindori 0.1 as Calindori
import org.kde.kirigamiaddons.delegates as Delegates

Kirigami.ScrollablePage {
    id: root

    property date incidenceStartDt
    property var calendar
    property int incidenceType : -1
    property int filterMode: 0

    /**
    * @brief Remove the editor page from the stack. If an incidence page exists in the page stack, remove it as well
    *
    */
    function removeEditorPage() {
        pageStack.pop();
    }

    title: incidenceType == 0 ? i18n("Events") : i18n("Tasks")
    leftPadding: 0
    rightPadding: 0

    actions: [
        Kirigami.Action {
            id: mainAction

            icon.name: "resource-calendar-insert"
            text: (incidenceType === 0) ? i18n("Create Event") : i18n("Create Task")
            onTriggered: {
                var currentDt = Calindori.CalendarController.localSystemDateTime();
                var lStartDt = (incidenceType == 0 && (incidenceStartDt == null || isNaN(incidenceStartDt))) ? new Date(currentDt.getTime() - currentDt.getMinutes()*60000 + 3600000) : incidenceStartDt;
                pageStack.push(incidenceType == 0 ? eventEditor : todoEditor, { startDt: lStartDt } );
            }
        },
        Kirigami.Action {
            property alias hide: incidenceModel.filterHideCompleted
            icon.name: hide ? "show_table_row" : "hide_table_row"
            visible: incidenceType == 1
            text: hide ? i18n("Show Completed") : i18n("Hide Completed")
            onTriggered: hide = !(hide)
        }
    ]

    ListView {
        id: listView

        currentIndex: -1
        anchors.fill: parent
        model: incidenceModel
        spacing: 0

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            icon.name: incidenceType == 0 ? "tag-events" : "view-calendar-tasks"
            width: parent.width - (Kirigami.Units.largeSpacing * 4)
            visible: listView.count == 0
            text: !isNaN(incidenceStartDt) ? i18n("Nothing scheduled for %1", incidenceStartDt.toLocaleDateString(_appLocale, Locale.ShortFormat)) : i18n("Nothing scheduled")
            helpfulAction: mainAction
        }

        // TODO: doesn't seem to work, just leaves empty gap
        // section {
        //     property: incidenceType == 0 ? "displayStartDate" : "displayDueDate"
        //     criteria: ViewSection.FullString
        //     delegate: Kirigami.ListSectionHeader {
        //         label: section
        //     }
        // }

        delegate: Delegates.RoundedItemDelegate {
            id: itemDelegate

            text: "%1\t%2".arg(model.allday ? i18n("All day") : (incidenceType == 0 ? model.displayStartTime : model.displayDueTime)).arg(model.summary)
            topPadding: Kirigami.Units.gridUnit
            bottomPadding: Kirigami.Units.gridUnit
            leftPadding: Kirigami.Units.smallSpacing
            rightPadding: Kirigami.Units.smallSpacing

            contentItem: Delegates.SubtitleContentItem {
                itemDelegate: itemDelegate
            }

            onClicked: {
                if(pageStack.lastItem && pageStack.lastItem.hasOwnProperty("isIncidencePage")) {
                    pageStack.pop(incidencePage);
                }

                pageStack.push(incidencePage, { incidence: model })
            }
        }
    }

    Calindori.IncidenceModel {
        id: incidenceModel

        filterMode: root.filterMode
        filterHideCompleted: true
        appLocale: _appLocale
    }

    Component {
        id: incidencePage

        IncidencePage {
            calendar: root.calendar
        }
    }

    Component {
        id: eventEditor

        EventEditorPage {
            calendar: Calindori.CalendarController.activeCalendar

            onEditcompleted: removeEditorPage()
        }
    }

    Component {
        id: todoEditor

        TodoEditorPage {
            onEditcompleted: removeEditorPage()
        }
    }
}

