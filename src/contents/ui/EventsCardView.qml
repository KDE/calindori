/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.4 as Kirigami
import org.kde.phone.calindori 0.1 as Calindori

Kirigami.Page {
    id: root

    property date eventStartDt
    property var calendar

    title: i18n("Events")

    leftPadding: 0
    rightPadding: 0

    actions.main: Kirigami.Action {
        icon.name: "resource-calendar-insert"
        text: i18n("Add event")
        onTriggered: pageStack.push(eventEditor, {startDt: (eventStartDt && !isNaN(eventStartDt)) ? new Date(root.eventStartDt.getTime() - root.eventStartDt.getMinutes()*60000 + 3600000) : new Date() })
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

    Controls2.Label {
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        visible: cardsListview.count == 0
        wrapMode: Text.WordWrap
        text: eventStartDt.toLocaleDateString() != "" ? i18n("No events scheduled for %1", eventStartDt.toLocaleDateString(Qt.locale(), Locale.ShortFormat)) : i18n("No events scheduled")
        font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
    }

    Kirigami.CardsListView {
        id: cardsListview

        anchors.fill: parent
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

        filterDt: root.eventStartDt
        calendar: root.calendar
        filterMode: 5
    }

}
