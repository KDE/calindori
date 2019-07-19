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

#include "eventcontroller.h"
#include "localcalendar.h"
#include <KCalCore/Event>
#include <KCalCore/MemoryCalendar>
#include <QDebug>

EventController::EventController(QObject* parent) : QObject(parent) {}

EventController::~EventController() = default;

QObject*  EventController::calendar() const
{
    return m_calendar;
}

void EventController::setCalendar(QObject * const calendarPtr)
{
    if(calendarPtr != m_calendar)
    {
        m_calendar = calendarPtr;
        emit calendarChanged();
    }

}

QVariantMap EventController::vevent() const
{
    return m_event;
}

void EventController::setVevent(const QVariantMap& event)
{
    m_event = event;
    emit veventChanged();
}

void EventController::remove()
{
    qDebug() << "Deleting event";

    auto localcalendar = qobject_cast<LocalCalendar*>(m_calendar);
    MemoryCalendar::Ptr memoryCalendar = localcalendar->memorycalendar();
    QString uid = m_event["uid"].value<QString>();
    Event::Ptr event = memoryCalendar->event(uid);
    memoryCalendar->deleteEvent(event);
    bool deleted = localcalendar->save();

    qDebug() << "Event deleted: " << deleted;

    emit veventChanged();
    emit veventsUpdated();
}

void EventController::addEdit()
{
    qDebug() << "\naddEdit:\tCreating event";

    auto localcalendar = qobject_cast<LocalCalendar*>(m_calendar);
    MemoryCalendar::Ptr memoryCalendar = localcalendar->memorycalendar();
    QDateTime now = QDateTime::currentDateTime();
    QString uid = m_event["uid"].value<QString>();
    QString summary = m_event["summary"].value<QString>();

    Event::Ptr event;
    if (uid == "") {
        event = Event::Ptr(new Event());
        event->setUid(summary.left(1) + now.toString("yyyyMMddhhmmsszzz"));
    }
    else {
        event = memoryCalendar->event(uid);
        event->setUid(uid);
    }

    QDate startDate = m_event["startDate"].value<QDate>();
    int startHour = m_event["startHour"].value<int>();
    int startMinute = m_event["startMinute"].value<int>();

    QDate endDate = m_event["endDate"].value<QDate>();
    int endHour = m_event["endHour"].value<int>();
    int endMinute = m_event["endMinute"].value<int>();

    QDateTime startDateTime;
    QDateTime endDateTime;
    bool allDayFlg= m_event["allDay"].value<bool>();

    if(allDayFlg) {
        startDateTime = QDateTime(startDate);
        endDateTime = QDateTime(endDate);
    }
    else {
        startDateTime = QDateTime(startDate, QTime(startHour, startMinute, 0, 0), QTimeZone::systemTimeZone());
        endDateTime = QDateTime(endDate, QTime(endHour, endMinute, 0, 0), QTimeZone::systemTimeZone());
    }

    event->setDtStart(startDateTime);
    event->setDtEnd(endDateTime);
    event->setDescription(m_event["description"].value<QString>());
    event->setSummary(summary);
    event->setAllDay(allDayFlg);
    event->setLocation(m_event["location"].value<QString>());

    event->clearAlarms();
    QVariantList newAlarms = m_event["alarms"].value<QVariantList>();
    QVariantList::const_iterator itr = newAlarms.constBegin();
    while(itr != newAlarms.constEnd())
    {
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

    memoryCalendar->addEvent(event);

    bool merged = localcalendar->save();

    qDebug() << "addEdit:\tEvent added/updated: " << merged;

    emit veventChanged();
    emit veventsUpdated();
}
