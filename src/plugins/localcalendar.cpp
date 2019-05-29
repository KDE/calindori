
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
#include <KLocalizedString>

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
    if (m_name != calendarName)
    {
        MemoryCalendar::Ptr calendar(new MemoryCalendar(QTimeZone::systemTimeZoneId()));
        FileStorage::Ptr storage(new FileStorage(calendar));
        m_fullpath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/calindori_" + calendarName + ".ics" ;

        QFile calendarFile(m_fullpath);
        storage->setFileName(m_fullpath);

        if (!calendarFile.exists())
        {
            qDebug() << "Creating file" << storage->save();
        }

        if(storage->load())
        {
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
    if(m_calendar != memoryCalendar)
    {
        m_calendar = memoryCalendar;
        qDebug() << "Calendar succesfully set";
    }
}

void LocalCalendar::setCalendarstorage(FileStorage::Ptr calendarStorage)
{
    if(m_cal_storage != calendarStorage)
    {
        m_cal_storage = calendarStorage;
        qDebug() << "Storage succesfully set";
    }
}

int LocalCalendar::todosCount(const QDate &date) const {
    if(m_calendar == nullptr)
    {
        return 0;
    }
    Todo::List todoList = m_calendar->rawTodos(date,date);

    return todoList.size();
}

void LocalCalendar::deleteCalendar()
{
        qDebug() << "Deleting calendar at " << m_fullpath;
        QFile calendarFile(m_fullpath);

        if (calendarFile.exists())
        {
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

QVariantMap LocalCalendar::canCreateFile(const QString& calendarName)
{
    QVariantMap result;
    result["success"] = QVariant(true);
    result["reason"] = QVariant(QString());

    QString targetPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/calindori_" + calendarName + ".ics" ;
    QFile calendarFile(targetPath);

    if(calendarFile.exists())
    {
        result["success"] = QVariant(false);
        result["reason"] = QVariant(QString(i18n("A calendar with the same name already exists")));

        return result;
    }

    result["targetPath"] = QVariant(QString(targetPath));

    return result;
}

QVariantMap LocalCalendar::importCalendar(const QString& calendarName, const QString& sourcePath)
{
    QVariantMap result;
    result["success"] = QVariant(false);

    MemoryCalendar::Ptr calendar(new MemoryCalendar(QTimeZone::systemTimeZoneId()));
    FileStorage::Ptr storage(new FileStorage(calendar));

    QVariantMap canCreateCheck = canCreateFile(calendarName);
    if(!(canCreateCheck["success"].toBool()))
    {
        result["reason"] = QVariant(canCreateCheck["reason"].toString());

        return result;
    }

    storage->setFileName(sourcePath);

    if(!(storage->load()))
    {
        result["reason"] = QVariant(QString(i18n("The calendar file is not valid")));

        return result;
    }

    storage->setFileName(canCreateCheck["targetPath"].toString());

    if(!(storage->save()))
    {
        result["reason"] = QVariant(QString(i18n("The calendar file cannot be saved")));

        return result;
    }

    result["success"] = QVariant(true);
    result["reason"] = QVariant(QString());

    return result;
}
