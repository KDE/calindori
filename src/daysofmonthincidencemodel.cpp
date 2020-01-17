/*
 *   Copyright 2019 Nicolas Fella <nicolas.fella@gmx.de>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "daysofmonthincidencemodel.h"
#include <QDebug>

QVariant DaysOfMonthIncidenceModel::data(const QModelIndex& index, int role) const
{
    if (!m_calendar) {
        return DaysOfMonthModel::data(index, role);;
    }

    switch (role) {
        case IncidenceCount: {
            QDate date(DaysOfMonthModel::data(index, YearNumberRole).toInt(), DaysOfMonthModel::data(index, MonthNumberRole).toInt(), DaysOfMonthModel::data(index, DayNumberRole).toInt());

            return m_calendar->todosCount(date) + m_calendar->eventsCount(date);
        }
        default:
            return DaysOfMonthModel::data(index, role);
    }
}

QHash<int, QByteArray> DaysOfMonthIncidenceModel::roleNames() const
{
    QHash<int, QByteArray> parentRoles = DaysOfMonthModel::roleNames();
    parentRoles[IncidenceCount] = "incidenceCount";
    return parentRoles;
}

LocalCalendar * DaysOfMonthIncidenceModel::calendar() const
{
    return m_calendar;
}

void DaysOfMonthIncidenceModel::setCalendar(LocalCalendar* calendar)
{
    qDebug() << this << "set cal" << calendar;
    if (m_calendar != calendar) {
        m_calendar = calendar;
        Q_EMIT calendarChanged();
        connect(m_calendar, &LocalCalendar::todosChanged, this, [this] {
            Q_EMIT dataChanged(index(0,0), index(rowCount(QModelIndex()) - 1));
        });
        connect(m_calendar, &LocalCalendar::eventsChanged, this, [this] {
            Q_EMIT dataChanged(index(0,0), index(rowCount(QModelIndex()) - 1));
        });
    }
}
