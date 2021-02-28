/*
 * SPDX-FileCopyrightText: 2018 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami

/**
 * Month Day Delegate
 *
 * Controls the display of each day of a months' grid
 *
 * Expects a model that provides:
 *
 * 1. dayNumber
 * 2. monthNumber
 * 3. yearNumber
 */
Rectangle {
    id: dayDelegate

    property date currentDate
    property int delegateWidth
    property date selectedDate
    property bool highlight: (model.yearNumber == selectedDate.getFullYear())  &&  (model.monthNumber == selectedDate.getMonth() + 1) &&  (model.dayNumber == root.selectedDate.getDate())

    signal dayClicked

    width: childrenRect.width
    height: childrenRect.height
    opacity:(isToday || highlight )  ? 0.4 : 1
    color: isToday ? Kirigami.Theme.textColor : ( highlight ? Kirigami.Theme.hoverColor : Kirigami.Theme.backgroundColor )
    border.color: Kirigami.Theme.disabledTextColor


    Item {
        width: dayDelegate.delegateWidth
        height: width

        /**
         * Display a tiny indicator in case that
         * todos or events exist for the day of the model
         */
        Rectangle {
            anchors {
                bottom: parent.bottom
                bottomMargin: parent.width/15
                right: parent.right
                rightMargin: parent.width/15

            }

            width: parent.width/10
            height: width
            radius: 50
            color: Kirigami.Theme.highlightColor
            visible: incidenceCount > 0
        }

        Controls2.Label {
            anchors.centerIn: parent
            color: isCurrentMonth ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
            text: model.dayNumber
        }

        MouseArea {
            anchors.fill: parent
            enabled: isCurrentMonth
            onClicked: dayDelegate.dayClicked()
        }
    }
}
