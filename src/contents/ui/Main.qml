/*
 *   Copyright 2018-2020 Dimitris Kardarakos <dimkard@posteo.net>
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

import QtQuick 2.1
import org.kde.kirigami 2.6 as Kirigami
import org.kde.phone.calindori 0.1 as Calindori

Kirigami.ApplicationWindow {
    id: root

    globalDrawer: Kirigami.GlobalDrawer {
        id: drawer

        title: _calindoriConfig.activeCalendar
        drawerOpen: !Kirigami.Settings.isMobile
        handleVisible: Kirigami.Settings.isMobile
        modal: Kirigami.Settings.isMobile
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
                        pageStack.push(calendarMonthPage);
                    }
                }

                Kirigami.Action {
                    text: i18n("Day")

                    onTriggered: {
                        pageStack.clear();
                        pageStack.push(dayPage);
                    }
                }

                Kirigami.Action {
                    text: i18n("Week")

                    onTriggered: {
                        pageStack.clear();
                        pageStack.push(weekPage, { startDate: new Date() } );
                    }
                }

                Kirigami.Action {
                    text: i18n("All Tasks")

                    onTriggered: {
                        pageStack.clear();
                        pageStack.push(incdidenceListView, { incidenceType: 1, filterMode: 9 });
                    }
                }

                Kirigami.Action {
                    text: i18n("All Events")

                    onTriggered: {
                        pageStack.clear();
                        pageStack.push(incdidenceListView, { incidenceType: 0, filterMode: 8 });
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
                id: aboutAction
                iconName: "help-about-symbolic"
                text: i18n("About")

                onTriggered: pageStack.push(aboutInfo)
            }
        ]

        Instantiator {
            model: _calindoriConfig.calendars.split(_calindoriConfig.calendars.includes(";") ? ";" : null)

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
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer

        title: (pageStack.currentItem && pageStack.currentItem.hasOwnProperty("selectedDate") && !isNaN(pageStack.currentItem.selectedDate)) ? pageStack.currentItem.selectedDate.toLocaleDateString(Qt.locale()) : ""
    }

    pageStack {
        initialPage: [calendarMonthPage]
        separatorVisible: false
    }


    Calindori.LocalCalendar {
        id: localCalendar

        name: _calindoriConfig.activeCalendar

        onNameChanged: {
            if (root.pageStack.depth > 1) {
                root.pageStack.pop(null);
            }
        }
    }

    Component {
        id: calendarMonthPage

        CalendarMonthPage {
            calendar: localCalendar
        }
    }

    Component {
        id: dayPage

        DayPage {}
    }

    Component {
        id: weekPage

        WeekPage {}
    }

    Component {
        id: incdidenceListView

        IncidenceListView {
            calendar: localCalendar
        }
    }

    Component {
        id: calendarEditor

        CalendarEditor {
            onCalendarAdded: {
                root.pageStack.pop(calendarEditor);
                root.pageStack.push(calendarMonthPage);
            }
            onCalendarAddCanceled: root.pageStack.pop(calendarEditor)
        }
    }

    Component {
        id: aboutInfo

        Kirigami.AboutPage
        {
            aboutData: _aboutData
        }
    }

    Kirigami.Action {
        id: calendarCreateAction

        text: i18n("New calendar")
        iconName: "list-add"
        onTriggered: root.pageStack.push(calendarEditor, {mode: "add"})
    }

    Kirigami.Action {
        id: calendarImportAction

        text: i18n("Import calendar")
        iconName: "document-import"

        onTriggered: root.pageStack.push(calendarEditor, {mode: "import"})
    }

    Kirigami.Action {
        id: actionSeparator

        separator: true
    }
}

