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

#ifndef TODOCONTROLLER_H
#define TODOCONTROLLER_H
#include <QObject>
#include <QVariantMap>

class TodoController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QObject* calendar READ calendar WRITE setCalendar NOTIFY calendarChanged);
    Q_PROPERTY(QVariantMap vtodo READ vtodo WRITE setVtodo NOTIFY vtodoChanged);

public:
    explicit TodoController(QObject* parent = nullptr);
    ~TodoController() override;

    QObject* calendar() const;
    void setCalendar(QObject* const calendarPtr );

    QVariantMap vtodo() const;
    void setVtodo(const QVariantMap& todo);

    Q_INVOKABLE void remove();
    Q_INVOKABLE void addEdit();

Q_SIGNALS:
    void calendarChanged();
    void vtodoChanged();
    void vtodosUpdated();

private:
    QObject* m_calendar;
    QVariantMap m_todo;
};
#endif

