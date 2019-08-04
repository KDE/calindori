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
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.4 as Kirigami
import org.kde.phone.calindori 0.1 as Calindori

Kirigami.Page {
    id: root

    property date todoDt
    property var calendar

    signal tasksUpdated

    function reload()
    {
        cardsListview.model.loadTasks();
    }

    title: i18n("Tasks")

    actions.main: Kirigami.Action {
        icon.name: "resource-calendar-insert"
        text: i18n("Add task")
        onTriggered: pageStack.push(todoEditor, {startdt: todoDt})
    }

    Component {
        id: todoEditor
        TodoEditor {
            calendar: localCalendar

            onTaskeditcompleted: {
                tasksUpdated();
                pageStack.pop(todoEditor);
            }
        }
    }

    Component {
        id: todoController

        Calindori.TodoController {}
    }

    Controls2.Label {
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        visible: todosModel.count == 0
        wrapMode: Text.WordWrap
        text: todoDt.toLocaleDateString() != "" ? i18n("No tasks scheduled for %1", todoDt.toLocaleDateString(Qt.locale(), Locale.ShortFormat)) : i18n("No tasks scheduled")
        font.pointSize: Kirigami.Units.fontMetrics.font.pointSize * 1.5
    }

    Kirigami.CardsListView {
        id: cardsListview

        anchors.fill: parent

        model: todosModel

        delegate: Kirigami.Card {
            id: cardDelegate

            banner.title: model.summary
            banner.titleLevel: 3

            actions: [
                Kirigami.Action {
                    text: i18n("Delete")
                    icon.name: "delete"

                    onTriggered: {
                        var controller = todoController.createObject(parent, {});
                        var vtodo = { "uid" : model.uid };
                        controller.remove(root.calendar, vtodo);
                        tasksUpdated();
                    }
                },

                Kirigami.Action {
                    text: i18n("Edit")
                    icon.name: "editor"

                    onTriggered: pageStack.push(todoEditor, { startdt: model.dtstart, uid: model.uid, todoData: model })
                }
            ]

            contentItem: Column {

                enabled: !model.completed

                Controls2.Label {
                    width: cardDelegate.availableWidth
                    wrapMode: Text.WordWrap
                    text: model.description
                }

                Controls2.Label {
                    width: cardDelegate.availableWidth
                    visible: model.dtstart && !isNaN(model.dtstart)
                    wrapMode: Text.WordWrap
                    text: (model.dtstart && !isNaN(model.dtstart)) ? model.dtstart.toLocaleString(Qt.locale(), model.allday ? "ddd d MMM yyyy" : "ddd d MMM yyyy hh:mm" ) : ""
                }

                Controls2.Label {
                    width: cardDelegate.availableWidth
                    visible: model.location != ""
                    wrapMode: Text.WordWrap
                    text: model.location
                }
            }
        }
    }

    Calindori.TodosModel {
        id: todosModel

        filterdt: root.todoDt
        memorycalendar: root.calendar.memorycalendar
    }
}
