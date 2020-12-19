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

void CalendarController::removeEvent(LocalCalendar *localCalendar, const QVariantMap &eventData)
{
    Calendar::Ptr calendar = localCalendar->calendar();
    QString uid = eventData["uid"].toString();
    Event::Ptr event = calendar->event(uid);
    calendar->deleteEvent(event);
    bool deleted = localCalendar->save();
    Q_EMIT localCalendar->eventsChanged();

    qDebug() << "Event " << uid << " deleted: " << deleted;
}

void CalendarController::upsertEvent(LocalCalendar *localCalendar, const QVariantMap &eventData)
{
    qDebug() << "\naddEdit:\tCreating event";

    Calendar::Ptr calendar = localCalendar->calendar();
    QDateTime now = QDateTime::currentDateTime();
    QString uid = eventData["uid"].toString();
    QString summary = eventData["summary"].toString();

    Event::Ptr event;
    if (uid == "") {
        event = Event::Ptr(new Event());
        event->setUid(summary.at(0) + now.toString("yyyyMMddhhmmsszzz"));
    } else {
        event = calendar->event(uid);
        event->setUid(uid);
    }

    QDate startDate = eventData["startDate"].toDate();
    int startHour = eventData["startHour"].value<int>();
    int startMinute = eventData["startMinute"].value<int>();

    QDate endDate = eventData["endDate"].toDate();
    int endHour = eventData["endHour"].value<int>();
    int endMinute = eventData["endMinute"].value<int>();

    QDateTime startDateTime;
    QDateTime endDateTime;
    bool allDayFlg = eventData["allDay"].toBool();

    if (allDayFlg) {
        startDateTime = startDate.startOfDay();
        endDateTime = endDate.startOfDay();
    } else {
        startDateTime = QDateTime(startDate, QTime(startHour, startMinute, 0, 0), QTimeZone::systemTimeZone());
        endDateTime = QDateTime(endDate, QTime(endHour, endMinute, 0, 0), QTimeZone::systemTimeZone());
    }

    event->setDtStart(startDateTime);
    event->setDtEnd(endDateTime);
    event->setDescription(eventData["description"].toString());
    event->setSummary(summary);
    event->setAllDay(allDayFlg);
    event->setLocation(eventData["location"].toString());

    event->clearAlarms();
    QVariantList newAlarms = eventData["alarms"].value<QVariantList>();
    QVariantList::const_iterator itr = newAlarms.constBegin();
    while (itr != newAlarms.constEnd()) {
        Alarm::Ptr newAlarm = event->newAlarm();
        QHash<QString, QVariant> newAlarmHashMap = (*itr).value<QHash<QString, QVariant>>();
        int startOffsetValue = newAlarmHashMap["startOffsetValue"].value<int>();
        int startOffsetType = newAlarmHashMap["startOffsetType"].value<int>();
        int actionType = newAlarmHashMap["actionType"].value<int>();

        qDebug() << "addEdit:\tAdding alarm with start offset value " << startOffsetValue;
        newAlarm->setStartOffset(Duration(startOffsetValue, static_cast<Duration::Type>(startOffsetType)));
        newAlarm->setType(static_cast<Alarm::Type>(actionType));
        newAlarm->setEnabled(true);
        newAlarm->setText((event->summary()).isEmpty() ?  event->description() : event->summary());
        ++itr;
    }

    ushort newPeriod = static_cast<ushort>(eventData["periodType"].toInt());

    //Bother with recurrences only if a recurrence has been found, either existing or new
    if ((event->recurrenceType() != Recurrence::rNone) || (newPeriod != Recurrence::rNone)) {
        //WORKAROUND: When changing an event from non-recurring to recurring, duplicate events are displayed
        if (uid != "") {
            calendar->deleteEvent(event);
        }

        switch (newPeriod) {
        case Recurrence::rYearlyDay:
        case Recurrence::rYearlyMonth:
        case Recurrence::rYearlyPos:
            event->recurrence()->setYearly(eventData["repeatEvery"].toInt());
            break;
        case Recurrence::rMonthlyDay:
        case Recurrence::rMonthlyPos:
            event->recurrence()->setMonthly(eventData["repeatEvery"].toInt());
            break;
        case Recurrence::rWeekly:
            event->recurrence()->setWeekly(eventData["repeatEvery"].toInt());
            break;
        case Recurrence::rDaily:
            event->recurrence()->setDaily(eventData["repeatEvery"].toInt());
            break;
        default:
            event->recurrence()->clear();
        }

        if (newPeriod != Recurrence::rNone) {
            int stopAfter = eventData["stopAfter"].toInt() > 0 ? eventData["stopAfter"].toInt() : -1;
            event->recurrence()->setDuration(stopAfter);
            event->recurrence()->setAllDay(allDayFlg);
        }

        if (uid != "") {
            calendar->addEvent(event);
        }
    }

    if (uid == "") {
        calendar->addEvent(event);
    }

    bool merged = localCalendar->save();
    Q_EMIT localCalendar->eventsChanged();

    qDebug() << "Event upsert: " << merged;
}

