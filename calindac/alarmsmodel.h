/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef ALARMSMODEL_H
#define ALARMSMODEL_H

#include <QAbstractListModel>
#include <KCalendarCore/Alarm>
#include <KCalendarCore/MemoryCalendar>
#include <KCalendarCore/FileStorage>
#include <QDateTime>

using namespace KCalendarCore;

struct FilterPeriod {
    QDateTime from;
    QDateTime to;
};

/**
 * @brief Model that serves the alarms found in a set of calendar files for a specific time period
 *
 */
class AlarmsModel : public QObject
{
    Q_OBJECT

public:
    explicit AlarmsModel(QObject *parent = nullptr);
    ~AlarmsModel() override;

    /**
     * @return The start/end date time to use to look for alarms
     */
    FilterPeriod period() const;

    /**
     * @brief Set the start date /end time to look for alarms
     */
    void setPeriod(const FilterPeriod &filterPeriod);

    /**
     * @brief The list of calendar files to look for alarms into
     */
    QStringList calendarFiles() const;

    /**
     * @brief Set the list of calendar files to look for alarms into
     */
    void setCalendarFiles(const QStringList &fileList);

    /**
     * @brief List of alarms scheduled into the interval specified
     */
    Alarm::List alarms() const;

    /**
     * @brief The date time of the first alarm scheduled into the interval specified
     */
    QDateTime firstAlarmTime() const;

Q_SIGNALS:
    void uidsChanged();
    void calendarsChanged();
    void periodChanged();

private:
    void loadAlarms();
    void setCalendars();
    void openLoadStorages();
    void closeStorages();
    QDateTime parentStartDt(const int idx) const;

    QVector<MemoryCalendar::Ptr> m_memory_calendars;
    QVector<FileStorage::Ptr> m_file_storages;
    Alarm::List m_alarms;
    QStringList m_calendar_files;
    FilterPeriod m_period;
};
#endif
