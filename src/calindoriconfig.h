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

#ifndef MOBILECALENDARCONFIG_H
#define MOBILECALENDARCONFIG_H

#include <QObject>
#include <QVariantMap>

class CalindoriConfig : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString calendars READ calendars NOTIFY calendarsChanged)
    Q_PROPERTY(QString activeCalendar READ activeCalendar WRITE setActiveCalendar NOTIFY activeCalendarChanged)
public:

    explicit CalindoriConfig(QObject* parent = nullptr);
    ~CalindoriConfig() override;

    QString calendars() const;
    QString calendarFile(const QString & calendarName);
    Q_SIGNAL void calendarsChanged();

    QString activeCalendar() const;
    void setActiveCalendar(const QString& calendar);
    Q_SIGNAL void activeCalendarChanged();

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
