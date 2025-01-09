/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
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

    property date eventStartDt
    property var calendar

    title: i18n("Events")

    leftPadding: 0
    rightPadding: 0
    visible: Kirigami.Settings.isMobile || (!Kirigami.Settings.isMobile && !pageStack.lastVisibleItem.hasOwnProperty("isEditorPage"))

    actions: [
        Kirigami.Action {
            id: mainAction

            icon.name: "resource-calendar-insert"
            text: i18n("Create Event")
            onTriggered: pageStack.push(eventEditor, {startDt: (eventStartDt && !isNaN(eventStartDt)) ? new Date(root.eventStartDt.getTime() - root.eventStartDt.getMinutes()*60000 + 3600000) : Calindori.CalendarController.localSystemDateTime()})
        }
    ]

    ListView {
        id: cardsListview
        spacing: 0

        model: eventsModel
        enabled: root.state !== "deleting"
        clip: true

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            icon.name: "tag-events"
            width: parent.width - (Kirigami.Units.largeSpacing * 4)
            visible: cardsListview.count == 0
            text: !isNaN(eventStartDt) ? i18n("No events scheduled for %1", eventStartDt.toLocaleDateString(_appLocale, Locale.ShortFormat)) : i18n("No events scheduled")
            helpfulAction: mainAction
        }

        delegate: EventCard {
            id: cardDelegate

            dataModel: model

            actions: [
                Kirigami.Action {
                    text: i18n("Delete")
                    icon.name: "delete"

                    onTriggered: {
                        deleteMsg.eventUid = model.uid;
                        deleteMsg.eventSummary = model.summary;
                        root.state = "deleting";
                    }
                },

                Kirigami.Action {
                    text: i18n("Edit")
                    icon.name: "editor"

                    onTriggered: pageStack.push(eventEditor, { startDt: model.dtstart, uid: model.uid, incidenceData: model })
                }
            ]
        }

        Calindori.IncidenceModel {
            id: eventsModel

            appLocale: _appLocale
            filterDt: root.eventStartDt
            filterMode: 5
        }

        Component {
            id: eventEditor

            EventEditorPage {
                calendar: Calindori.CalendarController.activeCalendar

                onEditcompleted: pageStack.pop()
            }
        }
    }

    footer: Kirigami.InlineMessage {
        id: deleteMsg

        property string eventUid
        property string eventSummary

        text: i18n("Event %1 will be deleted", eventSummary)
        visible: false

        actions: [
            Kirigami.Action {
                text: i18n("Delete")

                onTriggered: {
                    Calindori.CalendarController.removeEvent(root.calendar, {"uid": deleteMsg.eventUid});
                    root.state = "";
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
