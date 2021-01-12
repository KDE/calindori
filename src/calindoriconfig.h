/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef MOBILECALENDARCONFIG_H
#define MOBILECALENDARCONFIG_H

#include <QObject>
#include <QVariantMap>

class CalindoriConfig : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList internalCalendars READ internalCalendars NOTIFY internalCalendarsChanged)
    Q_PROPERTY(QStringList externalCalendars READ externalCalendars NOTIFY externalCalendarsChanged)
    Q_PROPERTY(QString activeCalendar READ activeCalendar WRITE setActiveCalendar NOTIFY activeCalendarChanged)
    Q_PROPERTY(int eventsDuration READ eventsDuration WRITE setEventsDuration NOTIFY eventsDurationChanged)
    Q_PROPERTY(int preEventRemindTime READ preEventRemindTime WRITE setPreEventRemindTime NOTIFY preEventRemindTimeChanged)
    Q_PROPERTY(bool alwaysRemind READ alwaysRemind WRITE setAlwaysRemind NOTIFY alwaysRemindChanged)

public:

    explicit CalindoriConfig(QObject *parent = nullptr);
    ~CalindoriConfig() override;

    QStringList internalCalendars() const;
    Q_SIGNAL void internalCalendarsChanged();

    QStringList externalCalendars() const;
    Q_SIGNAL void externalCalendarsChanged();

    QString activeCalendar() const;
    void setActiveCalendar(const QString &calendar);
    Q_SIGNAL void activeCalendarChanged();

    int eventsDuration() const;
    void setEventsDuration(int duration);
    Q_SIGNAL void eventsDurationChanged();

    int preEventRemindTime() const;
    void setPreEventRemindTime(int remindBefore);
    Q_SIGNAL void preEventRemindTimeChanged();

    bool alwaysRemind() const;
    void setAlwaysRemind(bool remind);
    Q_SIGNAL void alwaysRemindChanged();

    QString calendarFile(const QString &calendarName);
    void setOwnerName(const QString &calendar, const QString &ownerName);
    void setOwnerEmail(const QString &calendar, const QString &ownerEmail);

    Q_INVOKABLE bool isExternal(const QString &calendarName);
    Q_INVOKABLE void setOwnerInfo(const QString &calendar, const QString &ownerName, const QString &ownerEmail);
    Q_INVOKABLE QString ownerName(const QString &calendarName);
    Q_INVOKABLE QString ownerEmail(const QString &calendarName);

public Q_SLOTS:
    QVariantMap canAddCalendar(const QString &calendar);
    QVariantMap addInternalCalendar(const QString &calendar, const QString &ownerName = QString(), const QString &ownerEmail = QString());
    QVariantMap addExternalCalendar(const QString &calendar, const QString &ownerName, const QString &ownerEmail, const QUrl &calendarPathUrl);
    void removeCalendar(const QString &calendar);

private:
    static QString filenameToPath(const QString &calendarName);

    class Private;
    Private *d;
};

#endif
