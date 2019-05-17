/*
 *   Copyright 2018 Dimitris Kardarakos <dimkard@gmail.com>
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

    title: qsTr("Tasks")

    actions.main: Kirigami.Action {
        icon.name: "resource-calendar-insert"
        text: qsTr("Add task")
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

    Kirigami.CardsListView {
        id: cardsListview
        anchors.fill: parent

        model: Calindori.TodosModel {
            filterdt: root.todoDt
            memorycalendar: root.calendar.memorycalendar

        }

        delegate: Kirigami.Card {
            id: cardDelegate

            banner.title: model.summary
            banner.titleLevel: 3

            actions: [
                Kirigami.Action {
                    text: qsTr("Delete")
                    icon.name: "delete"

                    onTriggered: {
                        var controller = todoController.createObject(parent, { calendar: root.calendar });
                        controller.vtodo = { "uid" : model.uid };
                        controller.remove();
                        tasksUpdated();
                    }
                },

                Kirigami.Action {
                    text: qsTr("Edit")
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

    Component {
        id: todoController

        Calindori.TodoController {}
    }
}
