/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "todocontroller.h"
#include "localcalendar.h"
#include <KCalendarCore/Todo>
#include <KCalendarCore/MemoryCalendar>
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

    Q_EMIT calendar->todosChanged();

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

    Q_EMIT calendar->todosChanged();
    qDebug() << "Todo deleted: " << removed;
}
