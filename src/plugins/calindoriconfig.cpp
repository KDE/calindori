/*
 * Copyright (C) 2018 Dimitris Kardarakos
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

#include "calindoriconfig.h"

#include <KConfig>
#include <KConfigGroup>
#include <QDebug>
class CalindoriConfig::Private
{
public:
    Private()
        : config("calindorirc")
    {};
    KConfig config;
};

CalindoriConfig::CalindoriConfig(QObject* parent)
    : QObject(parent)
    , d(new Private)
{
    QString calendars = d->config.group("general").readEntry("calendars", QString());
    if(calendars.isEmpty()) {
        qDebug() << "No calendar found, creating a default one";
        addCalendar("personal");
        setActiveLocalCalendar("personal");
        d->config.sync();
    }
}

CalindoriConfig::~CalindoriConfig()
{
    delete d;
}

QString CalindoriConfig::calendars() const
{
   return d->config.group("general").readEntry("calendars", QString());
}

QString CalindoriConfig::activeLocalCalendar() const
{
    return d->config.group("general").readEntry("activeLocalCalendar", QString());
}

QString CalindoriConfig::activeOnlineCalendar() const
{
    return d->config.group("general").readEntry("activeOnlineCalendar", QString());
}

void CalindoriConfig::setActiveLocalCalendar(const QString & calendar)
{
    d->config.group("general").writeEntry("activeLocalCalendar", calendar);
    d->config.sync();
    emit activeLocalCalendarChanged();
}

void CalindoriConfig::setActiveOnlineCalendar(const QString & calendar)
{
    d->config.group("general").writeEntry("activeOnlineCalendar", calendar);
    d->config.sync();
    emit activeOnlineCalendarChanged();
}

QString CalindoriConfig::addCalendar(const QString & calendar)
{
    if(calendar.contains(";"))
    {
        return "Calendar name should not contain semicolons";
    }

    if(d->config.group("general").readEntry("calendars", QString()).isEmpty())
    {
        qDebug() << "Calendar list is empty";
        d->config.group("general").writeEntry("calendars", calendar);
        return QString();
    }

    qDebug() << "Calendar list is not empty, adding calendar " << calendar;
    QStringList calendarsList = d->config.group("general").readEntry("calendars", QString()).split(";");

    if(calendarsList.contains(calendar))
    {
        return "Calendar already exists";
    }

    calendarsList.append(calendar);
    d->config.group("general").writeEntry("calendars", calendarsList.join(";"));
    d->config.sync();

    emit calendarsChanged();

    return QString();
}

void CalindoriConfig::removeCalendar(const QString& calendar)
{
    QStringList calendarsList = d->config.group("general").readEntry("calendars", QString()).split(";");
    if(calendarsList.contains(calendar))
    {
        qDebug() << "Removing calendar " << calendar;
        calendarsList.removeAll(calendar);
        d->config.group("general").writeEntry("calendars", calendarsList.join(";"));
        d->config.sync();
        emit calendarsChanged();
    }
}
