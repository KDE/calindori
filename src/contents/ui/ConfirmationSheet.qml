/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.4 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.OverlaySheet {
    id: root

    property string message

    property var operation

    header: Kirigami.Heading {
        level:1
        text: i18n("Confirm")
    }

    contentItem: Controls2.Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        text: root.message
    }

    footer: RowLayout {
        Item {
            Layout.fillWidth: true
        }

        Controls2.ToolButton {
            text: i18n("Yes")

            onClicked: {
                root.close();
                operation();
            }
        }

        Controls2.ToolButton {
            text: i18n("No")

            onClicked: root.close()
        }
    }
}
