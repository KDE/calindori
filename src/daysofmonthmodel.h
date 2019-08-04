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

#ifndef DAYSOFMONTHMODEL_H
#define DAYSOFMONTHMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QDate>
#include <QLocale>

struct DayData
{
    bool isCurrent;
    int dayNumber;
    int monthNumber;
    int yearNumber;
    bool isToday = false;
};

class DaysOfMonthModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int year READ year WRITE setYear NOTIFY yearChanged)
    Q_PROPERTY(int month READ month WRITE setMonth NOTIFY monthChanged)
    Q_PROPERTY(int daysPerWeek READ daysPerWeek WRITE setDaysPerWeek NOTIFY daysPerWeekChanged)
    Q_PROPERTY(int weeks READ weeks WRITE setWeeks NOTIFY weeksChanged)
public:
    enum Roles {
        CurrentMonthRole = Qt::UserRole + 1,
        DayNumberRole,
        MonthNumberRole,
        YearNumberRole,
        TodayRole
    };

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex & index, int role) const override;
    int rowCount(const QModelIndex & parent) const override;

    int year() const;
    void setYear(int year);

    int month() const;
    void setMonth(int month);

    int daysPerWeek() const;
    void setDaysPerWeek(int daysPerWeek);

    int weeks() const;
    void setWeeks(int weeks);

    Q_INVOKABLE void goNextMonth();
    Q_INVOKABLE void goPreviousMonth();
    Q_INVOKABLE void goCurrentMonth();
    Q_INVOKABLE void update();

Q_SIGNALS:
    void yearChanged();
    void monthChanged();
    void daysPerWeekChanged();
    void weeksChanged();

private:

    QVector<DayData> m_dayList;
    int m_firstDayOfWeek = QLocale::system().firstDayOfWeek();
    int m_year;
    int m_month;
    int m_daysPerWeek = 7;
    int m_weeks = 6;
};

#endif // DAYSOFMONTHMODEL_H
