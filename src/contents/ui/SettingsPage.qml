/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 * SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.19 as Kirigami
import org.kde.kirigamiaddons.formcard 1.0 as FormCard
import org.kde.calindori 0.1 as Calindori

Kirigami.ScrollablePage {
    id: root
    property var applicationFooter
    
    title: i18n("Settings")

    Kirigami.FormLayout {
        wideMode: false
        width: root.width

        Controls.Button {
            Kirigami.FormData.label: i18n("More Info:")
            
            text: i18n("About")
            icon.name: "help-about-symbolic"
            onClicked: applicationWindow().pageStack.push(aboutInfoPage)
            
            Component {
                id: aboutInfoPage
                FormCard.AboutPage {
                    aboutData: _aboutData
                }
            }
        }
        
        Controls.Button {
            Kirigami.FormData.label: i18n("Calendars:")
            text: i18n("Manage internal calendars")
            icon.name: "view-calendar"
            onClicked: applicationWindow().pageStack.push(internalCalendarsPage)
            
            Component {
                id: internalCalendarsPage
                ManageCalendarsPage {
                    title: i18n("Manage Internal Calendars")
                    applicationFooter: root.applicationFooter
                    calendarModel: Calindori.CalindoriConfig && Calindori.CalindoriConfig.internalCalendars
                    isExternal: false
                }
            }
        }
        
        Controls.Button {
            text: i18n("Manage external calendars")
            icon.name: "view-calendar"
            onClicked: applicationWindow().pageStack.push(externalCalendarsPage)
            
            Component {
                id: externalCalendarsPage
                ManageCalendarsPage {
                    title: i18n("Manage External Calendars")
                    applicationFooter: root.applicationFooter
                    calendarModel: Calindori.CalindoriConfig && Calindori.CalindoriConfig.externalCalendars
                    isExternal: true
                }
            }
        }
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Events")
        }

        Controls.SpinBox {
            Kirigami.FormData.label: i18n("Initial duration (minutes):")

            from: 0
            value: Calindori.CalindoriConfig.eventsDuration

            onValueModified: Calindori.CalindoriConfig.eventsDuration = value
        }


        Controls.SpinBox {
            Kirigami.FormData.label: i18n("Remind before event (minutes):")

            from: 0
            value: Calindori.CalindoriConfig.preEventRemindTime

            onValueModified: Calindori.CalindoriConfig.preEventRemindTime = value
        }

        Controls.SwitchDelegate {
            Kirigami.FormData.label: i18n("Add reminder to new events:")

            checked: Calindori.CalindoriConfig.alwaysRemind
            onCheckedChanged: Calindori.CalindoriConfig.alwaysRemind = checked
        }
    }
}
