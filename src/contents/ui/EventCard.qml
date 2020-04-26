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

import QtQuick 2.7
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.4 as Kirigami
import org.kde.phone.calindori 0.1 as Calindori

Kirigami.Card {
    id: cardDelegate

    property var dataModel

    banner.title: dataModel.summary
    banner.titleLevel: 3

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
                property bool sameEndStart : dataModel.dtstart && !isNaN(dataModel.dtstart) && dataModel.dtend && !isNaN(dataModel.dtend) && dataModel.dtstart.toLocaleString(Qt.locale(), "dd.MM.yyyy") == dataModel.dtend.toLocaleString(Qt.locale(), "dd.MM.yyyy")
                property string timeFormat: dataModel.allday ? "" : "hh:mm"
                property string dateFormat: dataModel.allday ? "ddd d MMM yyyy" : "ddd d MMM yyyy hh:mm"
                property string separator: dataModel.allday ? "" : " - "

                wrapMode: Text.WordWrap
                text: ((dataModel.dtstart && !isNaN(dataModel.dtstart)) ? dataModel.dtstart.toLocaleString(Qt.locale(), dateFormat ) : "") +
                    (dataModel.dtend && !isNaN(dataModel.dtend) ? separator +
                        dataModel.dtend.toLocaleString(Qt.locale(), sameEndStart ? timeFormat : dateFormat ) : "")
                Layout.fillWidth: true
            }
        }

        RowLayout {
            visible: dataModel.location != ""
            width: cardDelegate.availableWidth
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "gps"
                width: Kirigami.Units.iconSizes.small
                height: width
            }

            Controls2.Label {
                wrapMode: Text.WordWrap
                text: dataModel.location
                Layout.fillWidth: true
            }
        }

        RowLayout {
            visible: dataModel.isRepeating
            width: cardDelegate.availableWidth
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "media-playlist-repeat"
                width: Kirigami.Units.iconSizes.small
                height: width
            }

            Controls2.Label {
                wrapMode: Text.WordWrap
                text: _repeatModel.repeatDescription(dataModel.repeatType, dataModel.repeatEvery, dataModel.repeatStopAfter)
                Layout.fillWidth: true
            }
        }

        Controls2.Label {
            visible: dataModel.description != ""
            width: cardDelegate.availableWidth
            wrapMode: Text.WordWrap
            text: dataModel.description
        }
    }
}
