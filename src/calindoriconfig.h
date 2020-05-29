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
    Q_PROPERTY(QString calendars READ calendars NOTIFY calendarsChanged)
    Q_PROPERTY(QString activeCalendar READ activeCalendar WRITE setActiveCalendar NOTIFY activeCalendarChanged)
    Q_PROPERTY(int eventsDuration READ eventsDuration WRITE setEventsDuration NOTIFY eventsDurationChanged)
    Q_PROPERTY(int preEventRemindTime READ preEventRemindTime WRITE setPreEventRemindTime NOTIFY preEventRemindTimeChanged)
    Q_PROPERTY(bool alwaysRemind READ alwaysRemind WRITE setAlwaysRemind NOTIFY alwaysRemindChanged)

public:

    explicit CalindoriConfig(QObject* parent = nullptr);
    ~CalindoriConfig() override;

    QString calendars() const;
    QString calendarFile(const QString & calendarName);
    Q_SIGNAL void calendarsChanged();

    QString activeCalendar() const;
    void setActiveCalendar(const QString& calendar);
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

public Q_SLOTS:
    QVariantMap canAddCalendar(const QString& calendar);
    QVariantMap addCalendar(const QString& calendar);
    void removeCalendar(const QString& calendar);

private:
    static QString filenameToPath(const QString & calendarName);

    class Private;
    Private* d;
};

#endif
