/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "eventcontroller.h"
#include "localcalendar.h"
#include <KCalendarCore/Event>
#include <KCalendarCore/MemoryCalendar>
#include <KLocalizedString>
#include <QDebug>

EventController::EventController(QObject *parent) : QObject(parent) {}

EventController::~EventController() = default;

void EventController::remove(LocalCalendar *calendar, const QVariantMap &eventData)
{
    qDebug() << "Deleting event";
    MemoryCalendar::Ptr memoryCalendar = calendar->memorycalendar();
    QString uid = eventData["uid"].toString();
    Event::Ptr event = memoryCalendar->event(uid);
    memoryCalendar->deleteEvent(event);
    bool deleted = calendar->save();
    Q_EMIT calendar->eventsChanged();

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
    } else {
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
            memoryCalendar->deleteEvent(event);
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
            memoryCalendar->addEvent(event);
        }
    }

    if (uid == "") {
        memoryCalendar->addEvent(event);
    }

    bool merged = calendar->save();
    Q_EMIT calendar->eventsChanged();

    qDebug() << "addEdit:\tEvent added/updated: " << merged;
}

QDateTime EventController::localSystemDateTime() const
{
    return QDateTime::currentDateTime();
}

QVariantMap EventController::validate(const QVariantMap &eventMap) const
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
