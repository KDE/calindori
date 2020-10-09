/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import org.kde.kirigami 2.0 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.Action {

    property bool isCalendar: true

    signal deleteCalendar

    enabled: _calindoriConfig != null ? (_calindoriConfig.activeCalendar != text) : false

    Kirigami.Action {
        text: i18n("Activate")
        iconName: "dialog-ok"

        onTriggered: _calindoriConfig.activeCalendar = parent.text
    }

    Kirigami.Action {
        text: i18n("Delete")
        iconName: "delete"
        visible: !_calindoriConfig.isExternal(parent.text)

        onTriggered: {
            deleteSheet.calendarName = parent.text;
            deleteSheet.open();
        }
    }

    Kirigami.Action {
        text: i18n("Remove")
        iconName: "remove"
        visible: _calindoriConfig.isExternal(parent.text)

        onTriggered: _calindoriConfig.removeCalendar(parent.text);
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
