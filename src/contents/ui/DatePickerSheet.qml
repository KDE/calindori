/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami

Kirigami.OverlaySheet {
    id: datePickerSheet

    property alias selectedDate: calendarMonth.selectedDate
    property string headerText

    signal datePicked


    header: Kirigami.Heading {
        level:1
        text: datePickerSheet.headerText
    }

    ColumnLayout {
        Layout.preferredWidth: calendarMonth.dayRectWidth * 8

        PickerMonthView {
            id: calendarMonth

            Layout.fillWidth: true
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
