/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "calendarcontroller.h"
#include "localcalendar.h"
#include <QStandardPaths>
#include <QDebug>
#include <QFile>
#include <QStringLiteral>
#include <KLocalizedString>
#include <KCalendarCore/ICalFormat>
#include <KCalendarCore/Calendar>
#include <KCalendarCore/MemoryCalendar>
#include <KCalendarCore/Attendee>
#include <KCalendarCore/Person>
#include "attendeesmodel.h"
#include "calindoriconfig.h"

CalendarController &CalendarController::instance()
{
    static CalendarController instance;
    return instance;
}

CalendarController::CalendarController(QObject *parent) : QObject {parent}, m_events {}, m_todos {}
{
    m_calendar = std::make_unique<LocalCalendar>();
    m_calendar->setName(CalindoriConfig::instance().activeCalendar());

    connect(&CalindoriConfig::instance(), &CalindoriConfig::activeCalendarChanged, this, [this]{
        m_calendar->setName(CalindoriConfig::instance().activeCalendar());
        Q_EMIT activeCalendarChanged();
    });
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

    QString confirmMsg {};

    if (!m_events.isEmpty() && m_todos.isEmpty()) {
        confirmMsg = i18np("1 event will be added", "%1 events will be added", m_events.count());
    } else if (m_events.isEmpty() && !m_todos.isEmpty()) {
        confirmMsg = i18np("1 task will be added", "%1 tasks will be added", m_todos.count());
    } else {
        auto incidenceCount = m_events.count() + m_todos.count();
        confirmMsg = i18n("%1 incidences will be added", incidenceCount);
    }

    Q_EMIT statusMessageChanged(confirmMsg, MessageType::Question);
}

