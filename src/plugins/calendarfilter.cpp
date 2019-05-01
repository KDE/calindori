
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

#include "calendarfilter.h"
#include <QDebug>

CalendarFilter::CalendarFilter(QObject* parent): QObject(parent)
{}


CalendarFilter::~CalendarFilter() = default;

QSet<QByteArray> CalendarFilter::filter() const
{
    return m_filter;
}


void CalendarFilter::addFilter(const QVariant & calendarId )
{
    m_filter.insert(calendarId.toByteArray());
    emit filterChanged();
}

void CalendarFilter::clearFilter()
{
    m_filter.clear();
    emit filterChanged();
}
