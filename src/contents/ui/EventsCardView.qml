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

    actions.main: Kirigami.Action {
        icon.name: "resource-calendar-insert"
        text: i18n("New Event")
        onTriggered: pageStack.push(eventEditor, {startDt: (eventStartDt && !isNaN(eventStartDt)) ? new Date(root.eventStartDt.getTime() - root.eventStartDt.getMinutes()*60000 + 3600000) : _eventController.localSystemDateTime()})
    }

    Component {
        id: eventEditor

        EventEditor {
            calendar: localCalendar

            onEditcompleted: {
                pageStack.pop(eventEditor);
            }
        }
    }

    Kirigami.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - (Kirigami.Units.largeSpacing * 4)
        visible: cardsListview.count == 0
        text: !isNaN(eventStartDt) ? i18n("No events scheduled for %1", eventStartDt.toLocaleDateString(_appLocale, Locale.ShortFormat)) : i18n("No events scheduled")
    }

    Kirigami.CardsListView {
        id: cardsListview

        model: eventsModel

        delegate: EventCard {
            id: cardDelegate

            dataModel: model

            actions: [
                Kirigami.Action {
                    text: i18n("Delete")
                    icon.name: "delete"

                    onTriggered: {
                        var vevent = { uid: model.uid } ;
                        _eventController.remove(root.calendar, vevent);
                    }
                },

                Kirigami.Action {
                    text: i18n("Edit")
                    icon.name: "editor"

                    onTriggered: pageStack.push(eventEditor, { startDt: model.dtstart, uid: model.uid, incidenceData: model })
                }
            ]
        }
    }

    Calindori.IncidenceModel {
        id: eventsModel

        appLocale: _appLocale
        filterDt: root.eventStartDt
        calendar: root.calendar
        filterMode: 5
    }
}
