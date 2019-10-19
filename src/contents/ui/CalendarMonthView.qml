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
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.0 as Kirigami
import org.kde.phone.calindori 0.1

/**
 * Calendar component that displays:
 *  - a header with currrent day's information
 *  - a table (grid) with the days of the current month
 *  - a set of actions to navigate between months
 * It offers vertical swiping
 */
Controls2.SwipeView {
    id: root

    property alias selectedDate: monthView.selectedDate
    property alias displayedMonthName: monthView.displayedMonthName
    property alias displayedYear: monthView.displayedYear
    property alias showHeader: monthView.showHeader
    property alias showMonthName: monthView.showMonthName
    property alias todosCount: monthView.todosCount
    property alias eventsCount: monthView.eventsCount
    property int backMonthPad: 720
    property int fwdMonthPad: 480
    property int previousIndex
    property var manageIndex: function () {}

    signal nextMonth
    signal previousMonth
    signal goToday
    signal refresh

    onRefresh: {
        mm.update();
        monthView.reloadSelectedDate();
    }

    onNextMonth: mm.goNextMonth()
    onPreviousMonth: mm.goPreviousMonth()
    onGoToday: mm.goCurrentMonth()
    onCurrentItemChanged: manageIndex()

    Component.onCompleted: {
        currentIndex = backMonthPad;
        previousIndex = currentIndex;
        manageIndex = function() {
            (currentIndex < previousIndex) ? mm.goPreviousMonth() : mm.goNextMonth();
            previousIndex = currentIndex;
            monthView.parent = currentItem;
        };
    }

    orientation: Qt.Vertical

    DaysOfMonthModel {
        id: mm

        year: monthView.selectedDate.getFullYear()
        month: monthView.selectedDate.getMonth() + 1
    }

    Repeater {
        id: backRepeater

        model: backMonthPad
        delegate: Item {}
    }

    Item {
        MonthView {
            id: monthView

            anchors.centerIn: parent
            displayedYear: mm.year
            displayedMonthName: Qt.locale(Qt.locale().uiLanguages[0]).monthName(mm.month-1)
            selectedDayTodosCount: todosCount(selectedDate)
            selectedDayEventsCount: eventsCount(selectedDate)
            daysModel: mm
        }
    }

    Repeater {
        id: forwardRepeater

        model: fwdMonthPad
        delegate: Item {}
    }
}
