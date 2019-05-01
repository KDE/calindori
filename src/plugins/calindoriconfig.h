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

#ifndef MOBILECALENDARCONFIG_H
#define MOBILECALENDARCONFIG_H

#include <QObject>

class CalindoriConfig : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString calendars READ calendars NOTIFY calendarsChanged)
    Q_PROPERTY(QString activeLocalCalendar READ activeLocalCalendar WRITE setActiveLocalCalendar NOTIFY activeLocalCalendarChanged)
    Q_PROPERTY(QString activeOnlineCalendar READ activeOnlineCalendar WRITE setActiveOnlineCalendar NOTIFY activeOnlineCalendarChanged)
public:

    explicit CalindoriConfig(QObject* parent = nullptr);
    ~CalindoriConfig() override;

    QString calendars() const;
    Q_SIGNAL void calendarsChanged();

    QString activeLocalCalendar() const;
    void setActiveLocalCalendar(const QString& calendar);
    Q_SIGNAL void activeLocalCalendarChanged();

    QString activeOnlineCalendar() const;
    void setActiveOnlineCalendar(const QString& calendar);
    Q_SIGNAL void activeOnlineCalendarChanged();


public Q_SLOTS:
    QString addCalendar(const QString& calendar);
    void removeCalendar(const QString& calendar);

private:
    class Private;
    Private* d;
};

#endif
