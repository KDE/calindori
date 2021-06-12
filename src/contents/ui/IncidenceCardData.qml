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

ColumnLayout {
    id: root

    property var dataModel
    spacing: Kirigami.Units.largeSpacing

    RowLayout {
        visible: dataModel && (dataModel.location != "")
        spacing: Kirigami.Units.smallSpacing
        Layout.fillWidth: true

        Kirigami.Icon {
            source: "gps"
            width: Kirigami.Units.iconSizes.small
            height: width
        }

        Controls2.Label {
            wrapMode: Text.WordWrap
            text: dataModel && dataModel.location
            Layout.fillWidth: true
        }
    }

    Kirigami.Separator {
        visible: dataModel && (dataModel.description != "")
        Layout.fillWidth: true
    }

    Controls2.Label {
        visible: dataModel && (dataModel.description != "")
        wrapMode: Text.WordWrap
        text: dataModel && dataModel.description
        Layout.fillWidth: true
    }
}
