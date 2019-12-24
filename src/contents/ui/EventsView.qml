/*
 *   Copyright 2019 Dimitris Kardarakos <dimkard@posteo.net>
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

import QtQuick 2.7
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.4 as Kirigami
import org.kde.phone.calindori 0.1 as Calindori

Kirigami.Page {
    id: root

    property date eventStartDt
    property var calendar

    signal eventsUpdated

    function reload()
    {
        cardsListview.model.loadEvents();
    }

    title: i18n("Events")

    actions.main: Kirigami.Action {
        icon.name: "resource-calendar-insert"
        text: i18n("Add event")
        onTriggered: pageStack.push(eventEditor, {startdt: (eventStartDt && !isNaN(eventStartDt)) ? eventStartDt : new Date() })
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

    Controls2.Label {
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        visible: eventsModel.count == 0
        wrapMode: Text.WordWrap
        text: eventStartDt.toLocaleDateString() != "" ? i18n("No events scheduled for %1", eventStartDt.toLocaleDateString(Qt.locale(), Locale.ShortFormat)) : i18n("No events scheduled")
        font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
    }

    Kirigami.CardsListView {
        id: cardsListview

        anchors.fill: parent

        model: eventsModel

        delegate: Kirigami.Card {
            id: cardDelegate

            padding: Kirigami.Units.smallSpacing
            leftPadding: Kirigami.Units.smallSpacing
            bottomPadding: Kirigami.Units.smallSpacing
            rightPadding: Kirigami.Units.smallSpacing

            banner.title: model.summary
            banner.titleLevel: 3

            actions: [
                Kirigami.Action {
                    text: i18n("Delete")
                    icon.name: "delete"

                    onTriggered: {
                        var vevent = { uid: model.uid } ;
                        _eventController.remove(root.calendar, vevent);
                        eventsUpdated();
                    }
                },

                Kirigami.Action {
                    text: i18n("Edit")
                    icon.name: "editor"

                    onTriggered: pageStack.push(eventEditor, { startdt: model.dtstart, uid: model.uid, eventData: model })
                }
            ]

            contentItem: Column {
                spacing: Kirigami.Units.largeSpacing
                topPadding: 0
                bottomPadding: Kirigami.Units.largeSpacing

                RowLayout {
                    width: cardDelegate.availableWidth
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Icon {
                        source: "view-calendar-day"
                        width: Kirigami.Units.iconSizes.small
                        height: width
                    }

                    Controls2.Label {
                        property bool sameEndStart : model.dtstart && !isNaN(model.dtstart) && model.dtend && !isNaN(model.dtend) && model.dtstart.toLocaleString(Qt.locale(), "dd.MM.yyyy") == model.dtend.toLocaleString(Qt.locale(), "dd.MM.yyyy")
                        property string timeFormat: model.allday ? "" : "hh:mm"
                        property string dateFormat: model.allday ? "ddd d MMM yyyy" : "ddd d MMM yyyy hh:mm"
                        property string separator: model.allday ? "" : " - "

                        wrapMode: Text.WordWrap
                        text: ((model.dtstart && !isNaN(model.dtstart)) ? model.dtstart.toLocaleString(Qt.locale(), dateFormat ) : "") +
                            (model.dtend && !isNaN(model.dtend) ? separator +
                                model.dtend.toLocaleString(Qt.locale(), sameEndStart ? timeFormat : dateFormat ) : "")
                        Layout.fillWidth: true

                    }
                }

                RowLayout {
                    visible: model.location != ""
                    width: cardDelegate.availableWidth
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Icon {
                        source: "find-location"
                        width: Kirigami.Units.iconSizes.small
                        height: width
                    }

                    Controls2.Label {
                        wrapMode: Text.WordWrap
                        text: model.location
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    visible: model.isRepeating
                    width: cardDelegate.availableWidth
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Icon {
                        source: "media-playlist-repeat"
                        width: Kirigami.Units.iconSizes.small
                        height: width
                    }

                    Controls2.Label {
                        wrapMode: Text.WordWrap
                        text: _repeatModel.repeatDescription(model.repeatType, model.repeatEvery, model.repeatStopAfter)
                        Layout.fillWidth: true
                    }
                }

                Controls2.Label {
                    visible: model.description != ""
                    width: cardDelegate.availableWidth
                    wrapMode: Text.WordWrap
                    text: model.description

                }
            }
        }
    }

    Calindori.EventModel {
        id: eventsModel

        filterdt: root.eventStartDt
        memorycalendar: root.calendar.memorycalendar
    }

}
