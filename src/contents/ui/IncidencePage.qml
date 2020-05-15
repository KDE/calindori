/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import org.kde.kirigami 2.4 as Kirigami

Kirigami.Page {
    id: root

    property var incidence
    property var calendar

    title: incidence.summary

    Loader {
        anchors.fill: parent
        sourceComponent: incidence.type == 0 ? eventCard : todoCard
    }

    Component {
        id: eventCard

        EventCard {
            dataModel: root.incidence
        }
    }

    Component {
        id: todoCard

        TodoCard {
            dataModel: root.incidence
        }
    }
}
