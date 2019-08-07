/*
 * Copyright (C) 2019 Dimitris Kardarakos
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 3 of
 * the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "todocontroller.h"
#include "localcalendar.h"
#include <KCalCore/Todo>
#include <KCalCore/MemoryCalendar>
#include <QDebug>

TodoController::TodoController(QObject* parent) : QObject(parent) {}

TodoController::~TodoController() = default;

void TodoController::addEdit(LocalCalendar *calendar, const QVariantMap& todo)
{
    qDebug() << "Adding/updating todo";

    MemoryCalendar::Ptr memoryCalendar = calendar->memorycalendar();
    Todo::Ptr vtodo;
    QDateTime now = QDateTime::currentDateTime();
    QString uid = todo["uid"].toString();
    QString summary = todo["summary"].toString();
    QDate startDate = todo["startDate"].toDate();
    int startHour = todo["startHour"].value<int>();
    int startMinute = todo["startMinute"].value<int>();
    bool allDayFlg= todo["allDay"].toBool();

    if(uid == "")
    {
        vtodo = Todo::Ptr(new Todo());
        vtodo->setUid(summary.at(0) + now.toString("yyyyMMddhhmmsszzz"));
    }
    else
    {
        vtodo = memoryCalendar->todo(uid);
        vtodo->setUid(uid);
    }

    QDateTime startDateTime;
    if(allDayFlg) {
        startDateTime = QDateTime(startDate);
    }
    else {
        startDateTime = QDateTime(startDate, QTime(startHour, startMinute, 0, 0), QTimeZone::systemTimeZone());
    }

    vtodo->setDtStart(startDateTime);
    vtodo->setDescription(todo["description"].toString());
    vtodo->setSummary(summary);
    vtodo->setAllDay(allDayFlg);
    vtodo->setLocation(todo["location"].toString());
    vtodo->setCompleted(todo["completed"].toBool());

    memoryCalendar->addTodo(vtodo);
    bool merged = calendar->save();

    qDebug() << "Todo added/updated: " << merged;
}

void TodoController::remove(LocalCalendar *calendar, const QVariantMap& todo)
{
    qDebug() << "Deleting todo";

    MemoryCalendar::Ptr memoryCalendar = calendar->memorycalendar();
    QString uid = todo["uid"].toString();
    Todo::Ptr vtodo = memoryCalendar->todo(uid);

    memoryCalendar->deleteTodo(vtodo);
    bool removed = calendar->save();

    qDebug() << "Todo deleted: " << removed;
}
