/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "incidencemodel.h"
#include <KLocalizedString>
#include <QDebug>

using namespace KCalendarCore;

IncidenceModel::IncidenceModel(QObject *parent) :
    QAbstractListModel(parent),
    m_filter_mode(FilterModes::Invalid),
    m_filter_dt(QDate()),
    m_filter_hour(-1),
    m_filter_hide_completed(false),
    m_calendar(nullptr),
    m_incidences(Incidence::List()),
    m_locale(QLocale::system()),
    m_cal_filter(new CalFilter())

{
    connect(this, &IncidenceModel::filterModeChanged, this, &IncidenceModel::loadIncidences);
    connect(this, &IncidenceModel::filterDtChanged, this, &IncidenceModel::loadIncidences);
    connect(this, &IncidenceModel::filterHourChanged, this, &IncidenceModel::loadIncidences);
    connect(this, &IncidenceModel::calendarChanged, this, &IncidenceModel::loadIncidences);
    connect(this, &IncidenceModel::calendarFilterChanged, this, &IncidenceModel::loadIncidences);
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

void IncidenceModel::setFilterDt(const QDate &filterDate)
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
    setCalendarFilter();

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

QVariant IncidenceModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

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
        if (type == IncidenceBase::TypeEvent) {
            return i18n("Event");
        } else if (type == IncidenceBase::TypeTodo) {
            return i18n("Task");
        } else {
            return QString();
        }
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

int IncidenceModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_incidences.count();
}

void IncidenceModel::loadIncidences()
{
    beginResetModel();
    m_incidences.clear();

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
    if (!(m_incidences.at(idx)->recurs())) {
        return 0;
    }

    return m_incidences.at(idx)->recurrence()->frequency();
}

int IncidenceModel::repeatStopAfter(const int idx) const
{

    if (!(m_incidences.at(idx)->recurs())) {
        return -1;
    }

    return m_incidences.at(idx)->recurrence()->duration();
}

ushort IncidenceModel::repeatPeriodType(const int idx) const
{
    if (!(m_incidences.at(idx)->recurs())) {
        return Recurrence::rNone;
    }

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
    const auto dayEventList = dayEvents();

    for (const auto &d : dayEventList) {
        auto e = d.dynamicCast<Event>();
        if (isHourEvent(e)) {
            incidences.append(e);
        }

    }

    return incidences;
}

bool IncidenceModel::isHourEvent(const Event::Ptr event) const
{
    auto startDate = event->dtStart().toTimeZone(QTimeZone::systemTimeZone()).date();
    auto endDate = event->dtEnd().toTimeZone(QTimeZone::systemTimeZone()).date();
    auto allDay = event->allDay();
    auto eventDuration = event->dtStart().secsTo(event->dtEnd());

    if (allDay) {
        return true;
    }

    if (!event->recurs()) { // Non-repeating event
        if ((m_filter_dt != startDate) && (m_filter_dt != endDate)) {
            // - The filter date is a date that the event does occur (because it has been included in the dayEventList)
            // - The filter date is not the first or the last - so it is in the middle
            // -> We include it whatever the filter hour
            return true;
        } else {
            if (withinFilter(event, m_filter_dt)) {
                return true;
            }
        }
    } else { //Repeating event

        if (event->recursOn(m_filter_dt, QTimeZone::systemTimeZone())) {
            // filter date == event recurrence start date
            // in case of two day events that repeat daily, we check both start and end date

            if ((event->recurrence()->recurrenceType() == Recurrence::rDaily) && event->isMultiDay() && eventDuration < 86400 && (m_filter_dt != startDate)) {
                return withinFilter(event, startDate) ||  withinFilter(event, endDate);
            } else {
                return withinFilter(event, startDate);
            }
        } else { // We know that the event does occur on m_filter_dt. We know that m_filter_dt is not the first day of the event. Let's find the start date of the recurrence we are interested in
            auto d { m_filter_dt.startOfDay() };
            d.setTime(event->dtEnd().toTimeZone(QTimeZone::systemTimeZone()).time());
            d = d.addSecs(-1 * eventDuration);
            if (event->recursOn(d.date(), QTimeZone::systemTimeZone())) {
                if (withinFilter(event, endDate)) {
                    return true;
                }
            } else {
                return true;
            }
        }
    }

    return false;
}

bool IncidenceModel::withinFilter(const KCalendarCore::Event::Ptr event, const QDate &filterDate) const
{
    auto filterStart = filterDate.startOfDay(QTimeZone::systemTimeZone()).addSecs(m_filter_hour * 3600);
    auto filterEnd = filterDate.startOfDay(QTimeZone::systemTimeZone()).addSecs(m_filter_hour * 3600 + 3599);

    auto eventStartWithinFilter = event->dtStart().toTimeZone(QTimeZone::systemTimeZone()) >= filterStart && event->dtStart().toTimeZone(QTimeZone::systemTimeZone()) <= filterStart;
    auto eventEndWithinFilter = event->dtEnd().toTimeZone(QTimeZone::systemTimeZone()) > filterStart && event->dtEnd().toTimeZone(QTimeZone::systemTimeZone()) <= filterEnd;
    auto filterWithinEvent =  event->dtStart().toTimeZone(QTimeZone::systemTimeZone()) < filterStart && filterEnd < event->dtEnd().toTimeZone(QTimeZone::systemTimeZone());

    if (eventStartWithinFilter || eventEndWithinFilter || filterWithinEvent) {
        return true;
    }

    return false;
}

