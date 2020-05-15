/*
 * SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
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
