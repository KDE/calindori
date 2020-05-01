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
    property alias showYear: monthView.showYear
    property int backMonthPad: 720
    property int fwdMonthPad: 480
    property int previousIndex
    property var cal
    property var manageIndex: function () {}

    signal nextMonth
    signal previousMonth
    signal goToday

    onNextMonth: {
        mm.goNextMonth();
        root.selectedDate = new Date(mm.year, mm.month-1, 1, root.selectedDate.getHours(), root.selectedDate.getMinutes());
    }

    onPreviousMonth: {
        mm.goPreviousMonth();
        root.selectedDate = new Date(mm.year, mm.month-1, 1, root.selectedDate.getHours(), root.selectedDate.getMinutes());
    }

    onGoToday: {
        mm.goCurrentMonth();
        root.selectedDate = new Date();
    }

    onCurrentItemChanged: manageIndex()

    Connections {
        target: cal

        onTodosChanged: monthView.reloadSelectedDate()
        onEventsChanged: monthView.reloadSelectedDate()
    }

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

    DaysOfMonthIncidenceModel {
        id: mm

        year: monthView.selectedDate.getFullYear()
        month: monthView.selectedDate.getMonth() + 1
        calendar: cal
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
            displayedMonthName: Qt.locale().standaloneMonthName(mm.month-1)
            selectedDayTodosCount: cal.todosCount(selectedDate)
            selectedDayEventsCount: cal.eventsCount(selectedDate)
            daysModel: mm

            reloadSelectedDate: function() {
                selectedDayTodosCount = cal.todosCount(root.selectedDate)
                selectedDayEventsCount = cal.eventsCount(root.selectedDate)
            }
        }
    }

    Repeater {
        id: forwardRepeater

        model: fwdMonthPad
        delegate: Item {}
    }
}
