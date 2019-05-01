/*
 * Copyright (C) 2019 Dimitris Kardarakos
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

#ifndef CALENDARFILTER_H
#define CALENDARFILTER_H

#include <QObject>
#include <QSet>
#include <QByteArray> 

class CalendarFilter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QSet<QByteArray> filter READ filter NOTIFY filterChanged)


public:
    explicit CalendarFilter(QObject* parent = nullptr);
    ~CalendarFilter() override;

    QSet<QByteArray> filter() const;

public Q_SLOTS:
    void addFilter(const QVariant & calendarId) ;
    void clearFilter();

Q_SIGNALS:
    void filterChanged();

private:
    QSet<QByteArray> m_filter;
};

#endif // CALENDARFILTER_H

