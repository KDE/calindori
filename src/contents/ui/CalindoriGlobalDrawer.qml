/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.14
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.7 as Kirigami
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
                    pageStack.push(weekView, { startDate: new Date() } );
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
            id: sectionSeparator

            separator: true
        },

        Kirigami.Action {
            id: calendarManagement

            text: i18n("Calendar Management")
            iconName: "view-calendar"

            children: [calendarCreateAction, calendarImportAction, actionSeparator]

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
        model: _calindoriConfig && _calindoriConfig.calendars.split(_calindoriConfig.calendars.includes(";") ? ";" : null)

        delegate: CalendarAction {
            text: modelData
        }

        onObjectAdded: {
            calendarManagement.children.push(object)
        }

        onObjectRemoved: {
            // HACK this is not pretty because onObjectRemoved is called for each calendar, but we cannot remove a single child
            calendarManagement.children = []
            calendarManagement.children.push(calendarCreateAction)
            calendarManagement.children.push(calendarImportAction)
            calendarManagement.children.push(actionSeparator)
        }
    }

    Kirigami.Action {
        id: calendarCreateAction

        text: i18n("New calendar")
        iconName: "list-add"
        onTriggered: pageStack.push(calendarEditor, {mode: "add"})
    }

    Kirigami.Action {
        id: calendarImportAction

        text: i18n("Import calendar")
        iconName: "document-import"

        onTriggered: pageStack.push(calendarEditor, {mode: "import"})
    }

    Kirigami.Action {
        id: actionSeparator

        separator: true
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

    Component {
        id: calendarEditor

        CalendarEditor {
            onCalendarAdded: {
                pageStack.pop(calendarEditor);
                pageStack.push(monthView);
            }
            onCalendarAddCanceled: pageStack.pop(calendarEditor)
        }
    }

    Component {
        id: dayView

        DayPage {}
    }

    Component {
        id: weekView

        WeekPage {}
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
