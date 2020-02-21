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
#include <KCalendarCore/MemoryCalendar>
#include <KCalendarCore/FileStorage>
#include "localcalendar.h"

using namespace KCalendarCore;

class TodosModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QDate filterdt READ filterdt WRITE setFilterdt NOTIFY filterdtChanged)
    Q_PROPERTY(LocalCalendar* calendar READ calendar WRITE setCalendar NOTIFY calendarChanged)
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
        Secrecy,
        Completed
    };

    explicit TodosModel(QObject* parent = nullptr);
     ~TodosModel() override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;

    LocalCalendar *calendar() const;
    void setCalendar(LocalCalendar *calendarPtr);

    QDate filterdt() const;
    void setFilterdt(const QDate& filterDate);

    QHash<int, QByteArray> roleNames() const override;

public Q_SLOTS:
    void loadTasks();

Q_SIGNALS:
    void rowCountChanged();
    void calendarChanged();
    void filterdtChanged();

private:

    Todo::List m_todos;
    LocalCalendar *m_calendar;
    QDate m_filterdt;
    bool m_filtered;
};

#endif // TODOSMODEL_H

