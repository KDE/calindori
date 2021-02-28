/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import org.kde.kirigami 2.0 as Kirigami
import org.kde.calindori 0.1 as Calindori

Controls2.ToolButton {
    id: root

    property date selectorDate
    property string selectorTitle
    property string invalidDateStr

    contentItem: Controls2.Label {
        leftPadding: Kirigami.Units.largeSpacing
        rightPadding: Kirigami.Units.largeSpacing
        text: (selectorDate === undefined || isNaN(root.selectorDate)) ? invalidDateStr : selectorDate.toLocaleDateString(_appLocale, "dd MMM yyyy")
    }

    onClicked: {
        datePickerSheet.selectedDate = (selectorDate != undefined && !isNaN(root.selectorDate)) ? selectorDate: Calindori.CalendarController.localSystemDateTime()
        datePickerSheet.open();
    }

    DatePickerSheet {
        id: datePickerSheet

        headerText: root.selectorTitle

        onDatePicked: root.selectorDate = selectedDate
    }
}
