/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
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
        { DisplayStartDate, "displayStartDate" },
        { DisplayDueDate, "displayDueDate" },
        { DisplayDueTime, "displayDueTime" },
        { DisplayStartEndTime, "displayStartEndTime" },
        { DisplayStartTime, "displayStartTime" },
        { DisplayType, "displayType" },
        { Completed, "completed" },
        { IncidenceType, "type" },
        { Due, "due" },
        { ValidStartDt, "validStartDt" },
        { ValidEndDt, "validEndDt" },
        { ValidDueDt, "validDueDt" }
    };
}

QVariant IncidenceModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid())
        return QVariant();

    int row = index.row();
    auto type = m_incidences.at(row)->type();

    switch (role) {
    case Uid:
        return m_incidences.at(row)->uid();
    case DtStart:
        return m_incidences.at(row)->dtStart().toTimeZone(QTimeZone::systemTimeZone());
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
        return (type == IncidenceBase::TypeEvent) ? m_incidences.at(row).dynamicCast<Event>()->dtEnd().toTimeZone(QTimeZone::systemTimeZone()) : QDateTime();
    case RepeatPeriodType:
        return repeatPeriodType(row);
    case RepeatEvery:
        return repeatEvery(row);
    case RepeatStopAfter:
        return repeatStopAfter(row);
    case IsRepeating:
        return m_incidences.at(row)->recurs();
    case DisplayStartDate:
        return displayStartDate(row);
    case DisplayDueDate:
        return displayDueDate(row);
    case DisplayStartEndTime:
        return displayStartEndTime(row);
    case DisplayDueTime:
        return displayDueTime(row);
    case DisplayStartTime:
        return displayStartTime(row);
    case DisplayType: {
        if (type == IncidenceBase::TypeEvent)
            return i18n("Event");
        else if (type == IncidenceBase::TypeTodo)
            return i18n("Task");
        else
            return QString();
    }
    case Completed:
        return (type == IncidenceBase::TypeTodo) ? m_incidences.at(row).dynamicCast<Todo>()->isCompleted() : false;
    case IncidenceType:
        return type;
    case Due:
        return (type == IncidenceBase::TypeTodo) ? m_incidences.at(row).dynamicCast<Todo>()->dtDue().toTimeZone(QTimeZone::systemTimeZone()) : QDateTime();
    case ValidStartDt:
        return m_incidences.at(row)->dtStart().toTimeZone(QTimeZone::systemTimeZone()).isValid();
    case ValidEndDt:
        return ((type == IncidenceBase::TypeEvent) && m_incidences.at(row).dynamicCast<Event>()->hasEndDate());
    case ValidDueDt:
        return ((type == IncidenceBase::TypeTodo) && m_incidences.at(row).dynamicCast<Todo>()->hasDueDate());
    default:
        return QVariant();
    }
}

