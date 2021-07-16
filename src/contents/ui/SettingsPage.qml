/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.3 as Kirigami
import org.kde.calindori 0.1 as Calindori

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
            value: Calindori.CalindoriConfig.eventsDuration

            onValueModified: Calindori.CalindoriConfig.eventsDuration = value
        }


        Controls.SpinBox {
            Kirigami.FormData.label: i18n("Remind before event (minutes)")

            from: 0
            value: Calindori.CalindoriConfig.preEventRemindTime

            onValueModified: Calindori.CalindoriConfig.preEventRemindTime = value
        }

        Controls.SwitchDelegate {
            Kirigami.FormData.label: i18n("Add reminder to new events")

            checked: Calindori.CalindoriConfig.alwaysRemind
            onCheckedChanged: Calindori.CalindoriConfig.alwaysRemind = checked
        }
    }
}
