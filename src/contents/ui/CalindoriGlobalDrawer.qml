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

    title: _calindoriConfig && _calindoriConfig.activeCalendar
    handleVisible: !root.wideScreen
    modal: !root.wideScreen

    actions: [
        Kirigami.Action {
            id: show

            text: i18n("View")
            iconName: "view-choose"
            expandible: true

            Kirigami.Action {
                text: i18n("Month")

                onTriggered: {
                    pageStack.clear();
                    pageStack.push(monthView);
                }
            }

            Kirigami.Action {
                text: i18n("Day")

                onTriggered: {
                    pageStack.clear();
                    pageStack.push(dayView);
                }
            }

            Kirigami.Action {
                text: i18n("Week")

                onTriggered: {
                    pageStack.clear();
                    pageStack.push(weekView, { startDate: _eventController.localSystemDateTime() } );
                }
            }

            Kirigami.Action {
                text: i18n("All Tasks")

                onTriggered: {
                    pageStack.clear();
                    pageStack.push(incidenceView, { incidenceType: 1, filterMode: 9 });
                }
            }

            Kirigami.Action {
                text: i18n("All Events")

                onTriggered: {
                    pageStack.clear();
                    pageStack.push(incidenceView, { incidenceType: 0, filterMode: 8 });
                }
            }
        },

        Kirigami.Action {
            id: calendarManagement

            text: i18n("Calendar Management")
            iconName: "view-calendar"

            // Internal Calendars
            Kirigami.Action {
                id: localCalendars

                iconName: "view-calendar"
                text: i18n("Local")
                expandible: true
                children: [calendarCreateAction, calendarImportAction]

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
                pageStack.clear();
                pageStack.push(settingsPage)
            }
        },

        Kirigami.Action {
            id: aboutAction

            iconName: "help-about-symbolic"
            text: i18n("About")

            onTriggered: {
                pageStack.clear();
                pageStack.push(aboutInfoPage)
            }
        }
    ]

    Instantiator {
        model: _calindoriConfig && _calindoriConfig.internalCalendars

        delegate: CalendarAction {
            text: modelData
        }

        onObjectAdded: localCalendars.children.push(object)

        onObjectRemoved: {
            // HACK this is not pretty because onObjectRemoved is called for each calendar, but we cannot remove a single child
            localCalendars.children = [];
            localCalendars.children.push(calendarCreateAction);
            localCalendars.children.push(calendarImportAction);
        }
    }

    Instantiator {
        model: _calindoriConfig && _calindoriConfig.externalCalendars

        delegate: CalendarAction {
            text: modelData
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
                PropertyChanges { target: root; width: Kirigami.Units.gridUnit * 14 }
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
            pageStack.clear();
            pageStack.push(calendarEditor, {mode: CalendarEditor.Mode.Create});
        }
    }

    Kirigami.Action {
        id: calendarImportAction

        text: i18n("Import")
        iconName: "document-import"

        onTriggered: {
            pageStack.clear();
            pageStack.push(calendarEditor, {mode: CalendarEditor.Mode.Import})
        }
    }

    Kirigami.Action {
        id: calendarAddExistingAction

        text: i18n("Add")
        iconName: "resource-calendar-child-insert"

        onTriggered: {
            pageStack.clear();
            pageStack.push(calendarEditor, {mode: CalendarEditor.Mode.AddExisting});
        }
    }

    Component {
        id: calendarEditor

        CalendarEditor {
            onCalendarAdded: {
                pageStack.clear()
                pageStack.push(monthView);
            }
            onCalendarAddCanceled: pageStack.pop(calendarEditor)
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
