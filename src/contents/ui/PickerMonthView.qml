/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Layouts 1.3
import org.kde.calindori 0.1

MonthView {
    id: root

    signal nextMonth
    signal previousMonth

    showHeader: false
    showMonthName: true
    displayedYear: mm.year
    displayedMonthName: Qt.locale().standaloneMonthName(mm.month-1)
    daysModel: mm

    Layout.preferredHeight: childrenRect.height
    Layout.preferredWidth: childrenRect.width

    onNextMonth: mm.goNextMonth()
    onPreviousMonth: mm.goPreviousMonth()

    DaysOfMonthModel {
        id: mm
        year: selectedDate.getFullYear()
        month: selectedDate.getMonth() + 1
    }
}
