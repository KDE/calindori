/*
 *   Copyright 2018 Dimitris Kardarakos <dimkard@gmail.com>
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

/**
 * Calendar component that displays:
 *  - a header with currrent day's information
 *  - a table (grid) with the days of the current month
 *  - a set of actions to navigate between months
 */
MonthView {
    id: root

    signal nextMonth
    signal previousMonth
    signal goToday
    signal refresh

    displayedYear: plasmaCalendar.year
    displayedMonthName: plasmaCalendar.displayedDateMonthName
    selectedDayTodosCount: todosCount(selectedDate)
    selectedDayEventsCount: eventsCount(selectedDate)
    daysModel: plasmaCalendar.daysModel
    Layout.preferredHeight: childrenRect.height
    Layout.preferredWidth: childrenRect.width

    onRefresh: {
        daysModel.update();
        reloadSelectedDate();
    }

    onNextMonth: {
        plasmaCalendar.displayedDate = new Date(plasmaCalendar.displayedDate.setMonth(plasmaCalendar.displayedDate.getMonth() + 1));
    }

    onPreviousMonth: {
        plasmaCalendar.displayedDate = new Date(plasmaCalendar.displayedDate.setMonth(plasmaCalendar.displayedDate.getMonth() -1));
    }

    onGoToday: {
        plasmaCalendar.displayedDate = root.currentDate;
    }

    // HACK: Added as a temporary model provider, to be replaced with a non-plasma dependant backend
    CalendarBackend {
        id: plasmaCalendar

        property int displayedDateMonth: Qt.formatDate(plasmaCalendar.displayedDate,"MM")
        property string displayedDateMonthName: Qt.locale(Qt.locale().uiLanguages[0]).monthName(displayedDateMonth-1)

        days: root.days
        weeks: root.weeks
        today: root.currentDate
    }
}

