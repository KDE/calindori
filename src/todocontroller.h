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

class LocalCalendar;

class TodoController : public QObject
{
    Q_OBJECT

public:
    explicit TodoController(QObject* parent = nullptr);
    ~TodoController() override;

    Q_INVOKABLE void remove(LocalCalendar *calendar, const QVariantMap& todo);
    Q_INVOKABLE void addEdit(LocalCalendar *calendar, const QVariantMap& todo);

};
#endif

