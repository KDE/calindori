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

#ifndef EVENTCONTROLLER_H
#define EVENTCONTROLLER_H

#include <QObject>
#include <KCalCore/Event>
#include <KCalCore/MemoryCalendar>
#include <KCalCore/FileStorage>

class EventController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariantMap vevent READ vevent WRITE setVevent NOTIFY veventChanged)
    Q_PROPERTY(QObject* calendar READ calendar WRITE setCalendar NOTIFY calendarChanged)

public:
    explicit EventController(QObject* parent = nullptr);
    ~EventController() override;
    
    QVariantMap vevent() const;
    void setVevent(const QVariantMap& event);

    QObject* calendar() const;
    void setCalendar(QObject* const calendarPtr);

    Q_INVOKABLE void remove();
    Q_INVOKABLE void addEdit();

Q_SIGNALS:
    void veventChanged();
    void calendarChanged();

private:
    QVariantMap m_event;
    QObject* m_calendar;
};
#endif
