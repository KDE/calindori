/*
* SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
*
* SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick 2.7
import org.kde.kirigami 2.0 as Kirigami

Kirigami.BasicListItem  {
    property alias itemBackgroundColor: backgroundRectangle.color

    leftPadding: Kirigami.Units.smallSpacing
    reserveSpaceForIcon: false
    clip: true

    background: Rectangle {
        id: backgroundRectangle
    }
}
