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
        enabled: !dataModel.completed
        spacing: Kirigami.Units.largeSpacing
        topPadding: 0
        bottomPadding: Kirigami.Units.largeSpacing

        Row {
            visible: dataModel.dtstart && !isNaN(dataModel.dtstart)
            width: cardDelegate.availableWidth
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "view-calendar-day"
                width: Kirigami.Units.iconSizes.small
                height: width
            }

            Controls2.Label {
                wrapMode: Text.WordWrap
                text: (dataModel.dtstart && !isNaN(dataModel.dtstart)) ? dataModel.dtstart.toLocaleString(Qt.locale(), dataModel.allday ? "ddd d MMM yyyy" : "ddd d MMM yyyy hh:mm" ) : ""
            }
        }

        Row {
            visible: dataModel.location != ""
            width: cardDelegate.availableWidth
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "find-location"
                width: Kirigami.Units.iconSizes.small
                height: width
            }

            Controls2.Label {
                wrapMode: Text.WordWrap
                text: dataModel.location
            }
        }

        Controls2.Label {
            width: cardDelegate.availableWidth
            wrapMode: Text.WordWrap
            text: dataModel.description
        }
    }
}
