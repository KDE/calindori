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


        Controls.SpinBox {
            Kirigami.FormData.label: i18n("Initial duration (minutes)")

            from: 0
            value: _calindoriConfig.eventsDuration

            onValueModified: _calindoriConfig.eventsDuration = value
        }


        Controls.SpinBox {
            Kirigami.FormData.label: i18n("Remind before event (minutes)")

            from: 0
            value: _calindoriConfig.preEventRemindTime

            onValueModified: _calindoriConfig.preEventRemindTime = value
        }

        Controls.SwitchDelegate {
            Kirigami.FormData.label: i18n("Add reminder to new events")

            checked: _calindoriConfig.alwaysRemind
            onCheckedChanged: _calindoriConfig.alwaysRemind = checked
        }
    }
}
