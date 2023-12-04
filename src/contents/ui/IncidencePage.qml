/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import org.kde.kirigami 2.6 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.Page {
    id: root

    property var incidence
    property var calendar
    property bool isIncidencePage: true

    title: incidence && incidence.summary
    visible: Kirigami.Settings.isMobile || (!Kirigami.Settings.isMobile && !pageStack.lastVisibleItem.hasOwnProperty("isEditorPage"))

    Loader {
        anchors.fill: parent
        sourceComponent: (incidence && incidence.type === 0) ? eventCard : todoCard
    }

    Component {
        id: eventCard

        EventCard {
            dataModel: root.incidence
        }
    }

    Component {
        id: todoCard

        TodoCard {
            dataModel: root.incidence
        }
    }

    actions.left: Kirigami.Action {
        text: i18n("Delete")
        enabled: root.state !== "deleting"
        icon.name: "delete"

        onTriggered: root.state = "deleting"
    }

    actions.right: Kirigami.Action {
        text: i18n("Edit")
        enabled: root.state !== "deleting"
        icon.name: "document-edit"

        onTriggered: pageStack.push(incidence.type === 0 ? eventEditor : todoEditor, { startDt: incidence.dtstart, uid: incidence.uid, incidenceData: incidence })
    }

    footer: Kirigami.InlineMessage {
        id: deleteMsg

        text: i18n("%1 will be deleted", incidence && incidence.summary)

        actions: [
            Kirigami.Action {
                text: i18n("Delete")

                onTriggered: {
                    var incidenceData = {uid: incidence.uid, summary: incidence.summary, type: incidence.type};

                    if(incidenceData.type === 0) {
                        Calindori.CalendarController.removeEvent(Calindori.CalendarController.activeCalendar, incidenceData);
                    }
                    else {
                        Calindori.CalendarController.removeTodo(Calindori.CalendarController.activeCalendar, incidenceData);
                    }
                    root.state = ""
                    pageStack.pop(incidencePage);
                }
            },

            Kirigami.Action {
                text: i18n("Cancel")

                onTriggered: root.state = ""
            }
        ]
    }

    states: [
        State {
            name: ""
            PropertyChanges { target: deleteMsg; visible: false }
        },
        State {
            name: "deleting"
            PropertyChanges { target: deleteMsg; visible: true }
        }
    ]
}
