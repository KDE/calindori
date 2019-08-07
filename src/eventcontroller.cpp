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

void EventController::remove(LocalCalendar *calendar, const QVariantMap &eventData)
{
    qDebug() << "Deleting event";

    MemoryCalendar::Ptr memoryCalendar = calendar->memorycalendar();
    QString uid = eventData["uid"].toString();
    Event::Ptr event = memoryCalendar->event(uid);
    memoryCalendar->deleteEvent(event);
    bool deleted = calendar->save();

    qDebug() << "Event deleted: " << deleted;
}

void EventController::addEdit(LocalCalendar *calendar, const QVariantMap &eventData)
{
    qDebug() << "\naddEdit:\tCreating event";

    MemoryCalendar::Ptr memoryCalendar = calendar->memorycalendar();
    QDateTime now = QDateTime::currentDateTime();
    QString uid = eventData["uid"].toString();
    QString summary = eventData["summary"].toString();

    Event::Ptr event;
    if (uid == "") {
        event = Event::Ptr(new Event());
        event->setUid(summary.at(0) + now.toString("yyyyMMddhhmmsszzz"));
    }
    else {
        event = memoryCalendar->event(uid);
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
    bool allDayFlg= eventData["allDay"].toBool();

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
    event->setDescription(eventData["description"].toString());
    event->setSummary(summary);
    event->setAllDay(allDayFlg);
    event->setLocation(eventData["location"].toString());

    event->clearAlarms();
    QVariantList newAlarms = eventData["alarms"].value<QVariantList>();
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

    bool merged = calendar->save();

    qDebug() << "addEdit:\tEvent added/updated: " << merged;
}
