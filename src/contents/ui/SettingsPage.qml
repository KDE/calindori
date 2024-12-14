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

FormCard.FormCardPage {
    id: root
    property var applicationFooter
    
    title: i18n("Settings")

    FormCard.FormHeader {
        title: i18n("About")
    }

    FormCard.FormCard {
        FormCard.FormButtonDelegate {
            text: i18n("About Calindori")
            icon.name: "help-about-symbolic"
            onClicked: applicationWindow().pageStack.push(aboutInfoPage)
            
            Component {
                id: aboutInfoPage
                FormCard.AboutPage {}
            }
        }
        
        FormCard.FormButtonDelegate {
            text: i18n("About KDE")
            icon.name: "kde-symbolic"
            onClicked: applicationWindow().pageStack.push(aboutKDEPage)

            Component {
                id: aboutKDEPage
                FormCard.AboutKDEPage {}
            }
        }
    }

    FormCard.FormHeader {
        title: i18n("Calendars")
    }

    FormCard.FormCard {
        FormCard.FormButtonDelegate {
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
        
        FormCard.FormButtonDelegate {
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
    }

    FormCard.FormHeader {
        title: i18n("Events")
    }

    FormCard.FormCard {

        FormCard.FormSpinBoxDelegate {
            label: i18n("Initial duration (minutes)")

            from: 0
            value: Calindori.CalindoriConfig.eventsDuration

            onValueChanged: Calindori.CalindoriConfig.eventsDuration = value
        }

        FormCard.FormSpinBoxDelegate {
            label: i18n("Remind before event (minutes)")

            from: 0
            value: Calindori.CalindoriConfig.preEventRemindTime

            onValueChanged: Calindori.CalindoriConfig.preEventRemindTime = value
        }

        FormCard.FormSwitchDelegate {
            text: i18n("Add reminder to new events")

            checked: Calindori.CalindoriConfig.alwaysRemind
            onCheckedChanged: Calindori.CalindoriConfig.alwaysRemind = checked
        }
    }
}
