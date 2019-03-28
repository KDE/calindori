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

#ifndef TODOSMODEL_H
#define TODOSMODEL_H

#include <QModelIndex>
#include <QSharedPointer>
#include <KCalCore/MemoryCalendar>
#include <KCalCore/FileStorage>
#include "localcalendar.h"

using namespace KCalCore;

class TodosModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(bool filtered READ filtered WRITE setFiltered NOTIFY filteredChanged)
    Q_PROPERTY(QDate filterdt READ filterdt WRITE setFilterdt NOTIFY filterdtChanged)
    Q_PROPERTY(QSharedPointer<MemoryCalendar> memorycalendar READ memorycalendar WRITE setMemorycalendar NOTIFY memorycalendarChanged )
    Q_PROPERTY(int count READ rowCount NOTIFY rowsChanged)
public:
    enum Roles {
        Uid=Qt::UserRole+1,
        LastModified,
        DtStart,
        AllDay,
        Description,
        Summary,
        Location,
        Categories,
        Priority,
        Created,
        Secrecy
    };

    explicit TodosModel(QObject* parent = nullptr);
     ~TodosModel() override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;

    MemoryCalendar::Ptr memorycalendar() const;
    void setMemorycalendar(MemoryCalendar::Ptr calendarPtr);

    QDate filterdt() const;
    void setFilterdt(QDate filterDate);

    bool filtered() const;
    void setFiltered(bool hasFilter);

    QHash<int, QByteArray> roleNames() const override;

public Q_SLOTS:
    void loadTasks();

Q_SIGNALS:
    void rowsChanged();
    void memorycalendarChanged();
    void filterdtChanged();
    void filteredChanged();

private:

    Todo::List m_todos;
    MemoryCalendar::Ptr m_calendar;
    QDate m_filterdt;
    bool m_filtered;
};

#endif // TODOSMODEL_H

