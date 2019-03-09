
/*
 *   Copyright 2019 Dimitris Kardarakos <dimkard@posteo.net>
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
import org.kde.kirigami 2.4 as Kirigami
import org.kde.phone.calindori 0.1 as Calindori

Kirigami.Action {

    property bool isCalendar: true
    property var configuration

    checked: (text == configuration.activeCalendar)

    Kirigami.Action {
        text: "Activate"
        iconName: "dialog-ok"

        onTriggered: {
            configuration.activeCalendar = parent.text;
        }
    }

    Kirigami.Action {
        text: "Delete"
        iconName: "delete"

        onTriggered: {
            if (configuration.activeCalendar == parent.text) {
                showPassiveNotification("Active calendar cannot be deleted");
            }
            else {
                var toRemoveCalendarComponent = Qt.createQmlObject("import org.kde.phone.calindori 0.1 as Calindori; Calindori.LocalCalendar { name: \"" + parent.text + "\"}",root);
                toRemoveCalendarComponent.deleteCalendar();
                configuration.removeCalendar(parent.text);
                showPassiveNotification("Calendar " + parent.text + " has been deleted");                        
            }
        }
    }
}
