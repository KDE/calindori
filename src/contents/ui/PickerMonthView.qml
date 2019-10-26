/*
 *   Copyright 2019 Dimitris Kardarakos <dimkard@posteo.net>
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
import QtQuick.Layouts 1.11
import org.kde.phone.calindori 0.1

MonthView {
    id: root

    signal nextMonth
    signal previousMonth

    showHeader: false
    showMonthName: true
    displayedYear: mm.year
    displayedMonthName: Qt.locale(Qt.locale().uiLanguages[0]).monthName(mm.month-1)
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