int IncidenceModel::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid())
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

    switch (m_filter_mode) {
    case FilterModes::HourIncidences: {
        m_incidences = (hourModelReady) ? hourIncidences() : m_incidences;
        break;
    }
    case FilterModes::HourEvents: {
        m_incidences = (hourModelReady) ? hourEvents() : m_incidences;
        break;
    }
    case FilterModes::HourTodos: {
        m_incidences = (hourModelReady) ? hourTodos() : m_incidences;
        break;
    }
    case FilterModes::DayIncidences: {
        m_incidences = (dayModelReady) ? dayIncidences() : m_incidences;
        break;
    }
    case FilterModes::DayEvents: {
        m_incidences = (dayModelReady) ? dayEvents() : m_incidences;
        break;
    }
    case FilterModes::DayTodos: {
        m_incidences = (dayModelReady) ? dayTodos() : m_incidences;
        break;
    }
    case FilterModes::AllIncidences: {
        m_incidences = (allModelReady) ? allIncidences() : m_incidences;
        break;
    }
    case FilterModes::AllEvents: {
        m_incidences = (allModelReady) ? allEvents() : m_incidences;
        break;
    }
    case FilterModes::AllTodos: {
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
    if (!(m_incidences.at(idx)->recurs())) return 0;

    return m_incidences.at(idx)->recurrence()->frequency();
}

int IncidenceModel::repeatStopAfter(const int idx) const
{

    if (!(m_incidences.at(idx)->recurs())) return -1;

    return m_incidences.at(idx)->recurrence()->duration();
}

ushort IncidenceModel::repeatPeriodType(const int idx) const
{
    if (!(m_incidences.at(idx)->recurs())) return Recurrence::rNone;

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
    auto filterStartDtTime = QDateTime(m_filter_dt).addSecs(m_filter_hour * 3600).toTimeZone(QTimeZone::systemTimeZone());
    auto filterEndtDtTime = QDateTime(m_filter_dt).addSecs(m_filter_hour * 3600 + 3599).toTimeZone(QTimeZone::systemTimeZone());
    auto dayEventList = dayEvents();

    for (const auto & d : dayEventList) {
        auto e = d.dynamicCast<Event>();

        auto eventStartWithinFilter = e->dtStart().toTimeZone(QTimeZone::systemTimeZone()) >= filterStartDtTime && e->dtStart().toTimeZone(QTimeZone::systemTimeZone()) <= filterEndtDtTime;
        auto eventEndWithinFilter = e->dtEnd().toTimeZone(QTimeZone::systemTimeZone()) > filterStartDtTime && e->dtEnd().toTimeZone(QTimeZone::systemTimeZone()) <= filterEndtDtTime;
        auto filterWithinEvent =  e->dtStart().toTimeZone(QTimeZone::systemTimeZone()) < filterStartDtTime && filterEndtDtTime < e->dtEnd().toTimeZone(QTimeZone::systemTimeZone());

        if ((eventStartWithinFilter || eventEndWithinFilter || filterWithinEvent)) {
            incidences.append(e);
        }

    }

    return incidences;
}

Incidence::List IncidenceModel::hourTodos() const
{
    Incidence::List incidences;
    auto dayTodoList = dayTodos();

    for (const auto & t : dayTodoList) {
        auto todo =  t.dynamicCast<Todo>();
        auto k = t->allDay() ? 0 : (todo->dtDue().isValid() ? todo->dtDue().toTimeZone(QTimeZone::systemTimeZone()).time().hour() : todo->dtStart().toTimeZone(QTimeZone::systemTimeZone()).time().hour());
        if (k == m_filter_hour || t->allDay()) {
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
    auto events = m_calendar->memorycalendar()->rawEvents(m_filter_dt, m_filter_dt, QTimeZone::systemTimeZone());
    return toIncidences(Calendar::sortEvents(events, EventSortField::EventSortStartDate, SortDirection::SortDirectionAscending));
}

Incidence::List IncidenceModel::dayTodos() const
{
    auto todos =  m_calendar->memorycalendar()->rawTodos(m_filter_dt, m_filter_dt);

    return toIncidences(Calendar::sortTodos(todos, TodoSortField::TodoSortDueDate, SortDirection::SortDirectionAscending));
}

Incidence::List IncidenceModel::allIncidences() const
{
    auto incidences = m_calendar->memorycalendar()->rawIncidences();

    return incidences;
}

Incidence::List IncidenceModel::allTodos() const
{
    auto todos =  m_calendar->memorycalendar()->rawTodos(TodoSortDueDate, SortDirectionDescending);

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

    for (const auto & e : eventList) {
        incidences.append(e.dynamicCast<Incidence>());
    }

    return incidences;
}

Incidence::List IncidenceModel::toIncidences(const Todo::List& todoList) const
{
    Incidence::List incidences;

    for (const auto & e : todoList) {
        incidences.append(e.dynamicCast<Incidence>());
    }

    return incidences;
}

QString IncidenceModel::displayStartEndTime(const int idx) const
{
    auto incidence = m_incidences.at(idx);

    if (incidence->allDay()) {
        return QString();
    }

    if (incidence->type() == IncidenceBase::TypeEvent && incidence.dynamicCast<Event>()->dtEnd().isValid()) {
        return QString("%1 - %2").arg(incidence->dtStart().toTimeZone(QTimeZone::systemTimeZone()).time().toString("hh:mm")).arg(incidence.dynamicCast<Event>()->dtEnd().toTimeZone(QTimeZone::systemTimeZone()).time().toString("hh:mm"));
    }

    return incidence->dtStart().toTimeZone(QTimeZone::systemTimeZone()).time().toString("hh:mm");
}

QString IncidenceModel::displayStartDate(const int idx) const
{
    auto incidence = m_incidences.at(idx);

    if (incidence->dtStart().isValid())
        return incidence->dtStart().toTimeZone(QTimeZone::systemTimeZone()).date().toString(Qt::SystemLocaleLongDate);

    return QString();
}

QString IncidenceModel::displayDueDate(const int idx) const
{
    auto incidence = m_incidences.at(idx);

    if ((incidence->type() == IncidenceBase::TypeTodo) && (incidence.dynamicCast<Todo>()->dtDue().isValid()))
        return incidence.dynamicCast<Todo>()->dtDue().toTimeZone(QTimeZone::systemTimeZone()).date().toString(Qt::SystemLocaleLongDate);

    return i18n("Unspecified due date");
}

QString IncidenceModel::displayDueTime(const int idx) const
{
    auto incidence = m_incidences.at(idx);

    if (incidence->allDay()) {
        return QString();
    }

    if (incidence->type() == IncidenceBase::TypeTodo) {
        auto todo = incidence.dynamicCast<Todo>();
        return todo->dtDue().isValid() ? todo->dtDue().toTimeZone(QTimeZone::systemTimeZone()).time().toString("hh:mm") : QString();
    }

    return QString();
}

QString IncidenceModel::displayStartTime(const int idx) const
{
    auto incidence = m_incidences.at(idx);

    if (incidence->allDay()) {
        return QString();
    }

    if (incidence->type() == IncidenceBase::TypeTodo) {
        auto todo = incidence.dynamicCast<Todo>();
        return todo->dtStart().toTimeZone(QTimeZone::systemTimeZone()).isValid() ? todo->dtStart().toTimeZone(QTimeZone::systemTimeZone()).time().toString("hh:mm") : QString();
    }

    return QString();
}
