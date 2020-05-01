/*
    Copyright (C) 2020 Dimitris Kardarakos <dimkard@posteo.net>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
