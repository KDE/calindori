/*
 * SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "daysofmonthmodel.h"
#include <QDebug>

void DaysOfMonthModel::update()
{
    beginResetModel();
    m_dayList = {};

    int totalDays = m_daysPerWeek * m_weeks;

    int daysBeforeCurrentMonth = 0;
    int daysAfterCurrentMonth = 0;

    QDate firstDay(m_year, m_month, 1);

    if (m_firstDayOfWeek < firstDay.dayOfWeek()) {
        daysBeforeCurrentMonth = firstDay.dayOfWeek() - m_firstDayOfWeek;
    } else {
        daysBeforeCurrentMonth = 7 - (m_firstDayOfWeek - firstDay.dayOfWeek());
    }

    int daysThusFar = daysBeforeCurrentMonth + firstDay.daysInMonth();
    if (daysThusFar < totalDays) {
        daysAfterCurrentMonth = totalDays - daysThusFar;
    }

    if (daysBeforeCurrentMonth > 0) {
        QDate previousMonth = firstDay.addMonths(-1);
        for (int i = 0; i < daysBeforeCurrentMonth; i++) {
            DayData day;
            day.isCurrent = false;
            day.dayNumber = previousMonth.daysInMonth() - (daysBeforeCurrentMonth - (i + 1));
            day.monthNumber = previousMonth.month();
            day.yearNumber = previousMonth.year();
            m_dayList << day;
        }
    }

    for (int i = 0; i < firstDay.daysInMonth(); i++) {
        DayData day;
        day.isCurrent = true;
        day.dayNumber = i + 1; // +1 to go form 0 based index to 1 based calendar dates
        day.monthNumber = firstDay.month();
        day.yearNumber = firstDay.year();
        m_dayList << day;

    }

    if (daysAfterCurrentMonth > 0) {
        for (int i = 0; i < daysAfterCurrentMonth; i++) {
            DayData day;
            day.isCurrent = false;
            day.dayNumber = i + 1; // +1 to go form 0 based index to 1 based calendar dates
            day.monthNumber = firstDay.addMonths(1).month();
            day.yearNumber = firstDay.addMonths(1).year();
            m_dayList << day;
        }
    }

    m_dayList[QDate::currentDate().day() + daysBeforeCurrentMonth - 1].isToday = QDate::currentDate().month() == m_month && QDate::currentDate().year() == m_year;

    endResetModel();
}

QVariant DaysOfMonthModel::data(const QModelIndex& index, int role) const
{
    int row = index.row();

    switch (role) {
    case CurrentMonthRole:
        return m_dayList[row].isCurrent;
    case DayNumberRole:
        return m_dayList[row].dayNumber;
    case MonthNumberRole:
        return m_dayList[row].monthNumber;
    case YearNumberRole:
        return m_dayList[row].yearNumber;
    case TodayRole:
        return m_dayList[row].isToday;
    default:
        return QStringLiteral("Deadbeef");
    }
}

QHash<int, QByteArray> DaysOfMonthModel::roleNames() const
{
    return {
        {CurrentMonthRole, "isCurrentMonth"},
        {DayNumberRole, "dayNumber"},
        {MonthNumberRole, "monthNumber"},
        {YearNumberRole, "yearNumber"},
        {TodayRole, "isToday"}
    };
}

void DaysOfMonthModel::goNextMonth()
{
    if (m_month == 12) {
        m_month = 1;
        m_year++;
    } else {
        m_month ++;
    }

    Q_EMIT yearChanged();
    Q_EMIT monthChanged();
    update();
}

void DaysOfMonthModel::goPreviousMonth()
{
    if (m_month == 1) {
        m_month = 12;
        m_year--;
    } else {
        m_month--;
    }

    Q_EMIT yearChanged();
    Q_EMIT monthChanged();
    update();
}

void DaysOfMonthModel::goCurrentMonth()
{
    m_year = QDate::currentDate().year();
    m_month = QDate::currentDate().month();
    Q_EMIT yearChanged();
    Q_EMIT monthChanged();
    update();
}

int DaysOfMonthModel::month() const
{
    return m_month;
}

void DaysOfMonthModel::setMonth(int month)
{
    if (m_month != month) {
        m_month = month;
        Q_EMIT monthChanged();
        update();
    }
}

void DaysOfMonthModel::setYear(int year)
{
    if (m_year != year) {
        m_year = year;
        Q_EMIT yearChanged();
        update();
    }
}

int DaysOfMonthModel::year() const
{
    return m_year;
}

int DaysOfMonthModel::daysPerWeek() const
{
    return m_daysPerWeek;
}

void DaysOfMonthModel::setDaysPerWeek(int daysPerWeek)
{
    if (m_daysPerWeek != daysPerWeek) {
        m_daysPerWeek = daysPerWeek;
        Q_EMIT daysPerWeekChanged();
        update();
    }
}

int DaysOfMonthModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent)
    return m_weeks * m_daysPerWeek;
}

int DaysOfMonthModel::weeks() const
{
    return m_weeks;
}

void DaysOfMonthModel::setWeeks(int weeks)
{
    if (m_weeks != weeks) {
        m_weeks = weeks;
        Q_EMIT weeksChanged();
        update();
    }
}
