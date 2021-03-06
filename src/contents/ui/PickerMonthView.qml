/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Layouts 1.3
import org.kde.calindori 0.1 as Calindori

MonthView {
    id: root

    signal nextMonth
    signal previousMonth

    showHeader: false
    showMonthName: true
    displayedYear: mm.year
    displayedMonthName: _appLocale.standaloneMonthName(mm.month-1)
    daysModel: mm
    applicationLocale: _appLocale
    selectedDate: Calindori.CalendarController.localSystemDateTime()
    currentDate: Calindori.CalendarController.localSystemDateTime()

    Layout.preferredHeight: childrenRect.height
    Layout.preferredWidth: childrenRect.width

    onNextMonth: mm.goNextMonth()
    onPreviousMonth: mm.goPreviousMonth()

    Calindori.DaysOfMonthModel {
        id: mm
        year: selectedDate.getFullYear()
        month: selectedDate.getMonth() + 1
    }
}
