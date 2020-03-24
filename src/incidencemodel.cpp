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

#include "incidencemodel.h"
#include <KLocalizedString>
#include <QDebug>

using namespace KCalendarCore;

IncidenceModel::IncidenceModel(QObject* parent) :
    QAbstractListModel(parent),
    m_filter_dt(QDate()),
    m_filter_hour(-1),
    m_calendar(nullptr),
    m_incidences(Incidence::List())
{
    connect(this, &IncidenceModel::filterDtChanged, this, &IncidenceModel::loadIncidences);
    connect(this, &IncidenceModel::filterHourChanged, this, &IncidenceModel::loadIncidences);
    connect(this, &IncidenceModel::calendarChanged, this, &IncidenceModel::loadIncidences);
}

IncidenceModel::~IncidenceModel() = default;

QDate IncidenceModel::filterDt() const
{
    return m_filter_dt;
}

void IncidenceModel::setFilterDt(const QDate& filterDate)
{
    m_filter_dt = filterDate;

    Q_EMIT filterDtChanged();
}

int IncidenceModel::filterHour() const
{
    return m_filter_hour;
}

void IncidenceModel::setFilterHour(const int hour)
{
    m_filter_hour = hour;

    Q_EMIT filterHourChanged();
}

LocalCalendar *IncidenceModel::calendar() const
{
    return m_calendar;
}

void IncidenceModel::setCalendar(LocalCalendar *calendarPtr)
{
    m_calendar = calendarPtr;

    connect(m_calendar, &LocalCalendar::eventsChanged, this, &IncidenceModel::loadIncidences);
    connect(m_calendar, &LocalCalendar::todosChanged, this, &IncidenceModel::loadIncidences);

    Q_EMIT calendarChanged();
}

QHash<int, QByteArray> IncidenceModel::roleNames() const
{
    return {
        { Uid, "uid" },
        { DtStart, "dtstart" },
        { AllDay, "allday" },
        { Description, "description" },
        { Summary, "summary" },
        { LastModified, "lastmodified" },
        { Location, "location" },
        { Categories, "categories" },
        { Priority, "priority" },
        { Created, "created" },
        { Secrecy, "secrecy" },
        { EndDate, "dtend" },
        { RepeatPeriodType, "repeatType" },
        { RepeatEvery, "repeatEvery" },
        { RepeatStopAfter, "repeatStopAfter" },
        { IsRepeating, "isRepeating" },
        { DisplayDate, "displayDate" },
        { DisplayTime, "displayTime" },
        { Completed, "completed" },
        { IncidenceType, "type" }
    };
}

QVariant IncidenceModel::data(const QModelIndex& index, int role) const
{
    if(!index.isValid())
        return QVariant();

    int row = index.row();
    auto type = m_incidences.at(row)->type();

    switch(role)
    {
        case Uid:
            return m_incidences.at(row)->uid();
        case DtStart:
            return m_incidences.at(row)->dtStart();
        case AllDay:
            return m_incidences.at(row)->allDay();
        case Description:
            return m_incidences.at(row)->description();
        case Summary:
            return m_incidences.at(row)->summary();
        case LastModified:
            return m_incidences.at(row)->lastModified();
        case Location:
            return m_incidences.at(row)->location();
        case Categories:
            return m_incidences.at(row)->categories();
        case Priority:
            return m_incidences.at(row)->priority();
        case Created:
            return m_incidences.at(row)->created();
        case Secrecy:
            return m_incidences.at(row)->secrecy();
        case EndDate:
            return (type == IncidenceBase::TypeEvent) ? m_incidences.at(row).dynamicCast<Event>()->dtEnd() : QDateTime();
        case RepeatPeriodType:
            return repeatPeriodType(row);
        case RepeatEvery:
            return repeatEvery(row);
        case RepeatStopAfter:
            return repeatStopAfter(row);
        case IsRepeating:
            return m_incidences.at(row)->recurs();
        case DisplayDate:
            return m_incidences.at(row)->dtStart().date().toString(Qt::SystemLocaleLongDate);
        case DisplayTime:
            return m_incidences.at(row)->allDay() ? i18n("All day") : m_incidences.at(row)->dtStart().time().toString("hh:mm");
        case IncidenceType:
            return type;
        default:
            return QVariant();
    }
}

int IncidenceModel::rowCount(const QModelIndex& parent) const
{
    if(parent.isValid())
        return 0;

    return m_incidences.count();
}

void IncidenceModel::loadIncidences()
{
    beginResetModel();
    m_incidences.clear();

    Event::List events;
    Todo::List todos;

    if(m_calendar != nullptr && m_filter_dt.isValid() && m_filter_hour >= 0)
    {
        events = m_calendar->memorycalendar()->rawEventsForDate(m_filter_dt);
        todos = m_calendar->memorycalendar()->rawTodos(m_filter_dt, m_filter_dt);
        //TODO: we should use KCalendarCore::Calendar::incidences, but it probably needs upstream fix: it does not return the todos of the date
        m_incidences = mergedHourList(events, todos);
    }

    endResetModel();
}

int IncidenceModel::repeatEvery(const int idx) const
{
    if(!(m_incidences.at(idx)->recurs())) return 0;

    return m_incidences.at(idx)->recurrence()->frequency();
}

int IncidenceModel::repeatStopAfter(const int idx) const
{

    if(!(m_incidences.at(idx)->recurs())) return -1;

    return m_incidences.at(idx)->recurrence()->duration();
}

ushort IncidenceModel::repeatPeriodType(const int idx) const
{
    if(!(m_incidences.at(idx)->recurs())) return Recurrence::rNone;

    return m_incidences.at(idx)->recurrence()->recurrenceType();
}

Incidence::List IncidenceModel::mergedHourList(const Event::List& eventList, const Todo::List& todoList)
{
    Incidence::List mergedList;
    auto filterDtTime = QDateTime(m_filter_dt).addSecs(m_filter_hour * 3600);

    for(const auto & e : eventList)
    {
        auto startHour =  e->allDay() ? 0 : e->dtStart().time().hour();
        auto endHour =  e->allDay() ? 23 : e->dtEnd().time().hour();

        //If the event starts and ends in the same day, we just check the hours; that way recurring events are fetched as well
        if( (e->dtStart().date() == e->dtEnd().date()) && (startHour <= m_filter_hour) && (endHour >= m_filter_hour) )
        {
            mergedList.append(e);
        }

        //For multi-day events we check that filter datetime is between start and end date
        auto startDtStripTime = QDateTime(e->dtStart().date());
        auto startDtTime =  e->allDay() ? startDtStripTime : startDtStripTime.addSecs(3600 * e->dtStart().time().hour());

        if( (e->dtStart().date() != e->dtEnd().date()) && (startDtTime <= filterDtTime) && (e->dtEnd() >= filterDtTime))
        {
            mergedList.append(e);
        }
    }

    for(const auto & t : todoList)
    {
        auto k = t->allDay() ? 0 : t->dtStart().time().hour();
        if(k == m_filter_hour || t->allDay())
        {
            mergedList.append(t);
        }
    }

    return mergedList;
}




