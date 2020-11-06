/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.0 as Kirigami
import org.kde.calindori 0.1

/**
 * Calendar component that displays:
 *  - a header with current day's information
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
    property alias dayRectangleWidth: monthView.dayRectWidth
    property int previousIndex
    property var cal
    /**
     * @brief When set, we take over the handling of the container items indexes programmatically
     *
     */
    property bool manualIndexing: false

    signal nextMonth
    signal previousMonth
    signal goToday
    /**
     * @brief It should be emitted when the SwipeView currentIndex is set to the first or the last one
     *
     * @param lastDate p_lastDate:...
     */
    signal viewEnd(var lastDate)

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
        root.selectedDate = _eventController.localSystemDateTime();
    }

    onCurrentItemChanged: manageIndex()

    function manageIndex ()
    {
        if(!manualIndexing)
        {
            return;
        }

        var returnDate = root.selectedDate;

        if (currentIndex > previousIndex)
        {
            returnDate = (returnDate.getMonth() == 11) ? new Date(returnDate.getFullYear() + 1, 0, 1) : new Date(returnDate.getFullYear(), returnDate.getMonth() + 1, 1);
        }
        else
        {
            returnDate = (returnDate.getMonth() == 0) ? new Date(returnDate.getFullYear() - 1, 11, 1) : new Date(returnDate.getFullYear(), returnDate.getMonth() - 1, 1);
        }

        previousIndex = currentIndex;

        if(currentIndex != 1)
        {
            viewEnd(returnDate) //Inform parents about the date to set as selected when re-pushing this page
        }
    }

    Connections {
        target: cal

        onTodosChanged: monthView.reloadSelectedDate()
        onEventsChanged: monthView.reloadSelectedDate()
    }

    Component.onCompleted: {
        currentIndex = 1;
        previousIndex = currentIndex;
        manualIndexing = true;
        orientation = Qt.Vertical //Change orientation after the object has been instantiated. Otherwise, we get a non-intuitive animation when swiping upwards
    }

    orientation: Qt.Horizontal

    DaysOfMonthIncidenceModel {
        id: mm

        year: monthView.selectedDate.getFullYear()
        month: monthView.selectedDate.getMonth() + 1
        calendar: cal
    }

    Item {}

    Item {
        MonthView {
            id: monthView

            anchors.centerIn: parent

            applicationLocale: _appLocale
            displayedYear: mm.year
            displayedMonthName: _appLocale.standaloneMonthName(mm.month-1)
            selectedDayTodosCount: cal.todosCount(selectedDate)
            selectedDayEventsCount: cal.eventsCount(selectedDate)
            daysModel: mm
            selectedDate: _eventController.localSystemDateTime()
            currentDate: _eventController.localSystemDateTime()

            reloadSelectedDate: function() {
                selectedDayTodosCount = cal.todosCount(root.selectedDate)
                selectedDayEventsCount = cal.eventsCount(root.selectedDate)
            }
        }
    }

    Item {}
}
