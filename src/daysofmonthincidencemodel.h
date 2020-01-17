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

#ifndef DAYSOFMONTHINCIDENCEMODEL_H
#define DAYSOFMONTHINCIDENCEMODEL_H

#include "daysofmonthmodel.h"
#include "localcalendar.h"

class DaysOfMonthIncidenceModel : public DaysOfMonthModel
{
    Q_OBJECT
    Q_PROPERTY(LocalCalendar* calendar READ calendar WRITE setCalendar NOTIFY calendarChanged)
public:
    enum ExtraRoles {
        IncidenceCount = TodayRole + 1
    };

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex & index, int role) const override;

    LocalCalendar *calendar() const;
    void setCalendar(LocalCalendar *calendar);

Q_SIGNALS:
    void calendarChanged();

private:
    LocalCalendar *m_calendar = nullptr;
};

#endif // DAYSOFMONTHINCIDENCEMODEL_H