QDateTime CalendarController::localSystemDateTime() const
{
    return QDateTime::currentDateTime();
}

QVariantMap CalendarController::validateEvent(const QVariantMap &eventMap) const
{
    QVariantMap result {};

    QDate startDate = eventMap["startDate"].toDate();
    bool validStartHour {false};
    int startHour = eventMap["startHour"].toInt(&validStartHour);
    bool validStartMinutes {false};
    int startMinute = eventMap["startMinute"].toInt(&validStartMinutes);
    QDate endDate = eventMap["endDate"].toDate();
    bool validEndHour {false};
    int endHour = eventMap["endHour"].toInt(&validEndHour);
    bool validEndMinutes {false};
    int endMinutes = eventMap["endMinute"].toInt(&validEndMinutes);
    bool allDayFlg = eventMap["allDay"].toBool();

    if (startDate.isValid() && validStartHour && validStartMinutes && endDate.isValid() && validEndHour && validEndMinutes) {
        if (allDayFlg && (endDate != startDate)) {
            result["success"] = false;
            result["reason"] = i18n("In case of all day events, start date and end date should be equal");

            return result;
        }

        auto startDateTime = QDateTime(startDate, QTime(startHour, startMinute, 0, 0), QTimeZone::systemTimeZone());
        auto endDateTime = QDateTime(endDate, QTime(endHour, endMinutes, 0, 0), QTimeZone::systemTimeZone());

        if (!allDayFlg && (startDateTime > endDateTime)) {
            result["success"] = false;
            result["reason"] = i18n("End date time should be equal to or greater than the start date time");
            return result;
        }

        auto validPeriodType {false};
        auto periodType = static_cast<ushort>(eventMap["periodType"].toInt(&validPeriodType));
        auto eventDuration = startDateTime.secsTo(endDateTime);
        auto validRepeatEvery {false};
        auto repeatEvery = static_cast<ushort>(eventMap["repeatEvery"].toInt(&validRepeatEvery));

        if (validPeriodType && (periodType == Recurrence::rDaily) && validRepeatEvery && (repeatEvery == 1) && eventDuration > 86400) {
            result["success"] = false;
            result["reason"] = i18n("Daily events should not span multiple days");
            return result;
        }
    }

    result["success"] = true;
    result["reason"] = QString();

    return result;

}

