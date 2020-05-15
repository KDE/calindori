/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "calindoriconfig.h"
#include <KLocalizedString>
#include <KConfig>
#include <KConfigGroup>
#include <QDebug>
#include <QRegExp>
#include <QDir>

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
    Q_EMIT activeCalendarChanged();
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

    Q_EMIT calendarsChanged();

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

        Q_EMIT calendarsChanged();
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
    QString basePath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir baseFolder(basePath);
    baseFolder.mkpath(QStringLiteral("."));

    return basePath + "/calindori_" + calendarName + ".ics";
}

int CalindoriConfig::eventsDuration() const
{
   return d->config.group("events").readEntry("duration", 60);
}

void CalindoriConfig::setEventsDuration(int duration)
{
    d->config.group("events").writeEntry("duration", duration);
    d->config.sync();

    Q_EMIT eventsDurationChanged();
}
