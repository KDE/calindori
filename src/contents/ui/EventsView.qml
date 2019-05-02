/*
 *   Copyright 2018 Dimitris Kardarakos <dimkard@gmail.com>
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
import org.kde.kirigami 2.4 as Kirigami
import org.kde.phone.calindori 0.1 as Calindori

Kirigami.Page {
    id: root

    property date eventStartDt
    property var calendar

    signal editEvent(var modelData)
    signal eventsUpdated

    function reload()
    {
        cardsListview.model.loadEvents();
    }

    title: qsTr("Events")

    actions.main: Kirigami.Action {
        icon.name: "resource-calendar-insert"
        text: qsTr("Add event")
        onTriggered: pageStack.push(eventEditor, {startdt: eventStartDt})
    }


    Component {
        id: eventEditor
        EventEditor {
            calendar: localCalendar

            onEditcompleted: {
                eventsUpdated();
                pageStack.pop(eventEditor);
            }
        }
    }

    Kirigami.CardsListView {
        id: cardsListview
        anchors.fill: parent

        model: Calindori.EventModel {
            filterdt: root.eventStartDt
            memorycalendar: root.calendar.memorycalendar

        }

        delegate: Kirigami.Card {
            banner.title: model.summary
            banner.titleLevel: 3

            actions: [
                Kirigami.Action {
                    text: qsTr("Delete")
                    icon.name: "delete"

                    onTriggered: {
                        root.calendar.deleteEvent(model.uid);
                        eventsUpdated();
                    }
                },

                Kirigami.Action {
                    text: qsTr("Edit")
                    icon.name: "editor"

                    onTriggered: root.editEvent(model)
                }
            ]

            contentItem: Column {

                Controls2.Label {
                    wrapMode: Text.WordWrap
                    text: model.description
                }

                Controls2.Label {
                    visible: model.dtstart && !isNaN(model.dtstart) //&& model.dtstart.toLocaleTimeString(Qt.locale()) != ""
                    wrapMode: Text.WordWrap
                    text: (model.dtstart && !isNaN(model.dtstart)) ? model.dtstart.toLocaleDateString(Qt.locale()) : ""
                }

                Controls2.Label {
                    visible: model.dtstart && !isNaN(model.dtstart) //&& model.dtstart.toLocaleTimeString(Qt.locale()) != ""
                    wrapMode: Text.WordWrap
                    text: (model.dtstart && !isNaN(model.dtstart)) ? model.dtstart.toLocaleTimeString(Qt.locale(), Locale.ShortFormat) : ""
                }

                Controls2.Label {
                    visible: model.location != ""
                    wrapMode: Text.WordWrap
                    text: model.location
                }
            }
        }
    }
}
