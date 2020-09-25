/*
 * SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef DAYSOFMONTHINCIDENCEMODEL_H
#define DAYSOFMONTHINCIDENCEMODEL_H

#include "daysofmonthmodel.h"
#include "localcalendar.h"

class DaysOfMonthIncidenceModel : public DaysOfMonthModel
{
    Q_OBJECT
    Q_PROPERTY(LocalCalendar *calendar READ calendar WRITE setCalendar NOTIFY calendarChanged)
public:
    enum ExtraRoles {
        IncidenceCount = TodayRole + 1
    };

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;

    LocalCalendar *calendar() const;
    void setCalendar(LocalCalendar *calendar);

Q_SIGNALS:
    void calendarChanged();

private:
    LocalCalendar *m_calendar = nullptr;
};

#endif // DAYSOFMONTHINCIDENCEMODEL_H

