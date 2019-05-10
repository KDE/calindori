
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

#include "localcalendar.h"
#include <QDebug>
#include <KCalCore/Todo>
#include <QFile>
#include <QStandardPaths>

using namespace KCalCore;

LocalCalendar::LocalCalendar(QObject* parent)
: QObject(parent)
{}


LocalCalendar::~LocalCalendar() = default;

MemoryCalendar::Ptr LocalCalendar::memorycalendar() const
{
    return m_calendar;
}

FileStorage::Ptr LocalCalendar::calendarstorage() const
{
    return m_cal_storage;
}

QString LocalCalendar::name() const
{
    return m_name;
}

void LocalCalendar::setName(QString calendarName)
{
    if (m_name != calendarName) {
        MemoryCalendar::Ptr calendar(new MemoryCalendar(QTimeZone::systemTimeZoneId()));
        FileStorage::Ptr storage(new FileStorage(calendar));
        m_fullpath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/" + calendarName + "_local.ical" ;

        QFile calendarFile(m_fullpath);
        storage->setFileName(m_fullpath);

        if (!calendarFile.exists()) {
            qDebug() << "Creating file" << storage->save();
        }

        if(storage->load()) {
            m_name = calendarName;
            m_calendar = calendar;
            m_cal_storage = storage;
        }

        emit nameChanged();
        emit memorycalendarChanged();
    }
}


void LocalCalendar::setMemorycalendar(MemoryCalendar::Ptr memoryCalendar)
{
    if(m_calendar != memoryCalendar) {
        m_calendar = memoryCalendar;
        qDebug() << "Calendar succesfully set";

    }
}

void LocalCalendar::setCalendarstorage(FileStorage::Ptr calendarStorage)
{
    if(m_cal_storage != calendarStorage) {
        m_cal_storage = calendarStorage;
        qDebug() << "Storage succesfully set";

    }
}

void LocalCalendar::addEditTask(QString uid, QDate startDate, QString summary, QString description, int startHour, int startMinute, bool allDayFlg, QString location, bool completed)
{
    if ( m_calendar == nullptr)
    {
        qDebug() << "Calendar not initialized, cannot add/edit tasks";
        return;
    }

    qDebug() << "Creating todo" << "summary:" << summary << ", description:" << description << ", startDate:" << startDate.toString() << ", startHour: " << startHour << " , startMinute: " << startMinute << " , allDayFlg: " << allDayFlg;
    QDateTime now = QDateTime::currentDateTime();

    Todo::Ptr todo;
    if (uid == "") {
        todo = Todo::Ptr(new Todo());
        todo->setUid(summary.left(1) + now.toString("yyyyMMddhhmmsszzz"));
    }
    else {
        todo = m_calendar->todo(uid);
        todo->setUid(uid);

    }

    QDateTime startDateTime;

    if(allDayFlg) {
        startDateTime = QDateTime(startDate);
    }
    else {
        startDateTime = QDateTime(startDate, QTime(startHour, startMinute, 0, 0), QTimeZone::systemTimeZone());
    }

    todo->setDtStart(startDateTime);
    todo->setDescription(description);
    todo->setSummary(summary);
    todo->setAllDay(allDayFlg);
    todo->setLocation(location);
    todo->setCompleted(completed);

    m_calendar->addTodo(todo);
    bool success = m_cal_storage->save();
    qDebug() << "Storage save: " << success;
    qDebug() << "Todo has been saved";
}

void LocalCalendar::deleteTask(QString uid) {

    qDebug() << "Deleting task: " << uid;
    Todo::Ptr todo = m_calendar->todo(uid);
    m_calendar->deleteTodo(todo);
    bool success = m_cal_storage->save();
    qDebug() << "Task deleted? " << success;
}

int LocalCalendar::todosCount(const QDate &date) const {
    if(m_calendar == nullptr)
    {
        return 0;
    }
    Todo::List todoList = m_calendar->rawTodos(date,date);
    //DEBUG qDebug() << todoList.size() << " todos found in " << date.toString();
    return todoList.size();
}

void LocalCalendar::deleteCalendar()
{
        qDebug() << "Deleting calendar at " << m_fullpath;
        QFile calendarFile(m_fullpath);

        if (calendarFile.exists()) {
            calendarFile.remove();
        }
}


QDateTime LocalCalendar::nulldate() const
{
    return QDateTime();
}

int LocalCalendar::eventsCount(const QDate& date) const {
    if(m_calendar == nullptr)
    {
        return 0;
    }
    Event::List eventList = m_calendar->rawEvents(date,date);
    return eventList.count();
}

bool LocalCalendar::save()
{
    return m_cal_storage->save();
}
