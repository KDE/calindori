/*
 * SPDX-FileCopyrightText: 2018 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "localcalendar.h"
#include "calindoriconfig.h"
#include "alarmchecker.h"
#include <QDebug>
#include <KCalendarCore/Todo>
#include <KCalendarCore/MemoryCalendar>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <KLocalizedString>

LocalCalendar::LocalCalendar(QObject *parent)
    : QObject(parent), m_alarm_checker {new AlarmChecker(this)}
{
    loadCalendar(CalindoriConfig::instance().activeCalendar());
}

LocalCalendar::~LocalCalendar() = default;

KCalendarCore::Calendar::Ptr LocalCalendar::calendar()
{
    reloadStorage();
    return m_calendar;
}

QString LocalCalendar::name() const
{
    return m_name;
}

void LocalCalendar::setName(const QString &calendarName)
{
    if (m_name != calendarName) {
        loadCalendar(calendarName);
    }
}

void LocalCalendar::setCalendar(KCalendarCore::Calendar::Ptr calendar)
{
    if (m_calendar != calendar) {
        m_calendar = calendar;
    }

    Q_EMIT calendarChanged();
}

int LocalCalendar::todosCount(const QDate &date) const
{
    if (m_calendar == nullptr) {
        return 0;
    }
    KCalendarCore::Todo::List todoList = m_calendar->rawTodos(date, date);

    return todoList.size();
}

void LocalCalendar::deleteCalendar()
{
    qDebug() << "Deleting calendar at " << m_fullpath;
    QFile calendarFile(m_fullpath);

    if (calendarFile.exists()) {
        calendarFile.remove();
    }
}

int LocalCalendar::eventsCount(const QDate &date) const
{
    if (m_calendar == nullptr) {
        return 0;
    }
    KCalendarCore::Event::List eventList = m_calendar->rawEventsForDate(date);

    return eventList.count();
}

bool LocalCalendar::save()
{
    if (m_cal_storage->save()) {
        qDebug() << "Saving to file";
        m_fs_sync_dt = QDateTime::currentDateTime();
        m_alarm_checker->scheduleAlarmCheck();
        return true;
    }

    return false;
}

QVariantMap LocalCalendar::canCreateFile(const QString &calendarName)
{
    QVariantMap result;
    result["success"] = QVariant(true);
    result["reason"] = QVariant(QString());

    QString targetPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/calindori_" + calendarName + ".ics" ;
    QFile calendarFile(targetPath);

    if (calendarFile.exists()) {
        result["success"] = QVariant(false);
        result["reason"] = QVariant(QString(i18n("A calendar with the same name already exists")));

        return result;
    }

    result["targetPath"] = QVariant(QString(targetPath));

    return result;
}

void LocalCalendar::loadCalendar(const QString &calendarName)
{
    m_fullpath = CalindoriConfig::instance().calendarFile(calendarName);

    if (loadStorage()) {
        m_name = calendarName;
        Q_EMIT nameChanged();
        Q_EMIT todosChanged();
        Q_EMIT eventsChanged();
    }
}

void LocalCalendar::reloadStorage()
{
    if (m_fullpath.isEmpty()) {
        qDebug() << "Not ready for reload, file path not set";
        return;
    }

    QFileInfo storageFileInfo { m_fullpath };

    if (storageFileInfo.lastModified() > m_fs_sync_dt) {
        qDebug() << "Last memory-fs sync: " << m_fs_sync_dt;
        qDebug() << "Filed modified: " << storageFileInfo.lastModified();
        qDebug() << "Reload storage";
        loadStorage();
    }
}

bool LocalCalendar::loadStorage()
{
    if (m_fullpath.isEmpty()) {
        qDebug() << "Not ready for load, file path not set";
        return false;
    }

    KCalendarCore::Calendar::Ptr calendar(new KCalendarCore::MemoryCalendar(QTimeZone::systemTimeZoneId()));
    KCalendarCore::FileStorage::Ptr storage(new KCalendarCore::FileStorage(calendar));
    storage->setFileName(m_fullpath);

    QFile calendarFile(m_fullpath);

    if (!calendarFile.exists()) {
        bool saved = storage->save();
        qDebug() << "New calendar file created: " << saved;
    }

    if (storage->load()) {
        qDebug() << "Storage file loaded";
        m_cal_storage = storage;
        m_calendar = calendar;
        m_fs_sync_dt = QDateTime::currentDateTime();
        m_alarm_checker->scheduleAlarmCheck();
        Q_EMIT calendarChanged();
        return true;
    }

    return false;
}

QString LocalCalendar::ownerName() const
{
    return CalindoriConfig::instance().ownerName(m_name);
}

QString LocalCalendar::ownerEmail() const
{
    return CalindoriConfig::instance().ownerEmail(m_name);
}

bool LocalCalendar::isExternal() const
{
    return CalindoriConfig::instance().isExternal(m_name);
}

void LocalCalendar::setOwnerName(const QString &ownerName)
{
    CalindoriConfig::instance().setOwnerName(m_name, ownerName);

    Q_EMIT ownerNameChanged();
}

void LocalCalendar::setOwnerEmail(const QString &ownerEmail)
{
    CalindoriConfig::instance().setOwnerEmail(m_name, ownerEmail);

    Q_EMIT ownerEmailChanged();
}
