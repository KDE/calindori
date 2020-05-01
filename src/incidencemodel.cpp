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

using namespace KCalendarCore;

IncidenceModel::IncidenceModel(QObject* parent) :
    QAbstractListModel(parent),
    m_filter_mode(FilterModes::Invalid),
    m_filter_dt(QDate()),
    m_filter_hour(-1),
    m_calendar(nullptr),
    m_incidences(Incidence::List())
{
    connect(this, &IncidenceModel::filterModeChanged, this, &IncidenceModel::loadIncidences);
    connect(this, &IncidenceModel::filterDtChanged, this, &IncidenceModel::loadIncidences);
    connect(this, &IncidenceModel::filterHourChanged, this, &IncidenceModel::loadIncidences);
    connect(this, &IncidenceModel::calendarChanged, this, &IncidenceModel::loadIncidences);
}

IncidenceModel::~IncidenceModel() = default;

int IncidenceModel::filterMode() const
{
    return m_filter_mode;
}

void IncidenceModel::setFilterMode(const int mode)
{
    m_filter_mode = mode;

    Q_EMIT filterModeChanged();
}


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
        case Completed:
            return (type == IncidenceBase::TypeTodo) ? m_incidences.at(row).dynamicCast<Todo>()->isCompleted() : false;
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

    auto hourModelReady = (m_calendar != nullptr && m_filter_dt.isValid() && m_filter_hour >= 0);
    auto dayModelReady = (m_calendar != nullptr && m_filter_dt.isValid());
    auto allModelReady = (m_calendar != nullptr);

    switch(m_filter_mode)
    {
        case FilterModes::HourIncidences:
        {
            m_incidences = (hourModelReady) ? hourIncidences() : m_incidences;
            break;
        }
        case FilterModes::HourEvents:
        {
            m_incidences = (hourModelReady) ? hourEvents() : m_incidences;
            break;
        }
        case FilterModes::HourTodos:
        {
            m_incidences = (hourModelReady) ? hourTodos() : m_incidences;
            break;
        }
        case FilterModes::DayIncidences:
        {
            m_incidences = (dayModelReady) ? dayIncidences() : m_incidences;
            break;
        }
        case FilterModes::DayEvents:
        {
            m_incidences = (dayModelReady) ? dayEvents() : m_incidences;
            break;
        }
        case FilterModes::DayTodos:
        {
            m_incidences = (dayModelReady) ? dayTodos() : m_incidences;
            break;
        }
        case FilterModes::AllIncidences:
        {
            m_incidences = (allModelReady) ? allIncidences() : m_incidences;
            break;
        }
        case FilterModes::AllEvents:
        {
            m_incidences = (allModelReady) ? allEvents() : m_incidences;
            break;
        }
        case FilterModes::AllTodos:
        {
            m_incidences = (allModelReady) ? allTodos() : m_incidences;
            break;
        }
        case Invalid:
            break;
        default:
            break;
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

Incidence::List IncidenceModel::hourIncidences() const
{
    auto incidences = hourEvents();
    incidences.append(hourTodos());

    return incidences;
}

Incidence::List IncidenceModel::hourEvents() const
{
    Incidence::List incidences;
    auto filterDtTime = QDateTime(m_filter_dt).addSecs(m_filter_hour * 3600);
    auto dayEventList = dayEvents();

    for(const auto & d : dayEventList)
    {
        auto e = d.dynamicCast<Event>();
        auto startHour =  e->allDay() ? 0 : e->dtStart().time().hour();
        auto endHour =  e->allDay() ? 23 : e->dtEnd().time().hour();

        //If the event starts and ends in the same day, we just check the hours; that way recurring events are fetched as well
        if( (e->dtStart().date() == e->dtEnd().date()) && (startHour <= m_filter_hour) && (endHour > m_filter_hour) )
        {
            incidences.append(e);
        }

        //For multi-day events we check that filter datetime is between start and end date
        auto startDtStripTime = QDateTime(e->dtStart().date());
        auto startDtTime =  e->allDay() ? startDtStripTime : startDtStripTime.addSecs(3600 * e->dtStart().time().hour());

        if( (e->dtStart().date() != e->dtEnd().date()) && (startDtTime <= filterDtTime) && (e->dtEnd() >= filterDtTime))
        {
            incidences.append(e);
        }
    }

    return incidences;
}

Incidence::List IncidenceModel::hourTodos() const
{
    Incidence::List incidences;
    auto dayTodoList = dayTodos();

    for(const auto & t : dayTodoList)
    {
        auto k = t->allDay() ? 0 : t->dtStart().time().hour();
        if(k == m_filter_hour || t->allDay())
        {
            incidences.append(t);
        }
    }

    return incidences;
}

Incidence::List IncidenceModel::dayIncidences() const
{
    auto incidences = dayEvents();
    incidences.append(dayTodos());

    return incidences;
}

Incidence::List IncidenceModel::dayEvents() const
{
    auto events = m_calendar->memorycalendar()->rawEventsForDate(m_filter_dt);

    return toIncidences(events);
}

Incidence::List IncidenceModel::dayTodos() const
{
    auto todos =  m_calendar->memorycalendar()->rawTodos(m_filter_dt,m_filter_dt);

    return toIncidences(todos);
}

Incidence::List IncidenceModel::allIncidences() const
{
    auto incidences = m_calendar->memorycalendar()->rawIncidences();

    return incidences;
}

Incidence::List IncidenceModel::allTodos() const
{
    auto todos =  m_calendar->memorycalendar()->rawTodos(TodoSortStartDate, SortDirectionDescending);

    return toIncidences(todos);
}

Incidence::List IncidenceModel::allEvents() const
{
    auto events = m_calendar->memorycalendar()->rawEvents(EventSortStartDate, SortDirectionDescending);

    return toIncidences(events);
}

Incidence::List IncidenceModel::toIncidences(const Event::List& eventList) const
{
    Incidence::List incidences;

    for(const auto & e : eventList)
    {
        incidences.append(e.dynamicCast<Incidence>());
    }

    return incidences;
}

Incidence::List IncidenceModel::toIncidences(const Todo::List& todoList) const
{
    Incidence::List incidences;

    for(const auto & e : todoList)
    {
        incidences.append(e.dynamicCast<Incidence>());
    }

    return incidences;
}

