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
    m_cal_url(QUrl()),
    m_calendar(nullptr),
    m_cal_storage(nullptr),
    m_filterdt(QDate())

{}

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

int TodosModel::rowCount(const QModelIndex& parent) const
{
    if(parent.isValid())
        return 0;
    return m_todos.count();
}


void TodosModel::addTodos(const Todo::List& todos)
{
    qDebug() << "Add Todos (not implemented yet)";

//     if(!todos.isEmpty()) {
//         beginInsertRows(QModelIndex(), rowCount(), rowCount()+todos.size()-1);
//         m_todos += todos;
// 
//         //TODO: add todos to calendar
//         //TODO: save storage
//         endInsertRows();
//         emit rowsChanged();
//     }
}

void TodosModel::deleteTodo(int row)
{

    qDebug() << "Delete Todo (not implemented yet)";
//     Todo::Ptr = m_todos[row].data();
}


QUrl TodosModel::calendar() const
{
    return m_cal_url;
}

QDate TodosModel::filterdt() const
{
    return m_filterdt;
}

void TodosModel::setFilterdt(QDate filterDate)
{
    qDebug() << filterDate.toString();
    m_filterdt = filterDate;
    if(m_calendar != nullptr) {
        loadTasks(m_filterdt);
    }
    
}


void TodosModel::loadTasks(QDate taskDt)
{
    beginResetModel();
    m_todos.clear();
    qDebug() << "Show tasks of " + taskDt.toString();
    m_todos =  m_calendar->rawTodos(taskDt,taskDt);
    endResetModel();
    emit rowsChanged();
    emit calendarChanged();
}

void TodosModel::setCalendar(QUrl calendarUrl)
{
    if(m_cal_url != calendarUrl) {
        MemoryCalendar::Ptr calendar(new MemoryCalendar(QTimeZone::systemTimeZone()));
        FileStorage::Ptr storage(new FileStorage(calendar));
        storage->setFileName(calendarUrl.path());

        if(storage->load()) {
            m_cal_url = calendarUrl; //TODO: create a calendar-url-storage type ?
            m_calendar = calendar;
            m_cal_storage = storage;
            loadTasks(m_filterdt);
//             beginResetModel();
//             m_todos.clear();
//             m_todos =  m_calendar->rawTodos();
//             endResetModel();
//             emit rowsChanged();
//             emit calendarChanged();
        }
        else {
            qDebug() << "Cannot open calendar file " << calendarUrl.toDisplayString() ;
        }
    }
}


