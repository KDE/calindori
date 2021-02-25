/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import org.kde.kirigami 2.2 as Kirigami
import QtQuick.Layouts 1.3


Controls2.AbstractButton {
    id: hoursButton

    property int selectedValue
    property string type

    checked: index == selectedValue
    text: index == selectedValue ? ( (type == "hours" && index == 0) ? 12 : index )
                                 : ( (type == "hours") ? ( index == 0 ? 12 : ( (index % 3 == 0) ? index : ".") ) : (index % 15 == 0) ? index : ".")
    contentItem: Controls2.Label {
        text: hoursButton.text
        color: index === parent.selectedValue ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        implicitHeight: Kirigami.Units.gridUnit * 1.2
        implicitWidth: height
        radius: width * 0.5
        Kirigami.Theme.colorSet: Kirigami.Theme.Button
        Kirigami.Theme.inherit: false
        color: parent.checked ? Kirigami.Theme.backgroundColor : "transparent"
    }
}

