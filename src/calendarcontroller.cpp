/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "calendarcontroller.h"
#include "localcalendar.h"
#include <QDebug>
#include <KLocalizedString>
#include <KCalendarCore/ICalFormat>
#include <KCalendarCore/Calendar>
#include <KCalendarCore/MemoryCalendar>

CalendarController::CalendarController(QObject *parent) : QObject {parent}, m_events {}, m_todos {}
{
}

void CalendarController::importCalendarData(const QByteArray &data)
{
    KCalendarCore::MemoryCalendar::Ptr importedCalendar {new KCalendarCore::MemoryCalendar {QTimeZone::systemTimeZoneId()}};
    KCalendarCore::ICalFormat icalFormat {};
    auto readResult = icalFormat.fromRawString(importedCalendar, data);

    if (!readResult) {
        qDebug() << "The file read was not a valid calendar";
        Q_EMIT statusMessageChanged(i18n("The url or file given does not contain valid calendar data"), MessageType::NegativeAnswer);
        return;
    }

    m_events = importedCalendar->rawEvents();
    m_todos = importedCalendar->rawTodos();

    if (m_events.isEmpty() && m_todos.isEmpty()) {
        qDebug() << "No events or tasks found.";
        Q_EMIT statusMessageChanged(i18n("The url or file given does not contain any event or task"), MessageType::NegativeAnswer);
        return;
    }

    auto eventMsg = !m_events.isEmpty() ? i18np("1 event", "%1 events", m_events.count()) : QString {};
    auto tasksMsg = !m_todos.isEmpty() ? i18np("1 task", "%1 tasks", m_todos.count()) : QString {};

    auto proceedMsg = i18n("will be added");
    QString confirmMsg {};

    if (!m_events.isEmpty() && m_todos.isEmpty()) {
        confirmMsg = QString {"%1 %2"}.arg(eventMsg, proceedMsg);
    } else if (m_events.isEmpty() && !m_todos.isEmpty()) {
        confirmMsg = QString {"%1 %2"}.arg(tasksMsg, proceedMsg);
    } else {
        confirmMsg = QString {"%1 %2 %3 %4"}.arg(eventMsg, i18n("and"), tasksMsg, proceedMsg);
    }

    Q_EMIT statusMessageChanged(confirmMsg, MessageType::Question);
}

void CalendarController::importFromBuffer(LocalCalendar *localCalendar)
{
    auto calendar = localCalendar->calendar();

    for (const auto &event : qAsConst(m_events)) {
        calendar->addEvent(event);
    }

    for (const auto &todo : qAsConst(m_todos)) {
        calendar->addTodo(todo);
    }

    bool result = localCalendar->save();

    if (!m_events.isEmpty()) {
        Q_EMIT localCalendar->eventsChanged();
        m_events.clear();
    }

    if (!m_todos.isEmpty()) {
        Q_EMIT localCalendar->todosChanged();
        m_todos.clear();
    }

    if (result) {
        Q_EMIT statusMessageChanged(i18n("Import completed successfully"), MessageType::PositiveAnswer);
    } else {
        Q_EMIT statusMessageChanged(i18n("An error has occurred during import"), MessageType::NegativeAnswer);
    }
}

void CalendarController::abortImporting()
{
    m_events.clear();
    m_todos.clear();
}
