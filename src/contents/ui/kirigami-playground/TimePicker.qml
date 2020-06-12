/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.11
import QtQuick.Controls 2.4 as Controls2
import org.kde.kirigami 2.0 as Kirigami
import QtQuick.Layouts 1.11

ColumnLayout {

    id: root

    property int hours
    property int minutes
    property bool pm

    Item {
        id: clock

        width: Kirigami.Units.gridUnit * 18
        height: width
        Layout.alignment: Qt.AlignHCenter

        /**
         * Hours clock
         */
        PathView {
            id: hoursClock

            delegate: ClockElement {
                type: "hours"
                selectedValue: root.hours
                onClicked: root.hours = index
            }
            model: 12
            path: Path {
                PathAngleArc {
                    centerX: Kirigami.Units.gridUnit * 9
                    centerY: centerX
                    radiusX: Kirigami.Units.gridUnit * 4
                    radiusY: radiusX
                    startAngle: -90
                    sweepAngle: 360
                }
            }
        }

        /**
         * Minutes clock
         */
        PathView {
            id: minutesClock

            model: 60

            delegate: ClockElement {
                type: "minutes"
                selectedValue: root.minutes
                onClicked: root.minutes = index
            }

            path: Path {
                PathAngleArc {
                    centerX: Kirigami.Units.gridUnit * 9
                    centerY: centerX
                    radiusX: Kirigami.Units.gridUnit * 7
                    radiusY: radiusX
                    startAngle: -90
                    sweepAngle: 360
                }
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter

        Controls2.Label {
            text: ((root.hours < 10) ? "0" : "" ) + root.hours + ":" + ( (root.minutes < 10) ? "0" : "") + root.minutes
            font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
        }

        Controls2.TabBar {
            id: pmTabBar
            font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5

            Controls2.TabButton {
                text: i18n("AM")
                checked: !root.pm

                onClicked: root.pm = !checked
            }
            Controls2.TabButton {
                text: i18n("PM")
                checked: root.pm

                onClicked: root.pm = checked
            }
        }
    }

}