Incidence::List IncidenceModel::hourTodos() const
{
    Incidence::List incidences;
    const auto dayTodoList = dayTodos();

    for (const auto &t : dayTodoList) {
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
    auto events = m_calendar->memorycalendar()->rawEventsForDate(m_filter_dt, QTimeZone::systemTimeZone(), EventSortStartDate, SortDirectionAscending);
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
    auto todos =  m_calendar->memorycalendar()->todos(TodoSortDueDate, SortDirectionDescending);

    return toIncidences(todos);
}

Incidence::List IncidenceModel::allEvents() const
{
    auto events = m_calendar->memorycalendar()->rawEvents(EventSortStartDate, SortDirectionDescending);

    return toIncidences(events);
}

Incidence::List IncidenceModel::toIncidences(const Event::List &eventList) const
{
    Incidence::List incidences;

    for (const auto &e : eventList) {
        incidences.append(e.dynamicCast<Incidence>());
    }

    return incidences;
}

Incidence::List IncidenceModel::toIncidences(const Todo::List &todoList) const
{
    Incidence::List incidences;

    for (const auto &e : todoList) {
        incidences.append(e.dynamicCast<Incidence>());
    }

    return incidences;
}

QString IncidenceModel::displayStartEndTime(const int idx) const
{
    auto incidence = m_incidences.at(idx);

    if (incidence->type() == IncidenceBase::TypeEvent) {
        return eventDisplayStartEndTime(incidence.dynamicCast<Event>());
    }

    return QString();
}

QString IncidenceModel::eventDisplayStartEndTime(const Event::Ptr event) const
{
    auto startDateTime = event->dtStart().toTimeZone(QTimeZone::systemTimeZone());
    auto endDateTime = event->dtEnd().toTimeZone(QTimeZone::systemTimeZone());

    if (event->allDay()) {
        return QString("%1 %2").arg(m_locale.toString(startDateTime, "MMM d"), i18n("all-day"));
    }

    if (startDateTime.date() != endDateTime.date()) {
        return QString("%1 %2 - %3 %4").arg(m_locale.toString(startDateTime, "MMM d"), m_locale.toString(startDateTime, "hh:mm"), m_locale.toString(endDateTime, "MMM d"), m_locale.toString(endDateTime, "hh:mm"));
    } else {
        return QString("%1 - %2").arg(m_locale.toString(startDateTime, "hh:mm"), m_locale.toString(endDateTime, "hh:mm"));
    }

    return QString();
}

QString IncidenceModel::displayStartDate(const int idx) const
{
    auto incidence = m_incidences.at(idx);

    if (incidence->dtStart().isValid()) {
        return m_locale.toString(incidence->dtStart().toTimeZone(QTimeZone::systemTimeZone()).date(), "MMM d");
    }

    return QString();
}

QString IncidenceModel::displayDueDate(const int idx) const
{
    auto incidence = m_incidences.at(idx);

    if ((incidence->type() == IncidenceBase::TypeTodo) && (incidence.dynamicCast<Todo>()->dtDue().isValid())) {
        return m_locale.toString(incidence.dynamicCast<Todo>()->dtDue().toTimeZone(QTimeZone::systemTimeZone()).date(), "MMM d");
    }

    return i18n("No Due Date");
}

QString IncidenceModel::displayDueTime(const int idx) const
{
    auto incidence = m_incidences.at(idx);

    if (incidence->allDay()) {
        return i18n("all-day");
    }

    if (incidence->type() == IncidenceBase::TypeTodo) {
        auto todo = incidence.dynamicCast<Todo>();
        return todo->dtDue().isValid() ? m_locale.toString(todo->dtDue().toTimeZone(QTimeZone::systemTimeZone()).time(), "hh:mm") : QString();
    }

    return QString();
}

QString IncidenceModel::displayStartTime(const int idx) const
{
    auto incidence = m_incidences.at(idx);
    auto startDt = incidence->dtStart().toTimeZone(QTimeZone::systemTimeZone());

    if (incidence->allDay()) {
        return i18n("all-day");
    }

    return startDt.isValid() ? m_locale.toString(startDt.time(), "hh:mm") : QString();
}

void IncidenceModel::setAppLocale(const QLocale &qmlLocale)
{
    m_locale = qmlLocale;

    Q_EMIT appLocaleChanged();
}

QLocale IncidenceModel::appLocale() const
{
    return m_locale;
}

bool IncidenceModel::filterHideCompleted() const
{
    return m_filter_hide_completed;
}

void IncidenceModel::setFilterHideCompleted(const bool hideCompleted)
{
    m_filter_hide_completed = hideCompleted;

    m_cal_filter = new CalFilter;
    if (m_filter_hide_completed) {
        m_cal_filter->setCriteria(CalFilter::HideCompletedTodos);
    }
    setCalendarFilter();

    Q_EMIT filterHideCompletedChanged();
}

void IncidenceModel::setCalendarFilter()
{
    if (m_calendar != nullptr) {
        m_calendar->memorycalendar()->setFilter(m_cal_filter);
    }

    Q_EMIT calendarFilterChanged();
}
