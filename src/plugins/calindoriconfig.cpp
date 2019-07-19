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

#include "calindoriconfig.h"

#include <KLocalizedString>
#include <KConfig>
#include <KConfigGroup>
#include <QDebug>
#include <QRegExp>

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
        setActiveCalendar("personal");
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

QString CalindoriConfig::activeCalendar() const
{
    return d->config.group("general").readEntry("activeCalendar", QString());
}


void CalindoriConfig::setActiveCalendar(const QString & calendar)
{
    d->config.group("general").writeEntry("activeCalendar", calendar);
    d->config.sync();
    emit activeCalendarChanged();
}

QVariantMap CalindoriConfig::canAddCalendar(const QString& calendar)
{
    QVariantMap result;
    result["success"] = QVariant(true);
    result["reason"] = QVariant(QString());

    QRegExp invalidChars("[\\;\\\\/<>:\\?\\*|\"\']");
    if(calendar.contains(invalidChars))
    {
        result["success"] = QVariant(false);
        result["reason"] = QVariant(i18n("Calendar name contains invalid characters"));
        return result;
    }

    if(d->config.group("general").readEntry("calendars", QString()).isEmpty())
    {
        return result;
    }

    QStringList calendarsList = d->config.group("general").readEntry("calendars", QString()).split(";");

    if(calendarsList.contains(calendar))
    {
        result["success"] = QVariant(false);
        result["reason"] = QVariant(i18n("Calendar already exists"));
        return result;
    }

    return result;
}

QVariantMap CalindoriConfig::addCalendar(const QString & calendar)
{
    QVariantMap result;
    result["success"] = QVariant(true);
    result["reason"] = QVariant(QString());

    QVariantMap canAddResult = canAddCalendar(calendar);

    if(!(canAddResult["success"].toBool()))
    {
        result["success"] = QVariant(false);
        result["reason"] = QVariant(canAddResult["reason"].toString());
        return result;
    }

    if(d->config.group("general").readEntry("calendars", QString()).isEmpty())
    {
        d->config.group("general").writeEntry("calendars", calendar);
        d->config.sync();

        return result;
    }

    QStringList calendarsList = d->config.group("general").readEntry("calendars", QString()).split(";");
    calendarsList.append(calendar);
    d->config.group("general").writeEntry("calendars", calendarsList.join(";"));
    d->config.sync();

    emit calendarsChanged();

    return result;
}

void CalindoriConfig::removeCalendar(const QString& calendar)
{
    d->config.reparseConfiguration();
    QStringList calendarsList = d->config.group("general").readEntry("calendars", QString()).split(";");
    if(calendarsList.contains(calendar))
    {
        qDebug() << "Removing calendar " << calendar;
        calendarsList.removeAll(calendar);

        d->config.deleteGroup(calendar);
        d->config.group("general").writeEntry("calendars", calendarsList.join(";"));
        d->config.sync();

        emit calendarsChanged();
    }
}

QString CalindoriConfig::calendarFile(const QString& calendarName)
{
    if(d->config.hasGroup(calendarName) && d->config.group(calendarName).hasKey("file"))
    {
        return  d->config.group(calendarName).readEntry("file");
    }
    d->config.group(calendarName).writeEntry("file", filenameToPath(calendarName));
    d->config.sync();

    return filenameToPath(calendarName);
}

QString CalindoriConfig::filenameToPath(const QString& calendarName)
{
    return QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/calindori_" + calendarName + ".ics";
}