void CalendarController::upsertTodo(LocalCalendar *localCalendar, const QVariantMap &todo)
{
    Calendar::Ptr calendar = localCalendar->calendar();
    Todo::Ptr vtodo;
    QDateTime now = QDateTime::currentDateTime();
    QString uid = todo["uid"].toString();
    QString summary = todo["summary"].toString();
    QDate startDate = todo["startDate"].toDate();
    int startHour = todo["startHour"].value<int>();
    int startMinute = todo["startMinute"].value<int>();
    bool allDayFlg = todo["allDay"].toBool();

    if (uid == "") {
        vtodo = Todo::Ptr(new Todo());
        vtodo->setUid(summary.at(0) + now.toString("yyyyMMddhhmmsszzz"));
    } else {
        vtodo = calendar->todo(uid);
        vtodo->setUid(uid);
    }

    QDateTime startDateTime;
    if (allDayFlg) {
        startDateTime = startDate.startOfDay();
    } else {
        startDateTime = QDateTime(startDate, QTime(startHour, startMinute, 0, 0), QTimeZone::systemTimeZone());
    }

    vtodo->setDtStart(startDateTime);

    QDate dueDate = todo["dueDate"].toDate();

    bool validDueHour {false};
    int dueHour = todo["dueHour"].toInt(&validDueHour);

    bool validDueMinutes {false};
    int dueMinute = todo["dueMinute"].toInt(&validDueMinutes);

    QDateTime dueDateTime = QDateTime();
    if (dueDate.isValid() && validDueHour && validDueMinutes && !allDayFlg) {
        dueDateTime = QDateTime(dueDate, QTime(dueHour, dueMinute, 0, 0), QTimeZone::systemTimeZone());
    } else if (dueDate.isValid() && allDayFlg) {
        dueDateTime = dueDate.startOfDay();
    }

    vtodo->setDtDue(dueDateTime);
    vtodo->setDescription(todo["description"].toString());
    vtodo->setSummary(summary);
    vtodo->setAllDay((startDate.isValid() || dueDate.isValid()) ? allDayFlg : false);
    vtodo->setLocation(todo["location"].toString());
    vtodo->setCompleted(todo["completed"].toBool());

    vtodo->clearAlarms();
    QVariantList newAlarms = todo["alarms"].value<QVariantList>();
    QVariantList::const_iterator itr = newAlarms.constBegin();
    while (itr != newAlarms.constEnd()) {
        Alarm::Ptr newAlarm = vtodo->newAlarm();
        QHash<QString, QVariant> newAlarmHashMap = (*itr).value<QHash<QString, QVariant>>();
        int startOffsetValue = newAlarmHashMap["startOffsetValue"].value<int>();
        int startOffsetType = newAlarmHashMap["startOffsetType"].value<int>();
        int actionType = newAlarmHashMap["actionType"].value<int>();

        newAlarm->setStartOffset(Duration(startOffsetValue, static_cast<Duration::Type>(startOffsetType)));
        newAlarm->setType(static_cast<Alarm::Type>(actionType));
        newAlarm->setEnabled(true);
        newAlarm->setText((vtodo->summary()).isEmpty() ?  vtodo->description() : vtodo->summary());
        ++itr;
    }

    calendar->addTodo(vtodo);
    bool merged = localCalendar->save();

    Q_EMIT localCalendar->todosChanged();

    qDebug() << "Todo upsert: " << merged;
}

void CalendarController::removeTodo(LocalCalendar *localCalendar, const QVariantMap &todo)
{
    Calendar::Ptr calendar = localCalendar->calendar();
    QString uid = todo["uid"].toString();
    Todo::Ptr vtodo = calendar->todo(uid);

    calendar->deleteTodo(vtodo);
    bool removed = localCalendar->save();

    Q_EMIT localCalendar->todosChanged();
    qDebug() << "Todo deleted: " << removed;
}

QVariantMap CalendarController::validateTodo(const QVariantMap &todo) const
{
    QVariantMap result {};

    QDate startDate = todo["startDate"].toDate();
    bool validStartHour {false};
    int startHour = todo["startHour"].toInt(&validStartHour);
    bool validStartMinutes {false};
    int startMinute = todo["startMinute"].toInt(&validStartMinutes);
    QDate dueDate = todo["dueDate"].toDate();
    bool validDueHour {false};
    int dueHour = todo["dueHour"].toInt(&validDueHour);
    bool validDueMinutes {false};
    int dueMinute = todo["dueMinute"].toInt(&validDueMinutes);
    bool allDayFlg = todo["allDay"].toBool();

    if (startDate.isValid() && validStartHour && validStartMinutes && dueDate.isValid() && validDueHour && validDueMinutes) {
        if (allDayFlg && (dueDate != startDate)) {
            result["success"] = false;
            result["reason"] = i18n("In case of all day tasks, start date and due date should be equal");

            return result;
        }

        if (!allDayFlg && (QDateTime(startDate, QTime(startHour, startMinute, 0, 0), QTimeZone::systemTimeZone()) >  QDateTime(dueDate, QTime(dueHour, dueMinute, 0, 0), QTimeZone::systemTimeZone()))) {
            result["success"] = false;
            result["reason"] = i18n("Due date time should be equal to or greater than the start date time");
            return result;
        }
    }

    result["success"] = true;
    result["reason"] = QString();

    return result;
}
