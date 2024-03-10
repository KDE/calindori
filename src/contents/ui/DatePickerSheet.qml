/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami as Kirigami

Kirigami.Dialog {
    id: datePickerSheet

    property alias selectedDate: calendarMonth.selectedDate
    property string headerText

    signal datePicked

    title: datePickerSheet.headerText

    preferredWidth: calendarMonth.dayRectWidth * 8
    standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel

    ColumnLayout {
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

    onAccepted: {
        datePickerSheet.datePicked();
        datePickerSheet.close();
    }
    onRejected: datePickerSheet.close()
}
