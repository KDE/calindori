/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1 as Controls
import org.kde.kirigami 2.4 as Kirigami

Kirigami.ScrollablePage {
    id: root

    title: i18n("Settings")

    Kirigami.FormLayout {
        width: root.width

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Events")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Initial duration (minutes)")

            Controls.SpinBox {
                from: 0
                value: _calindoriConfig.eventsDuration

                onValueModified: _calindoriConfig.eventsDuration = value
            }
        }
    }
}
