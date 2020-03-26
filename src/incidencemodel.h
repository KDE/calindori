/*
 * Copyright (C) 2020 Dimitris Kardarakos <dimkard@posteo.net>
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

#ifndef INCIDENCE_MODEL_H
#define INCIDENCE_MODEL_H

#include <QAbstractListModel>
#include <KCalendarCore/Incidence>
#include <KCalendarCore/Event>
#include <KCalendarCore/Todo>
#include "localcalendar.h"

using namespace KCalendarCore;

class IncidenceModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int filterMode READ filterMode WRITE setFilterMode NOTIFY filterModeChanged)
    Q_PROPERTY(QDate filterDt READ filterDt WRITE setFilterDt NOTIFY filterDtChanged)
    Q_PROPERTY(int filterHour READ filterHour WRITE setFilterHour NOTIFY filterHourChanged)
    Q_PROPERTY(LocalCalendar* calendar READ calendar WRITE setCalendar NOTIFY calendarChanged)

public:
    explicit IncidenceModel(QObject* parent = nullptr);
    ~IncidenceModel() override;

    enum FilterModes {
        Invalid = 0,
        HourIncidences,
        HourEvents,
        HourTodos,
        DayIncidences,
        DayEvents,
        DayTodos,
        AllIncidences,
        AllEvents,
        AllTodos
    };

    enum Roles
    {
        Uid = Qt::UserRole+1,
        LastModified,
        DtStart,
        AllDay,
        Description,
        Summary,
        Location,
        Categories,
        Priority,
        Created,
        Secrecy,
        EndDate,
        IsRepeating,
        RepeatPeriodType,
        RepeatEvery,
        RepeatStopAfter,
        DisplayDate,
        DisplayTime,
        Completed,
        IncidenceType
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QDate filterDt() const;
    void setFilterDt(const QDate & filterDate);

    int filterHour() const;
    void setFilterHour(const int hour);

    int filterMode() const;
    void setFilterMode(const int mode);

    LocalCalendar *calendar() const;
    void setCalendar(LocalCalendar *calendarPtr);


Q_SIGNALS:
    void filterDtChanged();
    void filterHourChanged();
    void calendarChanged();
    void filterModeChanged();

private:
    /**
     * @return The INTERVAL of RFC 5545. It contains a positive integer representing at
      which intervals the recurrence rule repeats.
     */
    int repeatEvery(const int idx) const;

    /**
     * @return The COUNT of RFC 5545. It defines the number of occurrences at which to
      range-bound the recurrence.  The "DTSTART" property value always
      counts as the first occurrence.
     */
    int repeatStopAfter(const int idx) const;

    /**
     * return The FREQ rule part which identifies the type of recurrence rule
     */
    ushort repeatPeriodType(const int idx) const;

    void loadIncidences();
    Incidence::List hourIncidences() const;
    Incidence::List hourEvents() const;
    Incidence::List hourTodos() const;
    Incidence::List dayIncidences() const;
    Incidence::List dayEvents() const;
    Incidence::List dayTodos() const;
    Incidence::List allIncidences() const;
    Incidence::List allEvents() const;
    Incidence::List allTodos() const;
    Incidence::List toIncidences(const Event::List & eventList) const;
    Incidence::List toIncidences(const Todo::List & todoList) const;
    Incidence::List toIncidences(const Event::List & eventList, const Todo::List & todoList) const;

    int m_filter_mode;
    QDate m_filter_dt;
    int m_filter_hour;
    LocalCalendar *m_calendar;
    Incidence::List m_incidences;
};

#endif //INCIDENCE_MODEL_H
