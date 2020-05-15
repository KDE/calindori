/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Controls 2.4 as Controls2

Controls2.ToolButton {
    id: root

    property date selectorDate

    text: selectorDate.toLocaleDateString(Qt.locale(),Locale.NarrowFormat)

    onClicked: {
        datePickerSheet.selectedDate = selectorDate;
        datePickerSheet.open();
    }

    DatePickerSheet {
        id: datePickerSheet

        onDatePicked: root.selectorDate = selectedDate
    }
}
