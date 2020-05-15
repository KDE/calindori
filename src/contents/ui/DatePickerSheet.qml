/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.4 as Kirigami

Kirigami.OverlaySheet {
    id: datePickerSheet

    property alias selectedDate: calendarMonth.selectedDate

    signal datePicked

    ColumnLayout {
        Layout.preferredWidth: childrenRect.width + datePickerSheet.rightPadding + datePickerSheet.leftPadding

        PickerMonthView {
            id: calendarMonth

            Layout.alignment: Qt.AlignHCenter
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
