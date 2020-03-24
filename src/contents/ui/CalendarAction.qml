
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

    signal deleteCalendar

    checked: (text == _calindoriConfig.activeCalendar)
    visible: _calindoriConfig.activeCalendar != text

    Kirigami.Action {
        text: "Activate calendar"
        iconName: "dialog-ok"

        onTriggered: _calindoriConfig.activeCalendar = parent.text
    }

    Kirigami.Action {
        text: "Delete calendar"
        iconName: "delete"

        onTriggered: {
            deleteSheet.calendarName = parent.text;
            deleteSheet.open();
        }
    }

    ConfirmationSheet {
        id: deleteSheet

        property string calendarName
        message: i18n("All data included in this calendar will be deleted. Proceed with deletion?")

        operation: function() {
            var toRemoveCalendarComponent = Qt.createQmlObject("import org.kde.phone.calindori 0.1 as Calindori; Calindori.LocalCalendar { name: \"" + calendarName + "\"}",deleteSheet);
            toRemoveCalendarComponent.deleteCalendar();
            _calindoriConfig.removeCalendar(calendarName);
        }
    }
}