void CalendarController::importFromBuffer(LocalCalendar *localCalendar)
{
    auto calendar = localCalendar->calendar();

    for (const auto &event : std::as_const(m_events)) {
        calendar->addEvent(event);
    }

    for (const auto &todo : std::as_const(m_todos)) {
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

    sendMessage(result);
}

void CalendarController::importFromBuffer(const QString &targetCalendar)
{
    auto filePath = CalindoriConfig::instance().calendarFile(targetCalendar);
    QFile calendarFile {filePath};
    if (!calendarFile.exists()) {
        sendMessage(false);
        return;
    }

    KCalendarCore::Calendar::Ptr calendar {new KCalendarCore::MemoryCalendar(QTimeZone::systemTimeZoneId())};
    KCalendarCore::FileStorage::Ptr storage {new KCalendarCore::FileStorage {calendar}};
    storage->setFileName(filePath);
    if (!storage->load()) {
        sendMessage(false);
        return;
    }

    for (const auto &event : std::as_const(m_events)) {
        calendar->addEvent(event);
    }

    for (const auto &todo : std::as_const(m_todos)) {
        calendar->addTodo(todo);
    }

    sendMessage(storage->save());
}

void CalendarController::sendMessage(const bool positive)
{
    if (positive) {
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
    KCalendarCore::Calendar::Ptr calendar = localCalendar->calendar();
    QString uid = eventData[QStringLiteral("uid")].toString();
    KCalendarCore::Event::Ptr event = calendar->event(uid);
    calendar->deleteEvent(event);
    bool deleted = localCalendar->save();
    Q_EMIT localCalendar->eventsChanged();

    qDebug() << "Event " << uid << " deleted: " << deleted;
}

void CalendarController::upsertEvent(const QVariantMap &eventData, const QVariantList &attendeesList)
{
    qDebug() << "\naddEdit:\tCreating event";

    KCalendarCore::Calendar::Ptr calendar = CalendarController::instance().activeCalendar()->calendar();
    QDateTime now = QDateTime::currentDateTime();
    QString uid = eventData[QStringLiteral("uid")].toString();
    QString summary = eventData[QStringLiteral("summary")].toString();
    bool clearPartStatus {false};

    QDate startDate = eventData[QStringLiteral("startDate")].toDate();
    int startHour = eventData[QStringLiteral("startHour")].value<int>();
    int startMinute = eventData[QStringLiteral("startMinute")].value<int>();

    QDate endDate = eventData[QStringLiteral("endDate")].toDate();
    int endHour = eventData[QStringLiteral("endHour")].value<int>();
    int endMinute = eventData[QStringLiteral("endMinute")].value<int>();

    QDateTime startDateTime;
    QDateTime endDateTime;
    bool allDayFlg = eventData[QStringLiteral("allDay")].toBool();

    if (allDayFlg) {
        startDateTime = startDate.startOfDay();
        endDateTime = endDate.startOfDay();
    } else {
        startDateTime = QDateTime(startDate, QTime(startHour, startMinute, 0, 0), QTimeZone::systemTimeZone());
        endDateTime = QDateTime(endDate, QTime(endHour, endMinute, 0, 0), QTimeZone::systemTimeZone());
    }

    KCalendarCore::Event::Ptr event;
    if (uid.isEmpty()) {
        event = KCalendarCore::Event::Ptr(new KCalendarCore::Event());
        event->setUid(summary.at(0) + now.toString(QStringLiteral("yyyyMMddhhmmsszzz")));
    } else {
        event = calendar->event(uid);
        event->setUid(uid);
        clearPartStatus = (event->dtStart() != startDateTime) || (event->dtEnd() != endDateTime) || (event->allDay() != allDayFlg);
    }

    event->setDtStart(startDateTime);
    event->setDtEnd(endDateTime);
    event->setDescription(eventData[QStringLiteral("description")].toString());
    event->setSummary(summary);
    event->setAllDay(allDayFlg);
    event->setLocation(eventData[QStringLiteral("location")].toString());

    event->clearAttendees();
    for (auto &a : std::as_const(attendeesList)) {
        auto attendee = a.value<KCalendarCore::Attendee>();
        if (clearPartStatus) {
            qDebug() << "Participants need to be informed";
            attendee.setRSVP(true);
            attendee.setStatus(KCalendarCore::Attendee::PartStat::NeedsAction);
        }
        event->addAttendee(attendee);
    }

    if (!attendeesList.isEmpty()) {
        event->setOrganizer(KCalendarCore::Person { CalendarController::instance().activeCalendar()->ownerName(), CalendarController::instance().activeCalendar()->ownerEmail()});
    }

    event->clearAlarms();
    QVariantList newAlarms = eventData[QStringLiteral("alarms")].value<QVariantList>();
    QVariantList::const_iterator itr = newAlarms.constBegin();
    while (itr != newAlarms.constEnd()) {
        KCalendarCore::Alarm::Ptr newAlarm = event->newAlarm();
        QHash<QString, QVariant> newAlarmHashMap = (*itr).value<QHash<QString, QVariant>>();
        int startOffsetValue = newAlarmHashMap[QStringLiteral("startOffsetValue")].value<int>();
        int startOffsetType = newAlarmHashMap[QStringLiteral("startOffsetType")].value<int>();
        int actionType = newAlarmHashMap[QStringLiteral("actionType")].value<int>();

        qDebug() << "addEdit:\tAdding alarm with start offset value " << startOffsetValue;
        newAlarm->setStartOffset(KCalendarCore::Duration(startOffsetValue, static_cast<KCalendarCore::Duration::Type>(startOffsetType)));
        newAlarm->setType(static_cast<KCalendarCore::Alarm::Type>(actionType));
        newAlarm->setEnabled(true);
        newAlarm->setText((event->summary()).isEmpty() ?  event->description() : event->summary());
        ++itr;
    }

    ushort newPeriod = static_cast<ushort>(eventData[QStringLiteral("periodType")].toInt());

    //Bother with recurrences only if a recurrence has been found, either existing or new
    if ((event->recurrenceType() != KCalendarCore::Recurrence::rNone) || (newPeriod != KCalendarCore::Recurrence::rNone)) {
        //WORKAROUND: When changing an event from non-recurring to recurring, duplicate events are displayed
        if (!uid.isEmpty()) {
            calendar->deleteEvent(event);
        }

        switch (newPeriod) {
        case KCalendarCore::Recurrence::rYearlyDay:
        case KCalendarCore::Recurrence::rYearlyMonth:
        case KCalendarCore::Recurrence::rYearlyPos:
            event->recurrence()->setYearly(eventData[QStringLiteral("repeatEvery")].toInt());
            break;
        case KCalendarCore::Recurrence::rMonthlyDay:
        case KCalendarCore::Recurrence::rMonthlyPos:
            event->recurrence()->setMonthly(eventData[QStringLiteral("repeatEvery")].toInt());
            break;
        case KCalendarCore::Recurrence::rWeekly:
            event->recurrence()->setWeekly(eventData[QStringLiteral("repeatEvery")].toInt());
            break;
        case KCalendarCore::Recurrence::rDaily:
            event->recurrence()->setDaily(eventData[QStringLiteral("repeatEvery")].toInt());
            break;
        default:
            event->recurrence()->clear();
        }

        if (newPeriod != KCalendarCore::Recurrence::rNone) {
            int stopAfter = eventData[QStringLiteral("stopAfter")].toInt() > 0 ? eventData[QStringLiteral("stopAfter")].toInt() : -1;
            event->recurrence()->setDuration(stopAfter);
            event->recurrence()->setAllDay(allDayFlg);
        }

        if (!uid.isEmpty()) {
            calendar->addEvent(event);
        }
    }

    event->setStatus(eventData[QStringLiteral("status")].value<KCalendarCore::Incidence::Status>());

    if (uid.isEmpty()) {
        calendar->addEvent(event);
    }

    bool merged = CalendarController::instance().activeCalendar()->save();
    Q_EMIT CalendarController::instance().activeCalendar()->eventsChanged();

    qDebug() << "Event upsert: " << merged;
}

QDateTime CalendarController::localSystemDateTime() const
{
    return QDateTime::currentDateTime();
}

QVariantMap CalendarController::validateEvent(const QVariantMap &eventMap) const
{
    QVariantMap result {};

    QDate startDate = eventMap[QStringLiteral("startDate")].toDate();
    bool validStartHour {false};
    int startHour = eventMap[QStringLiteral("startHour")].toInt(&validStartHour);
    bool validStartMinutes {false};
    int startMinute = eventMap[QStringLiteral("startMinute")].toInt(&validStartMinutes);
    QDate endDate = eventMap[QStringLiteral("endDate")].toDate();
    bool validEndHour {false};
    int endHour = eventMap[QStringLiteral("endHour")].toInt(&validEndHour);
    bool validEndMinutes {false};
    int endMinutes = eventMap[QStringLiteral("endMinute")].toInt(&validEndMinutes);
    bool allDayFlg = eventMap[QStringLiteral("allDay")].toBool();

    if (startDate.isValid() && validStartHour && validStartMinutes && endDate.isValid() && validEndHour && validEndMinutes) {
        if (allDayFlg && (endDate != startDate)) {
            result[QStringLiteral("success")] = false;
            result[QStringLiteral("reason")] = i18n("In case of all day events, start date and end date should be equal");

            return result;
        }

        auto startDateTime = QDateTime(startDate, QTime(startHour, startMinute, 0, 0), QTimeZone::systemTimeZone());
        auto endDateTime = QDateTime(endDate, QTime(endHour, endMinutes, 0, 0), QTimeZone::systemTimeZone());

        if (!allDayFlg && (startDateTime > endDateTime)) {
            result[QStringLiteral("success")] = false;
            result[QStringLiteral("reason")] = i18n("End date time should be equal to or greater than the start date time");
            return result;
        }

        auto validPeriodType {false};
        auto periodType = static_cast<ushort>(eventMap[QStringLiteral("periodType")].toInt(&validPeriodType));
        auto eventDuration = startDateTime.secsTo(endDateTime);
        auto validRepeatEvery {false};
        auto repeatEvery = static_cast<ushort>(eventMap[QStringLiteral("repeatEvery")].toInt(&validRepeatEvery));

        if (validPeriodType && (periodType == KCalendarCore::Recurrence::rDaily) && validRepeatEvery && (repeatEvery == 1) && eventDuration > 86400) {
            result[QStringLiteral("success")] = false;
            result[QStringLiteral("reason")] = i18n("Daily events should not span multiple days");
            return result;
        }
    }

    result[QStringLiteral("success")] = true;
    result[QStringLiteral("reason")] = QString();

    return result;

}

void CalendarController::upsertTodo(LocalCalendar *localCalendar, const QVariantMap &todo)
{
    KCalendarCore::Calendar::Ptr calendar = localCalendar->calendar();
    KCalendarCore::Todo::Ptr vtodo;
    QDateTime now = QDateTime::currentDateTime();
    QString uid = todo[QStringLiteral("uid")].toString();
    QString summary = todo[QStringLiteral("summary")].toString();
    QDate startDate = todo[QStringLiteral("startDate")].toDate();
    int startHour = todo[QStringLiteral("startHour")].value<int>();
    int startMinute = todo[QStringLiteral("startMinute")].value<int>();
    bool allDayFlg = todo[QStringLiteral("allDay")].toBool();

    if (uid.isEmpty()) {
        vtodo = KCalendarCore::Todo::Ptr(new KCalendarCore::Todo());
        vtodo->setUid(summary.at(0) + now.toString(QStringLiteral("yyyyMMddhhmmsszzz")));
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

    QDate dueDate = todo[QStringLiteral("dueDate")].toDate();

    bool validDueHour {false};
    int dueHour = todo[QStringLiteral("dueHour")].toInt(&validDueHour);

    bool validDueMinutes {false};
    int dueMinute = todo[QStringLiteral("dueMinute")].toInt(&validDueMinutes);

    QDateTime dueDateTime = QDateTime();
    if (dueDate.isValid() && validDueHour && validDueMinutes && !allDayFlg) {
        dueDateTime = QDateTime(dueDate, QTime(dueHour, dueMinute, 0, 0), QTimeZone::systemTimeZone());
    } else if (dueDate.isValid() && allDayFlg) {
        dueDateTime = dueDate.startOfDay();
    }

    vtodo->setDtDue(dueDateTime);
    vtodo->setDescription(todo[QStringLiteral("description")].toString());
    vtodo->setSummary(summary);
    vtodo->setAllDay((startDate.isValid() || dueDate.isValid()) ? allDayFlg : false);
    vtodo->setLocation(todo[QStringLiteral("location")].toString());
    vtodo->setCompleted(todo[QStringLiteral("completed")].toBool());

    vtodo->clearAlarms();
    QVariantList newAlarms = todo[QStringLiteral("alarms")].value<QVariantList>();
    QVariantList::const_iterator itr = newAlarms.constBegin();
    while (itr != newAlarms.constEnd()) {
        KCalendarCore::Alarm::Ptr newAlarm = vtodo->newAlarm();
        QHash<QString, QVariant> newAlarmHashMap = (*itr).value<QHash<QString, QVariant>>();
        int startOffsetValue = newAlarmHashMap[QStringLiteral("startOffsetValue")].value<int>();
        int startOffsetType = newAlarmHashMap[QStringLiteral("startOffsetType")].value<int>();
        int actionType = newAlarmHashMap[QStringLiteral("actionType")].value<int>();

        newAlarm->setStartOffset(KCalendarCore::Duration(startOffsetValue, static_cast<KCalendarCore::Duration::Type>(startOffsetType)));
        newAlarm->setType(static_cast<KCalendarCore::Alarm::Type>(actionType));
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
    KCalendarCore::Calendar::Ptr calendar = localCalendar->calendar();
    QString uid = todo[QStringLiteral("uid")].toString();
    KCalendarCore::Todo::Ptr vtodo = calendar->todo(uid);

    calendar->deleteTodo(vtodo);
    bool removed = localCalendar->save();

    Q_EMIT localCalendar->todosChanged();
    qDebug() << "Todo deleted: " << removed;
}

QVariantMap CalendarController::validateTodo(const QVariantMap &todo) const
{
    QVariantMap result {};

    QDate startDate = todo[QStringLiteral("startDate")].toDate();
    bool validStartHour {false};
    int startHour = todo[QStringLiteral("startHour")].toInt(&validStartHour);
    bool validStartMinutes {false};
    int startMinute = todo[QStringLiteral("startMinute")].toInt(&validStartMinutes);
    QDate dueDate = todo[QStringLiteral("dueDate")].toDate();
    bool validDueHour {false};
    int dueHour = todo[QStringLiteral("dueHour")].toInt(&validDueHour);
    bool validDueMinutes {false};
    int dueMinute = todo[QStringLiteral("dueMinute")].toInt(&validDueMinutes);
    bool allDayFlg = todo[QStringLiteral("allDay")].toBool();

    if (startDate.isValid() && validStartHour && validStartMinutes && dueDate.isValid() && validDueHour && validDueMinutes) {
        if (allDayFlg && (dueDate != startDate)) {
            result[QStringLiteral("success")] = false;
            result[QStringLiteral("reason")] = i18n("In case of all day tasks, start date and due date should be equal");

            return result;
        }

        if (!allDayFlg && (QDateTime(startDate, QTime(startHour, startMinute, 0, 0), QTimeZone::systemTimeZone()) >  QDateTime(dueDate, QTime(dueHour, dueMinute, 0, 0), QTimeZone::systemTimeZone()))) {
            result[QStringLiteral("success")] = false;
            result[QStringLiteral("reason")] = i18n("Due date time should be equal to or greater than the start date time");
            return result;
        }
    }

    result[QStringLiteral("success")] = true;
    result[QStringLiteral("reason")] = QString();

    return result;
}

QString CalendarController::fileNameFromUrl(const QUrl &sourcePath)
{
    return sourcePath.fileName();
}

QVariantMap CalendarController::exportData(const QString &calendarName)
{
    auto filePath = CalindoriConfig::instance().calendarFile(calendarName);
    QFile calendarFile {filePath};
    if (!calendarFile.exists()) {
        return {
            { QStringLiteral("success"), false },
            { QStringLiteral("reason"), i18n("Cannot read calendar. Export failed.") }
        };
    }

    KCalendarCore::Calendar::Ptr calendar {new KCalendarCore::MemoryCalendar(QTimeZone::systemTimeZoneId())};
    KCalendarCore::FileStorage::Ptr storage {new KCalendarCore::FileStorage {calendar}};
    storage->setFileName(filePath);
    if (!storage->load()) {
        return {
            { QStringLiteral("success"), false },
            { QStringLiteral("reason"), i18n("Cannot load calendar. Export failed.") }
        };
    }

    auto dirPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    QFile targetFile {dirPath + QStringLiteral("/calindori_") + calendarName + QStringLiteral(".ics")};
    auto fileSuffix {1};
    while (targetFile.exists()) {
        targetFile.setFileName(dirPath + QStringLiteral("/calindori_") + calendarName + QStringLiteral("(") + QString::number(fileSuffix++) + QStringLiteral(").ics"));
    }

    storage->setFileName(targetFile.fileName());
    if (!(storage->save())) {
        return {
            { QStringLiteral("success"), false },
            { QStringLiteral("reason"), i18n("Cannot save calendar file. Export failed.") }
        };

    }

    return {
        { QStringLiteral("success"), true },
        { QStringLiteral("reason"), i18n("Export completed successfully") },
        { QStringLiteral("targetFolder"), QUrl {QStringLiteral("file://") + dirPath} }
    };
}

LocalCalendar *CalendarController::activeCalendar() const
{
    return m_calendar.get();
}
