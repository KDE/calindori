/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.4 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.Card {
    id: root

    property var dataModel

    banner.title: dataModel && dataModel.summary
    banner.titleLevel: 3
    clip: true

    contentItem: Column {
        spacing: Kirigami.Units.largeSpacing
        topPadding: 0
        bottomPadding: Kirigami.Units.largeSpacing

        RowLayout {
            width: root.availableWidth
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "view-calendar-day"
                width: Kirigami.Units.iconSizes.small
                height: width
            }

            Controls2.Label {
                wrapMode: Text.WordWrap
                text: dataModel && dataModel.displayStartEndTime

                Layout.fillWidth: true
            }
        }

        RowLayout {
            visible: dataModel && dataModel.isRepeating
            width: root.availableWidth
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "media-playlist-repeat"
                width: Kirigami.Units.iconSizes.small
                height: width
            }

            Controls2.Label {
                wrapMode: Text.WordWrap
                text: dataModel && _repeatModel && _repeatModel.repeatDescription(dataModel.repeatType, dataModel.repeatEvery, dataModel.repeatStopAfter)
                Layout.fillWidth: true
            }
        }

        RowLayout {
            visible: dataModel && dataModel.displayAttendeeNames
            width: root.availableWidth
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "meeting-attending"
                width: Kirigami.Units.iconSizes.small
                height: width
            }

            Controls2.Label {
                wrapMode: Text.WordWrap
                text: dataModel && dataModel.displayAttendeeNames
                Layout.fillWidth: true
            }
        }

        IncidenceCardData {
            dataModel: root.dataModel
            width: root.availableWidth
        }
    }
}
