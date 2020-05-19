/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import org.kde.kirigami 2.4 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.Action {

    property bool isCalendar: true

    signal deleteCalendar

    visible: _calindoriConfig != null ? (_calindoriConfig.activeCalendar != text) : false

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
            var toRemoveCalendarComponent = Qt.createQmlObject("import org.kde.calindori 0.1 as Calindori; Calindori.LocalCalendar { name: \"" + calendarName + "\"}",deleteSheet);
            toRemoveCalendarComponent.deleteCalendar();
            _calindoriConfig.removeCalendar(calendarName);
        }
    }
}
