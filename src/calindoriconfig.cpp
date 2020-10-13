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
#include <QUrl>

class CalindoriConfig::Private
{
public:
    Private()
        : config("calindorirc")
    {};
    KConfig config;
};

CalindoriConfig::CalindoriConfig(QObject *parent)
    : QObject(parent)
    , d(new Private)
{
    if ((d->config.group("general").readEntry("calendars", QString())).isEmpty() && (d->config.group("general").readEntry("externalCalendars", QString())).isEmpty()) {
        qDebug() << "No calendar found, creating a default one";
        addInternalCalendar("personal");
        setActiveCalendar("personal");
        d->config.sync();
    }
}

CalindoriConfig::~CalindoriConfig()
{
    delete d;
}

QStringList CalindoriConfig::internalCalendars() const
{
    auto cals = d->config.group("general").readEntry("calendars", QString());

    return cals.isEmpty() ? QStringList() : cals.split(";");
}

QStringList CalindoriConfig::externalCalendars() const
{
    auto cals = d->config.group("general").readEntry("externalCalendars", QString());

    return cals.isEmpty() ? QStringList() : cals.split(";");
}

QString CalindoriConfig::activeCalendar() const
{
    return d->config.group("general").readEntry("activeCalendar", QString());
}

void CalindoriConfig::setActiveCalendar(const QString &calendar)
{
    d->config.group("general").writeEntry("activeCalendar", calendar);
    d->config.sync();
    Q_EMIT activeCalendarChanged();
}

QVariantMap CalindoriConfig::canAddCalendar(const QString &calendar)
{
    QRegExp invalidChars("[\\;\\\\/<>:\\?\\*|\"\']");
    if (calendar.contains(invalidChars)) {
        return QVariantMap({
            {"success", false},
            {"reason", i18n("Calendar name contains invalid characters")}
        });
    }

    auto internalCalendars = d->config.group("general").readEntry("calendars", QString());
    auto externalCalendars = d->config.group("general").readEntry("externalCalendars", QString());

    if (internalCalendars.isEmpty() && externalCalendars.isEmpty()) {
        return QVariantMap({
            {"success", true},
            {"reason", QString()}
        });
    }

    auto calendarsList = internalCalendars.isEmpty() ? QStringList() : internalCalendars.split(";");
    if (!(externalCalendars.isEmpty())) {
        calendarsList.append(externalCalendars.split(";"));
    }

    if (calendarsList.contains(calendar)) {
        return QVariantMap({
            {"success", false},
            {"reason", i18n("Calendar already exists")}
        });
    }

    return QVariantMap({
        {"success", true},
        {"reason", QString()}
    });
}

QVariantMap CalindoriConfig::addInternalCalendar(const QString &calendar)
{
    QVariantMap canAddResult = canAddCalendar(calendar);

    if (!(canAddResult["success"].toBool())) {
        return QVariantMap({
            {"success", false}, {"reason ", canAddResult["reason"].toString()}
        });
    }

    auto calsStr = d->config.group("general").readEntry("calendars", QString());
    if (calsStr.isEmpty()) {
        d->config.group("general").writeEntry("calendars", calendar);
    } else {
        QStringList calendarsList = calsStr.split(";");
        calendarsList.append(calendar);
        d->config.group("general").writeEntry("calendars", calendarsList.join(";"));
    }
    d->config.sync();
    Q_EMIT internalCalendarsChanged();

    return QVariantMap({
        {"success", true}, {"reason ", QString()}
    });
}

QVariantMap CalindoriConfig::addExternalCalendar(const QString &calendar, const QUrl &calendarPathUrl)
{
    QVariantMap canAddResult = canAddCalendar(calendar);

    if (!(canAddResult["success"].toBool())) {
        return QVariantMap({
            {"success", false}, {"reason ", canAddResult["reason"].toString()}
        });
    }

    auto eCals = d->config.group("general").readEntry("externalCalendars", QString());
    if (eCals.isEmpty()) {
        d->config.group("general").writeEntry("externalCalendars", calendar);
    } else {
        QStringList calendarsList = eCals.split(";");
        calendarsList.append(calendar);
        d->config.group("general").writeEntry("externalCalendars", calendarsList.join(";"));
    }
    d->config.group(calendar).writeEntry("file", calendarPathUrl.toString(QUrl::RemoveScheme));
    d->config.group(calendar).writeEntry("external", true);
    d->config.sync();
    Q_EMIT externalCalendarsChanged();

    return QVariantMap({
        {"success", true}, {"reason ", QString()}
    });
}

void CalindoriConfig::removeCalendar(const QString &calendar)
{
    d->config.reparseConfiguration();

    auto iCalendarsStr = d->config.group("general").readEntry("calendars", QString());
    auto iCalendarsList = iCalendarsStr.isEmpty() ? QStringList() : iCalendarsStr.split(";");
    auto eCalendarsStr = d->config.group("general").readEntry("externalCalendars", QString());
    auto eCalendarsList = eCalendarsStr.isEmpty() ? QStringList() : eCalendarsStr.split(";");

    if (iCalendarsList.contains(calendar)) {
        iCalendarsList.removeAll(calendar);
        d->config.group("general").writeEntry("calendars", iCalendarsList.join(";"));

        Q_EMIT internalCalendarsChanged();
    }

    if (eCalendarsList.contains(calendar)) {
        eCalendarsList.removeAll(calendar);
        d->config.group("general").writeEntry("externalCalendars", eCalendarsList.join(";"));

        Q_EMIT externalCalendarsChanged();
    }

    d->config.deleteGroup(calendar);
    d->config.sync();
}

QString CalindoriConfig::calendarFile(const QString &calendarName)
{
    d->config.reparseConfiguration();

    qDebug() << "calendar: " << calendarName;

    if (d->config.hasGroup(calendarName) && d->config.group(calendarName).hasKey("file")) {
        return d->config.group(calendarName).readEntry("file");
    }
    d->config.group(calendarName).writeEntry("file", filenameToPath(calendarName));
    d->config.sync();

    return filenameToPath(calendarName);
}

QString CalindoriConfig::filenameToPath(const QString &calendarName)
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

int CalindoriConfig::preEventRemindTime() const
{
    return d->config.group("events").readEntry("preEventRemindTime", 15);
}

void CalindoriConfig::setPreEventRemindTime(int remindBefore)
{
    d->config.group("events").writeEntry("preEventRemindTime", remindBefore);
    d->config.sync();

    Q_EMIT preEventRemindTimeChanged();
}

bool CalindoriConfig::alwaysRemind() const
{
    return d->config.group("events").readEntry("alwaysRemind", true);
}

void CalindoriConfig::setAlwaysRemind(bool remind)
{
    d->config.group("events").writeEntry("alwaysRemind", remind);
    d->config.sync();

    Q_EMIT alwaysRemindChanged();
}

bool CalindoriConfig::isExternal(const QString &calendarName)
{
    if (d->config.hasGroup(calendarName) && d->config.group(calendarName).hasKey("external")) {
        return d->config.group(calendarName).readEntry("external", false);
    }

    return false;
}
