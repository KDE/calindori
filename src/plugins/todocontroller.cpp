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

QObject * TodoController::calendar() const
{
    return m_calendar;
}

void TodoController::setCalendar(QObject *const calendarPtr)
{
    if(m_calendar != calendarPtr)
    {
        m_calendar = calendarPtr;
        emit calendarChanged();
    }
}

QVariantMap TodoController::vtodo() const
{
    return m_todo;
}

void TodoController::setVtodo(const QVariantMap& todo)
{
    m_todo = todo;
    emit vtodoChanged();
}

void TodoController::addEdit()
{
    qDebug() << "Adding/updating todo";

    auto localCalendar = qobject_cast<LocalCalendar*>(m_calendar);
    MemoryCalendar::Ptr memoryCalendar = localCalendar->memorycalendar();
    Todo::Ptr vtodo;
    QDateTime now = QDateTime::currentDateTime();
    QString uid = m_todo["uid"].value<QString>();
    QString summary = m_todo["summary"].value<QString>();
    QDate startDate = m_todo["startDate"].value<QDate>();
    int startHour = m_todo["startHour"].value<int>();
    int startMinute = m_todo["startMinute"].value<int>();
    bool allDayFlg= m_todo["allDay"].value<bool>();

    if(uid == "")
    {
        vtodo = Todo::Ptr(new Todo());
        vtodo->setUid(summary.left(1) + now.toString("yyyyMMddhhmmsszzz"));
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
    vtodo->setDescription(m_todo["description"].value<QString>());
    vtodo->setSummary(summary);
    vtodo->setAllDay(allDayFlg);
    vtodo->setLocation(m_todo["location"].value<QString>());
    vtodo->setCompleted(m_todo["completed"].value<bool>());

    memoryCalendar->addTodo(vtodo);
    bool merged = localCalendar->save();

    qDebug() << "Todo added/updated: " << merged;

    emit vtodoChanged();
    emit vtodosUpdated();
}

void TodoController::remove()
{
    qDebug() << "Deleting todo";

    auto localCalendar = qobject_cast<LocalCalendar*>(m_calendar);
    MemoryCalendar::Ptr memoryCalendar = localCalendar->memorycalendar();
    QString uid = m_todo["uid"].value<QString>();
    Todo::Ptr vtodo = memoryCalendar->todo(uid);

    memoryCalendar->deleteTodo(vtodo);
    bool removed = localCalendar->save();

    qDebug() << "Todo deleted: " << removed;

    emit vtodoChanged();
    emit vtodosUpdated();
}
