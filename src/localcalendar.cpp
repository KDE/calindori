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
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <KLocalizedString>

using namespace KCalendarCore;

LocalCalendar::LocalCalendar(QObject *parent)
    : QObject(parent), m_config {new CalindoriConfig(this)}, m_alarm_checker {new AlarmChecker(this)}
{
    loadCalendar(m_config->activeCalendar());
}

LocalCalendar::~LocalCalendar() = default;

MemoryCalendar::Ptr LocalCalendar::memorycalendar()
{
    reloadStorage();
    return m_calendar;
}

QString LocalCalendar::name() const
{
    return m_name;
}

void LocalCalendar::setName(QString calendarName)
{
    if (m_name != calendarName) {
        loadCalendar(calendarName);
    }
}

void LocalCalendar::setMemorycalendar(MemoryCalendar::Ptr memoryCalendar)
{
    if (m_calendar != memoryCalendar) {
        m_calendar = memoryCalendar;
    }

    Q_EMIT memorycalendarChanged();
}

int LocalCalendar::todosCount(const QDate &date) const
{
    if (m_calendar == nullptr) {
        return 0;
    }
    Todo::List todoList = m_calendar->rawTodos(date, date);

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
    Event::List eventList = m_calendar->rawEventsForDate(date);

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

QVariantMap LocalCalendar::importCalendar(const QString &calendarName, const QUrl &sourcePath)
{
    QVariantMap result;
    result["success"] = QVariant(false);

    MemoryCalendar::Ptr calendar(new MemoryCalendar(QTimeZone::systemTimeZoneId()));
    FileStorage::Ptr storage(new FileStorage(calendar));

    QVariantMap canCreateCheck = canCreateFile(calendarName);
    if (!(canCreateCheck["success"].toBool())) {
        result["reason"] = QVariant(canCreateCheck["reason"].toString());

        return result;
    }

    storage->setFileName(sourcePath.toString(QUrl::RemoveScheme));

    if (!(storage->load())) {
        result["reason"] = QVariant(QString(i18n("The calendar file is not valid")));

        return result;
    }

    storage->setFileName(canCreateCheck["targetPath"].toString());

    if (!(storage->save())) {
        result["reason"] = QVariant(QString(i18n("The calendar file cannot be saved")));

        return result;
    }

    result["success"] = QVariant(true);
    result["reason"] = QVariant(QString());

    return result;
}

void LocalCalendar::loadCalendar(const QString &calendarName)
{
    m_fullpath = m_config->calendarFile(calendarName);

    if (loadStorage()) {
        m_name = calendarName;
        Q_EMIT nameChanged();
        Q_EMIT todosChanged();
        Q_EMIT eventsChanged();
    }
}

QString LocalCalendar::fileNameFromUrl(const QUrl &sourcePath)
{
    return sourcePath.fileName();
}

void LocalCalendar::reloadStorage()
{
    if (m_fullpath.isEmpty()) {
        qDebug() << "Not ready for reload, file path not set";
        return;
    }

    QFileInfo storageFileInfo { m_fullpath };

    qDebug() << "Last memory-fs sync: " << m_fs_sync_dt;
    qDebug() << "Filed modified: " << storageFileInfo.lastModified();

    if (storageFileInfo.lastModified() <= m_fs_sync_dt) {
        qDebug() << "Reload not needed, the calendar file has not been updated";
    } else {
        loadStorage();
    }
}

bool LocalCalendar::loadStorage()
{
    if (m_fullpath.isEmpty()) {
        qDebug() << "Not ready for load, file path not set";
        return false;
    }

    MemoryCalendar::Ptr calendar(new MemoryCalendar(QTimeZone::systemTimeZoneId()));
    FileStorage::Ptr storage(new FileStorage(calendar));
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
        Q_EMIT memorycalendarChanged();
        return true;
    }

    return false;
}
