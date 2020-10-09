/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
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
    Q_PROPERTY(LocalCalendar *calendar READ calendar WRITE setCalendar NOTIFY calendarChanged)
    Q_PROPERTY(QLocale appLocale READ appLocale WRITE setAppLocale NOTIFY appLocaleChanged)

public:
    explicit IncidenceModel(QObject *parent = nullptr);
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

    enum Roles {
        Uid = Qt::UserRole + 1,
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
        DisplayStartDate,
        Completed,
        IncidenceType,
        DisplayStartEndTime,
        DisplayDueDate,
        DisplayDueTime,
        DisplayStartTime,
        DisplayType,
        Due,
        ValidStartDt,
        ValidEndDt,
        ValidDueDt
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QDate filterDt() const;
    void setFilterDt(const QDate &filterDate);

    int filterHour() const;
    void setFilterHour(const int hour);

    int filterMode() const;
    void setFilterMode(const int mode);

    LocalCalendar *calendar() const;
    void setCalendar(LocalCalendar *calendarPtr);

    QLocale appLocale() const;
    void setAppLocale(const QLocale &qmlLocale);

Q_SIGNALS:
    void filterDtChanged();
    void filterHourChanged();
    void calendarChanged();
    void filterModeChanged();
    void appLocaleChanged();

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
    Incidence::List toIncidences(const Event::List &eventList) const;
    Incidence::List toIncidences(const Todo::List &todoList) const;
    Incidence::List toIncidences(const Event::List &eventList, const Todo::List &todoList) const;
    QString displayStartEndTime(const int idx) const;
    QString eventDisplayStartEndTime(const Event::Ptr event) const;
    QString displayStartDate(const int idx) const;
    QString displayDueDate(const int idx) const;
    QString displayDueTime(const int idx) const;
    QString displayStartTime(const int idx) const;
    bool isHourEvent(const Event::Ptr event) const;
    bool withinFilter(const KCalendarCore::Event::Ptr event, const QDate &filterDate) const;

    int m_filter_mode;
    QDate m_filter_dt;
    int m_filter_hour;
    LocalCalendar *m_calendar;
    Incidence::List m_incidences;
    QLocale m_locale;
};

#endif //INCIDENCE_MODEL_H
