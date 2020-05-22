/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.4 as Kirigami
import org.kde.phone.calindori 0.1 as Calindori

Kirigami.Card {
    id: cardDelegate

    property var dataModel

    banner.title: dataModel && dataModel.summary
    banner.titleLevel: 3

    contentItem: Column {
        enabled: dataModel && !dataModel.completed
        spacing: Kirigami.Units.largeSpacing
        topPadding: 0
        bottomPadding: Kirigami.Units.largeSpacing

        Row {
            visible: dataModel && dataModel.dtstart && !isNaN(dataModel.dtstart)
            width: cardDelegate.availableWidth
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "view-calendar-day"
                width: Kirigami.Units.iconSizes.small
                height: width
            }

            Controls2.Label {
                wrapMode: Text.WordWrap
                text: dataModel && ((dataModel.dtstart && !isNaN(dataModel.dtstart)) ? dataModel.dtstart.toLocaleString(Qt.locale(), dataModel.allday ? "ddd d MMM yyyy" : "ddd d MMM yyyy hh:mm" ) : "")
            }
        }

        Row {
            visible: dataModel && (dataModel.location != "")
            width: cardDelegate.availableWidth
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "gps"
                width: Kirigami.Units.iconSizes.small
                height: width
            }

            Controls2.Label {
                wrapMode: Text.WordWrap
                text: dataModel && dataModel.location
            }
        }

        Controls2.Label {
            width: cardDelegate.availableWidth
            wrapMode: Text.WordWrap
            text: dataModel && dataModel.description
        }
    }
}
