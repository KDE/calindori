/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "alarmsmodel.h"
#include <KSharedConfig>
#include <KConfigGroup>
#include <QFile>
#include <QDebug>

AlarmsModel::AlarmsModel(QObject *parent) : QObject(parent), m_memory_calendars {QVector<MemoryCalendar::Ptr>()}, m_file_storages {QVector<FileStorage::Ptr>()}, m_alarms {Alarm::List()}, m_calendar_files {QStringList()}
{
    connect(this, &AlarmsModel::periodChanged, this, &AlarmsModel::loadAlarms);
    connect(this, &AlarmsModel::calendarsChanged, this, &AlarmsModel::loadAlarms);
}

AlarmsModel::~AlarmsModel() = default;

void AlarmsModel::loadAlarms()
{
    m_alarms.clear();

    if (!(m_period.from.isValid()) && !(m_period.to.isValid())) {
        return;
    }

    openLoadStorages();

    for (const auto &m : qAsConst(m_memory_calendars)) {

        Alarm::List calendarAlarms;

        if (m_period.from.isValid() && m_period.to.isValid()) {
            calendarAlarms = m->alarms(m_period.from, m_period.to, true);
        } else if (!(m_period.from.isValid()) && m_period.to.isValid()) {
            calendarAlarms = m->alarmsTo(m_period.to);
        }

        if (!(calendarAlarms.empty())) {
            m_alarms.append(calendarAlarms);
        }
    }
    qDebug() << "loadAlarms:" << m_period.from.toString("dd.MM.yyyy hh:mm:ss") << "to" << m_period.to.toString("dd.MM.yyyy hh:mm:ss") << m_alarms.count() << "alarms found";

    closeStorages();
}

void AlarmsModel::setCalendars()
{
    m_file_storages.clear();
    m_memory_calendars.clear();

    qDebug() << "setCalendars:" << "Appending calendars" << m_calendar_files.join(",");

    for (const auto &cf : qAsConst(m_calendar_files)) {
        MemoryCalendar::Ptr calendar(new MemoryCalendar(QTimeZone::systemTimeZoneId()));
        FileStorage::Ptr storage(new FileStorage(calendar));
        storage->setFileName(cf);
        if (!(storage->fileName().isNull())) {
            m_file_storages.append(storage);
            m_memory_calendars.append(calendar);
        }
    }

    Q_EMIT calendarsChanged();
}

void AlarmsModel::openLoadStorages()
{
    auto loaded { true };
    for (const auto &fs : qAsConst(m_file_storages)) {
        loaded = fs->open() && fs->load() && loaded;
    }
    qDebug() << "openLoadStorages:" << "Loaded:" << loaded;

}

void AlarmsModel::closeStorages()
{
    auto closed { true };
    for (const auto &fs : qAsConst(m_file_storages)) {
        closed = fs->close() && closed;
    }

    qDebug() << "closeStorages:" << "Closed:" << closed;
}

QDateTime AlarmsModel::parentStartDt(const int idx) const
{
    Alarm::Ptr alarm = m_alarms.at(idx);
    Duration offsetDuration;
    QDateTime alarmTime = m_alarms.at(idx)->time();
    if (alarm->hasStartOffset()) {
        offsetDuration = alarm->startOffset();
    }

    if (!(offsetDuration.isNull())) {
        int secondsFromStart = offsetDuration.asSeconds();

        return alarmTime.addSecs(-1 * secondsFromStart);
    }

    return alarmTime;
}

Alarm::List AlarmsModel::alarms() const
{
    return m_alarms;
}

FilterPeriod AlarmsModel::period() const
{
    return m_period;
}

void AlarmsModel::setPeriod(const FilterPeriod &filterPeriod)
{
    m_period = filterPeriod;

    Q_EMIT periodChanged();
}

QStringList AlarmsModel::calendarFiles() const
{
    return m_calendar_files;
}

void AlarmsModel::setCalendarFiles(const QStringList &fileList)
{
    m_calendar_files = fileList;

    setCalendars();
}

QDateTime AlarmsModel::firstAlarmTime() const
{
    auto firstAlarmTime = m_period.to;

    for (const auto &alarm : m_alarms) {
        auto alarmTime = alarm->time();
        if (alarmTime < firstAlarmTime) {
            firstAlarmTime = alarmTime;
        }
    }

    return firstAlarmTime;
}
