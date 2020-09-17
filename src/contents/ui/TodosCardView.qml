/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.12 as Kirigami
import org.kde.calindori 0.1 as Calindori

Kirigami.ScrollablePage {
    id: root

    property date todoDt
    property var calendar

    title: i18n("Tasks")

    actions.main: Kirigami.Action {
        icon.name: "resource-calendar-insert"
        text: i18n("New Task")
        onTriggered: pageStack.push(todoEditor, {startDt: todoDt})
    }

    leftPadding: 0
    rightPadding: 0

    Component {
        id: todoEditor
        TodoEditor {
            calendar: localCalendar

            onEditcompleted: pageStack.pop(todoEditor)
        }
    }

    Kirigami.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - (Kirigami.Units.largeSpacing * 4)
        visible: cardsListview.count == 0
        text: !isNaN(todoDt) ? i18n("No tasks scheduled for %1", todoDt.toLocaleDateString(_appLocale, Locale.ShortFormat)) : i18n("No tasks scheduled")
    }

    Kirigami.CardsListView {
        id: cardsListview

        model: todosModel

        delegate: TodoCard {
            id: cardDelegate

            dataModel: model

            actions: [
                Kirigami.Action {
                    text: i18n("Delete")
                    icon.name: "delete"

                    onTriggered: {
                        var vtodo = { "uid" : model.uid };
                        _todoController.remove(root.calendar, vtodo);
                    }
                },

                Kirigami.Action {
                    text: i18n("Edit")
                    icon.name: "editor"

                    onTriggered: pageStack.push(todoEditor, { startDt: model.dtstart, uid: model.uid, incidenceData: model })
                }
            ]
        }
    }

    Calindori.IncidenceModel {
        id: todosModel

        appLocale: _appLocale
        filterDt: root.todoDt
        calendar: root.calendar
        filterMode: 6
    }
}
