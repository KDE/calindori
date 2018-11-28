
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
        MemoryCalendar::Ptr calendar(new MemoryCalendar(QTimeZone::systemTimeZone()));
        FileStorage::Ptr storage(new FileStorage(calendar));
        QString fullPathName = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/" + calendarName; //TODO: Consider changing to GenericDataLocation if calendar should be shared with other apps
        
        QFile calendarFile(fullPathName);
        storage->setFileName(fullPathName);
        
        if (!calendarFile.exists()) {
            qDebug() << "Creating file" << storage->save();
        }
        
        if(storage->load()) {
            m_name = calendarName; 
            m_calendar = calendar;
            m_cal_storage = storage;
        }
    }
}


void LocalCalendar::setMemorycalendar(MemoryCalendar::Ptr memoryCalendar)
{
    if(m_calendar != memoryCalendar) {
        m_calendar = memoryCalendar;
        qDebug() << "Calendar succesfully set";
        
    }
    else {
        qDebug() << "Cannot set calendar ";
    }
}

void LocalCalendar::setCalendarstorage(FileStorage::Ptr calendarStorage)
{
    if(m_cal_storage != calendarStorage) {
        m_cal_storage = calendarStorage;
        qDebug() << "Storage succesfully set";
        
    }
    else {
        qDebug() << "Cannot set storage ";
    }
}

void LocalCalendar::addTask(QString summary, QString description, QDate startDate)
{
    qDebug() << "Creating todo" << "summary:" << summary << ", description:" << description << ", startDate:" << startDate.toString();
    QDateTime now = QDateTime::currentDateTime();
    
    Todo::Ptr todo(new Todo());
    todo->setUid(summary.left(1) + now.toString("yyyyMMddhhmmsszzz"));
    todo->setDtStart(QDateTime(startDate));
    todo->setDescription(description);
    todo->setSummary(summary);
    m_calendar->addTodo(todo);
    bool success = m_cal_storage->save();
    qDebug() << "Storage save: " << success;
    emit todoAdded();
    
    qDebug() << "New todo has been saved"; 
}



