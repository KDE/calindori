/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.14
import QtQml.Models 2.14
import QtQuick.Layouts 1.14
import org.kde.kirigami 2.6 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.GlobalDrawer {
    id: root

    property var monthView
    property var calendar
    property bool wideScreen: false
    property var applicationFooter

    handleVisible: !root.wideScreen
    modal: !root.wideScreen

    header: Kirigami.AbstractApplicationHeader {
        topPadding: Kirigami.Units.smallSpacing
        bottomPadding: Kirigami.Units.largeSpacing
        leftPadding: Kirigami.Units.largeSpacing
        rightPadding: Kirigami.Units.smallSpacing
        implicitHeight: Kirigami.Units.gridUnit * 2
        Kirigami.Heading {
            level: 1
            text: Calindori.CalindoriConfig && Calindori.CalindoriConfig.activeCalendar
            Layout.fillWidth: true
        }
    }

    actions: [
        Kirigami.Action {
            id: show

            text: i18n("View")
            iconName: "view-choose"
            expandible: true

            Kirigami.Action {
                text: i18n("Month")

                onTriggered: {
                    popExtraLayers();
                    pageStack.clear();
                    pageStack.push(monthView);
                }
            }

            Kirigami.Action {
                text: i18n("Day")

                onTriggered: {
                    popExtraLayers();
                    pageStack.clear();
                    pageStack.push(dayView);
                }
            }

            Kirigami.Action {
                text: i18n("Week")

                onTriggered: {
                    popExtraLayers();
                    pageStack.clear();
                    pageStack.push(weekView, { startDate: Calindori.CalendarController.localSystemDateTime() } );
                }
            }

            Kirigami.Action {
                text: i18n("All Tasks")

                onTriggered: {
                    popExtraLayers();
                    pageStack.clear();
                    pageStack.push(incidenceView, { incidenceType: 1, filterMode: 9 });
                }
            }

            Kirigami.Action {
                text: i18n("All Events")

                onTriggered: {
                    popExtraLayers();
                    pageStack.clear();
                    pageStack.push(incidenceView, { incidenceType: 0, filterMode: 8 });
                }
            }
        },

        Kirigami.Action {
            id: calendarManagement

            text: i18n("Calendars")
            iconName: "view-calendar"

            // Internal Calendars
            Kirigami.Action {
                id: localCalendars

                iconName: "view-calendar"
                text: i18n("Local")
                expandible: true
                children: [calendarCreateAction]

            }

            // External Calendars
            Kirigami.Action {
                id: externalCalendars

                visible: true
                iconName: "view-calendar"
                text: i18n("External")
                expandible: true
                children: [calendarAddExistingAction]
            }
        },

        Kirigami.Action {
            text: i18n("Settings")
            iconName: "settings-configure"

            onTriggered: {
                popExtraLayers();
                pageStack.layers.push(settingsPage);
            }
        },

        Kirigami.Action {
            id: aboutAction

            iconName: "help-about-symbolic"
            text: i18n("About")

            onTriggered: {
                popExtraLayers();
                pageStack.layers.push(aboutInfoPage);
            }
        }
    ]

    Instantiator {
        model: Calindori.CalindoriConfig && Calindori.CalindoriConfig.internalCalendars

        delegate: CalendarAction {
            loadedCalendar: root.calendar
            text: modelData
            messageFooter: root.applicationFooter
        }

        onObjectAdded: localCalendars.children.push(object)

        onObjectRemoved: {
            // HACK this is not pretty because onObjectRemoved is called for each calendar, but we cannot remove a single child
            localCalendars.children = [];
            localCalendars.children.push(calendarCreateAction);
        }
    }

    Instantiator {
        model: Calindori.CalindoriConfig && Calindori.CalindoriConfig.externalCalendars

        delegate: CalendarAction {
            loadedCalendar: root.calendar
            text: modelData
            messageFooter: root.applicationFooter
        }

        onObjectAdded: externalCalendars.children.push(object)

        onObjectRemoved: {
            // HACK this is not pretty because onObjectRemoved is called for each calendar, but we cannot remove a single child
            externalCalendars.children = [];
            externalCalendars.children.push(calendarAddExistingAction);
        }
    }

    Item {
        visible: false

        states: [
            State {
                when: root.wideScreen
                PropertyChanges { target: root; drawerOpen: true }
            },
            State {
                when: !root.wideScreen
                PropertyChanges { target: root; drawerOpen: false }
            }
        ]
    }

    Kirigami.Action {
        id: calendarCreateAction

        text: i18n("Create")
        iconName: "resource-calendar-insert"

        onTriggered: {
            pageStack.layers.push(calendarEditor, {mode: CalendarEditor.Mode.Create});
        }
    }

    Kirigami.Action {
        id: calendarAddExistingAction

        text: i18n("Add")
        iconName: "resource-calendar-child-insert"

        onTriggered: {

            pageStack.layers.push(calendarEditor, {mode: CalendarEditor.Mode.AddExisting});
        }
    }

    Component {
        id: calendarEditor

        CalendarEditor {

            loadedCalendar: root.calendar

            onCalendarEditorSaved: pageStack.layers.pop()

            onCalendarEditorCancelled: pageStack.layers.pop()

        }
    }

    Component {
        id: dayView

        DayPage {
            wideScreen: root.wideScreen
        }
    }

    Component {
        id: weekView

        WeekPage {
            wideScreen: root.wideScreen
        }
    }

    Component {
        id: incidenceView

        IncidenceListView {
            calendar: root.calendar
        }
    }

    Component {
        id: settingsPage

        SettingsPage {}
    }

    Component {
        id: aboutInfoPage

        Kirigami.AboutPage
        {
            aboutData: _aboutData
        }
    }
}
