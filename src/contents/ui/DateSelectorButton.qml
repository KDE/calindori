/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import org.kde.kirigami 2.0 as Kirigami

Controls2.ToolButton {
    id: root

    property date selectorDate
    property string selectorTitle

    text: selectorDate.toLocaleDateString(Qt.locale(),Locale.NarrowFormat)
    implicitWidth: Kirigami.Units.gridUnit * 5

    onClicked: {
        datePickerSheet.selectedDate = selectorDate;
        datePickerSheet.open();
    }

    DatePickerSheet {
        id: datePickerSheet

        headerText: root.selectorTitle

        onDatePicked: root.selectorDate = selectedDate
    }
}
