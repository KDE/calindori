/*
 *   Copyright 2019 Dimitris Kardarakos
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.4 as Kirigami

Kirigami.OverlaySheet {
    id: datePickerSheet

    property alias selectedDate: calendarMonth.selectedDate

    signal datePicked

    rightPadding: 0
    leftPadding: 0

    ColumnLayout {

        CalendarMonthView {
            id: calendarMonth

            Layout.alignment : Qt.AlignHCenter
            showHeader: false
            showMonthName: true
        }

        RowLayout {
            spacing: Kirigami.Units.largeSpacing
            Layout.alignment : Qt.AlignHCenter

            RowLayout {
                spacing: 0

                Controls2.ToolButton {
                    icon.name: "go-previous"

                    onClicked: calendarMonth.previousMonth()
                }

                Controls2.ToolButton {
                    text: "Previous"

                    onClicked: calendarMonth.previousMonth()
                }
            }

            RowLayout {
                spacing: 0

                Controls2.ToolButton {
                    text: "Next"

                    onClicked: calendarMonth.nextMonth()
                }

                Controls2.ToolButton {
                    icon.name: "go-next"

                    onClicked: calendarMonth.nextMonth()
                }
            }
        }
    }

    footer: RowLayout {

        Item {
            Layout.fillWidth: true
        }

        Controls2.ToolButton {
            text: "OK"

            onClicked: {
                datePickerSheet.datePicked();
                datePickerSheet.close();
            }
        }

        Controls2.ToolButton {
            text: "Cancel"

            onClicked: datePickerSheet.close()
        }
    }
}
