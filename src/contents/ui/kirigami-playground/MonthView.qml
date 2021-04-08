/*
 * SPDX-FileCopyrightText: 2018 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import org.kde.kirigami 2.2 as Kirigami

/*
 * Component that displays the days of a month as a 6x7 table
 *
 * Optionally, it may display:
 * - a header on top of the table showing the current date
 * - inside each day cell, a small indicator in case that tasks
 *   exist for this day
 */
Item {
    id: root

    property int days: 7
    property int weeks: 6
    property date currentDate: new Date()
    property int dayRectWidth: Kirigami.Units.gridUnit * 2.5
    property date selectedDate: new Date()
    property int selectedDayTodosCount: 0
    property int selectedDayEventsCount: 0
    property string displayedMonthName
    property int displayedYear
    property var reloadSelectedDate: function() {}
    property var applicationLocale: Qt.locale()
    property bool loadAsync: false

    /**
     * A model that provides:
     *
     * 1. dayNumber
     * 2. monthNumber
     * 3. yearNumber
     */
    property var daysModel

    property bool showHeader: false
    property bool showMonthName: true
    property bool showYear: true

    signal datePressed(date dateOfPress)
    signal dateLongPressed(date dateOfLongPress)
    signal dateReleased(date dateOfRelease)

    onSelectedDateChanged: reloadSelectedDate()

    Loader {
        id: monthViewLoader

        anchors.centerIn: parent

        visible: status == Loader.Ready
        sourceComponent: mainViewComponent
        asynchronous: root.loadAsync
    }

    Controls2.BusyIndicator {
        anchors.centerIn: parent

        running: !monthViewLoader.visible
        implicitWidth: Kirigami.Units.iconSizes.enormous
        implicitHeight: width

    }

    Component {
        id: mainViewComponent

        Column {
            id: mainView

            anchors.centerIn: parent

            spacing: Kirigami.Units.smallSpacing

            /**
            * Optional header on top of the table
            * that displays the current date and
            * the amount of the day's tasks
            */
            CalendarHeader {
                id: calendarHeader

                applicationLocale: root.applicationLocale
                headerDate: root.selectedDate
                headerTodosCount: root.selectedDayTodosCount
                headerEventsCount: root.selectedDayEventsCount
                visible: root.showHeader
            }


            Row {

                Controls2.Label {
                    visible: showMonthName
                    font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
                    text: displayedMonthName
                }

                Controls2.Label {
                    visible: showYear
                    font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
                    text: (showMonthName ? " " : "" ) + displayedYear
                }
            }

            /**
            * Styled week day names of the days' calendar grid
            * E.g.
            * Mon Tue Wed ...
            */
            Row {
                spacing: 0

                Repeater {
                    model: root.days
                    delegate:
                        Rectangle {
                            width: root.dayRectWidth
                            height: width
                            color: Kirigami.Theme.disabledTextColor
                            opacity: 0.8

                            Controls2.Label {
                                anchors.centerIn: parent
                                color: Kirigami.Theme.textColor
                                text: root.applicationLocale.dayName(((model.index + root.applicationLocale.firstDayOfWeek) % root.days), Locale.ShortFormat)
                            }
                    }
                }
            }

            /**
            * Grid that displays the days of a month (normally 6x7)
            */
            Grid {
                columns: root.days
                rows: root.weeks

                Repeater {
                    model: root.daysModel
                    delegate: DayDelegate {
                        property date modelDate: new Date(model.yearNumber, model.monthNumber -1, model.dayNumber, root.selectedDate.getHours(), root.selectedDate.getMinutes(), 0)
                        currentDate: root.currentDate
                        delegateWidth: root.dayRectWidth
                        selectedDate: root.selectedDate

                        onDayClicked: root.selectedDate = modelDate
                        onDayPressed: root.datePressed(modelDate)
                        onDayLongPressed: root.dateLongPressed(modelDate)
                        onDayReleased: root.dateReleased(modelDate)

                    }
                }
            }
        }
    }
}
