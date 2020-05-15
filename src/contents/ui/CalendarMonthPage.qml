/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.1
import org.kde.kirigami 2.6 as Kirigami

Kirigami.Page {
    id: root

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
     *  @brief When set to a valid contextual action index, that contextual action is triggered
     *
     */
    property int triggerAction: -1

   /**
    * @brief Emited when the hosted SwipeView index is set to the first or the last container item
    *
    */
    signal pageEnd(var lastDate, var lastActionIndex)

    title: calendarMonthView.displayedMonthName + " " + calendarMonthView.displayedYear

    actions {
        left: Kirigami.Action {
            iconName: "go-down"
            text: i18n("Previous month")

            onTriggered: calendarMonthView.previousMonth()
        }

        main: Kirigami.Action {
            iconName: "view-calendar-day"
            text: i18n("Today")

            onTriggered: calendarMonthView.goToday()
        }

        right: Kirigami.Action {
            iconName: "go-up"
            text: i18n("Next month")

            onTriggered: calendarMonthView.nextMonth()
        }

        contextualActions: [
            Kirigami.Action {
                iconName: "view-calendar-tasks"
                text: i18n("Tasks")

                onTriggered: {
                    latestContextualAction = 0
                    pageStack.push(todosCardView);
                }
            },

            Kirigami.Action {
                iconName: "tag-events"
                text: i18n("Events")

                onTriggered: {
                    latestContextualAction = 1
                    pageStack.push(eventsCardView);
                }
            }
        ]
    }

    Component.onCompleted: {
        if(triggerAction >= 0)
        {
            contextualActions[triggerAction].trigger();
        }
    }
    CalendarMonthView {
        id: calendarMonthView

        anchors.fill: parent
        cal: root.calendar

        anchors.centerIn: parent
        showHeader: true
        showMonthName: false
        showYear: false

        onSelectedDateChanged: {
            if (Kirigami.Settings.isMobile && pageStack.depth > 1) {
                pageStack.pop(null);
            }
        }

        onViewEnd: pageEnd(lastDate, (pageStack.depth > 1) ? root.latestContextualAction : -1)
    }

    Component {
        id: todosCardView

        TodosCardView {
            calendar: localCalendar
            todoDt: root.selectedDate
        }
    }

    Component {
        id: eventsCardView

        EventsCardView {
            calendar: localCalendar
            eventStartDt: root.selectedDate
        }
    }
}
