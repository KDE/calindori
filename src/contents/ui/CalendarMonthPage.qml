/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import org.kde.kirigami 2.12 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.Page {
    id: root

    property var appContextDrawer
    property string contextIconName: "view-calendar-tasks"
    property alias dayRectangleWidth: calendarMonthView.dayRectangleWidth
    property alias selectedDate: calendarMonthView.selectedDate

    /**
     * @brief The active calendar, which is the host of todos, events, etc.
     *
     */
    property var calendar

    /**
     *  @brief The index of the last contextual action triggered
     *
     */
    property int latestContextualAction: -1

    /**
     *  @brief When set to a valid contextual action index, as soon as the page is loaded the corresponding contextual action is also opened
     *
     */
    property int loadWithAction: -1

   /**
    * @brief Emitted when the hosted SwipeView index is set to the first or the last container item
    *
    */
    signal pageEnd(var lastDate, var lastActionIndex)

    title: calendarMonthView.selectedDate.toLocaleDateString(_appLocale, Locale.ShortFormat)

    actions: [
        Kirigami.Action {
            icon.name: "arrow-left"
            text: i18n("Previous")
            displayHint: Kirigami.Action.IconOnly
            onTriggered: calendarMonthView.previousMonth()
        },
        
        Kirigami.Action {
            icon.name: "arrow-right"
            text: i18n("Next")
            displayHint: Kirigami.Action.IconOnly
            onTriggered: calendarMonthView.nextMonth()
        },
        Kirigami.Action {
            icon.name: "view-calendar-day"
            text: i18n("Today")
            
            onTriggered: calendarMonthView.goToday()
        },
        Kirigami.Action {
            icon.name: "view-calendar-tasks"
            text: i18n("Tasks")

            onTriggered: {
                latestContextualAction = 0;
                pageStack.pop(root);
                pageStack.push(todosCardView);
            }
        },
        Kirigami.Action {
            icon.name: "tag-events"
            text: i18n("Events")

            onTriggered: {
                latestContextualAction = 1;
                pageStack.pop(root);
                pageStack.push(eventsCardView);
            }
        }
    ]

    Component.onCompleted: {
        if(loadWithAction >= 0)
        {
            contextualActions[loadWithAction].trigger();
        }
    }

    CalendarMonthView {
        id: calendarMonthView

        anchors.fill: parent
        cal: root.calendar

        showHeader: true
        showMonthName: false
        showYear: false

        onSelectedDateChanged: {
            if (Kirigami.Settings.isMobile && pageStack.depth > 1) {
                pageStack.pop(null);
            }
        }

        onDayPressed: {
            if (dayOfPress.toLocaleDateString() === selectedDate.toLocaleDateString()) {
                appContextDrawer.handleOpenIcon.color = Kirigami.Theme.highlightColor;
                appContextDrawer.handleClosedIcon.color = Kirigami.Theme.highlightColor;
            }
        }

        onDayLongPressed: {
            if ((dayOfLongPress.toLocaleDateString() === selectedDate.toLocaleDateString()) && Kirigami.Settings.isMobile) {
                appContextDrawer.open();
            }
        }

        onDayReleased: {
            appContextDrawer.handleOpenIcon.color = '';
            appContextDrawer.handleClosedIcon.color = '';
        }

        onViewEnd: pageEnd(lastDate, (pageStack.depth > 1) ? root.latestContextualAction : -1)
    }

    Component {
        id: todosCardView

        TodosCardView {
            calendar: Calindori.CalendarController.activeCalendar
            todoDt: root.selectedDate
        }
    }

    Component {
        id: eventsCardView

        EventsCardView {
            calendar: Calindori.CalendarController.activeCalendar
            eventStartDt: root.selectedDate
        }
    }
}
