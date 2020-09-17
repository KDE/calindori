/*
 * SPDX-FileCopyrightText: 2018 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami

ColumnLayout {
    id: root

    property date headerDate
    property int headerTodosCount
    property int headerEventsCount
    property var applicationLocale: Qt.locale()

    RowLayout {
        id: selectedDayHeading

        spacing:  Kirigami.Units.largeSpacing

        Controls2.Label {
            font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 4
            text: root.headerDate.getDate()
            opacity: 0.6
        }

        ColumnLayout {
            spacing:  Kirigami.Units.smallSpacing

            Controls2.Label {
                text: root.headerDate.toLocaleDateString(applicationLocale, "dddd")
                font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
            }

            Controls2.Label {
                text: root.headerDate.toLocaleDateString(applicationLocale, "MMMM") + " " + root.headerDate.getFullYear()
                font.pointSize: Kirigami.Units.fontMetrics.font.pointSize
            }
        }
    }

    Controls2.Label {
        text: ((root.headerTodosCount > 0) ? i18np("%1 task", "%1 tasks",root.headerTodosCount) : "") +
                ((root.headerTodosCount > 0 && root.headerEventsCount > 0) ? " and " : "") +
                    ((root.headerEventsCount > 0) ? i18np("%1 event", "%1 events",root.headerEventsCount) : "")
        opacity: 0.6
    }
}
