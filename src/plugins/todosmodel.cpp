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

#include "todosmodel.h"
#include <QDebug>
TodosModel::TodosModel(QObject* parent)
    : QAbstractListModel(parent),
    m_todos(Todo::List()),
    m_calendar(nullptr),
    m_filterdt(QDate())
{
    connect(this, &TodosModel::memorycalendarChanged, this, &TodosModel::loadTasks);
    connect(this, &TodosModel::filterdtChanged, this, &TodosModel::loadTasks);
    connect(this, &TodosModel::filteredChanged, this, &TodosModel::loadTasks);
}

TodosModel::~TodosModel() = default;

QHash< int, QByteArray > TodosModel::roleNames() const
{
    QHash<int, QByteArray> roles = QAbstractItemModel::roleNames();
    roles.insert(Uid, "uid");
    roles.insert(DtStart, "dtstart");
    roles.insert(Description, "description");
    roles.insert(Summary, "summary");
    roles.insert(LastModified, "lastmodified");
    roles.insert(AllDay, "allday");
    roles.insert(Location, "location");
    roles.insert(Categories, "categories");
    roles.insert(Priority, "priority");
    roles.insert(Created, "created");
    roles.insert(Secrecy, "secrecy");
    return roles;
}

QVariant TodosModel::data(const QModelIndex& index, int role) const
{
    if(!index.isValid())
        return QVariant();
    switch(role) {
        case Qt::DisplayRole:
            return m_todos.at(index.row())->summary();
        case Uid:
            return m_todos.at(index.row())->uid();
        case LastModified:
            return m_todos.at(index.row())->lastModified();
        case DtStart:
            return m_todos.at(index.row())->dtStart();
        case AllDay:
            return m_todos.at(index.row())->allDay();
        case Description:
            return m_todos.at(index.row())->description();
        case Summary:
            return m_todos.at(index.row())->summary();
        case Location:
            return m_todos.at(index.row())->location();
        case Categories:
            return m_todos.at(index.row())->categories();
        case Priority:
            return m_todos.at(index.row())->priority();
        case Created:
            return m_todos.at(index.row())->created();
        case Secrecy:
            return m_todos.at(index.row())->secrecy();
    }
    return QVariant();
}


MemoryCalendar::Ptr TodosModel::memorycalendar() const
{
    return m_calendar;
}

void TodosModel::setMemorycalendar(MemoryCalendar::Ptr calendarPtr)
{
    m_calendar = calendarPtr;

    emit memorycalendarChanged();
}

QDate TodosModel::filterdt() const
{
    return m_filterdt;
}

void TodosModel::setFilterdt(QDate filterDate)
{
    if (filterDate.isValid()) {
        m_filterdt = filterDate;
        emit filterdtChanged();
    }
}

int TodosModel::rowCount(const QModelIndex& parent) const
{
    if(parent.isValid())
        return 0;
    return m_todos.count();
}

void TodosModel::loadTasks()
{
    beginResetModel();
    m_todos.clear();
    if(m_calendar != nullptr && m_filterdt.isValid() && filtered()) {
        m_todos =  m_calendar->rawTodos(m_filterdt,m_filterdt);
    }
    if (m_calendar != nullptr && !(filtered())) {
        m_todos =  m_calendar->rawTodos();
    }
    endResetModel();
}

void TodosModel::setFiltered(bool hasFilter)
{
    m_filtered = hasFilter;
    emit filteredChanged();
}

bool TodosModel::filtered() const
{
    return m_filtered;
}
