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

public Q_SLOTS:
    QVariantMap canAddCalendar(const QString& calendar);
    QVariantMap addCalendar(const QString& calendar);
    void removeCalendar(const QString& calendar);

private:
    static QString filenameToPath(const QString & calendarName) ;

    class Private;
    Private* d;
};

#endif
