/*
 *  Copyright (c) 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  As a special exception, permission is given to link this program
 *  with any edition of Qt, and distribute the resulting executable,
 *  without including the source code for Qt in the source distribution.
 */

#include "alarmsmodel.h"
#include <KSharedConfig>
#include <KConfigGroup>
#include <QFile>
#include <QDebug>

AlarmsModel::AlarmsModel(QObject* parent) : QAbstractListModel(parent), mMemoryCalendars(QVector<MemoryCalendar::Ptr>()), mFileStorages(QVector<FileStorage::Ptr>()), mAlarms(Alarm::List()), mCalendarFiles(QStringList()), mParams(QHash<QString, QVariant>())
{
    connect(this, &AlarmsModel::paramsChanged, this, &AlarmsModel::loadAlarms);
}

AlarmsModel::~AlarmsModel() = default;

QHash<int, QByteArray> AlarmsModel::roleNames() const
{
    QHash<int, QByteArray> roles = QAbstractListModel::roleNames();
    roles.insert(Uid, "uid");
    roles.insert(Text, "text");
    roles.insert(Time, "time");
    roles.insert(IncidenceStartDt, "incidenceStartDt");

    return roles;
}

QVariant AlarmsModel::data(const QModelIndex& index, int role) const
{
    if(!index.isValid())
    {
        return QVariant();
    }

    switch(role)
    {
        case Qt::DisplayRole:
            return mAlarms.at(index.row())->parentUid();
        case Uid:
            return mAlarms.at(index.row())->parentUid();
        case Time:
            return mAlarms.at(index.row())->time();
        case Text:
            return mAlarms.at(index.row())->text();
        case IncidenceStartDt:
            return parentStartDt(index.row());
    }

    return QVariant();
}

int AlarmsModel::rowCount(const QModelIndex& parent) const
{
    if(parent.isValid())
    {
        return 0;
    }

    return mAlarms.count();
}

void AlarmsModel::loadAlarms()
{
    qDebug() << "\nloadAlarms";

    beginResetModel();
    mAlarms.clear();
    openLoadStorages();

    int cnt = 0;
    QVector<MemoryCalendar::Ptr>::const_iterator itr = mMemoryCalendars.constBegin();
    while(itr != mMemoryCalendars.constEnd())
    {
        QDateTime from = mPeriod["from"].toDateTime();
        QDateTime to = mPeriod["to"].toDateTime();
        qDebug() << "loadAlarms:\tLooking for alarms in calendar #" << cnt << ", from" << from.toString("dd.MM.yyyy hh:mm:ss") << "to" << to.toString("dd.MM.yyyy hh:mm:ss");

        Alarm::List calendarAlarms;

        if(from.isValid() && to.isValid())
        {
            calendarAlarms = (*itr)->alarms(from, to, true);
        }
        else if(!(from.isValid()) && to.isValid())
        {
            calendarAlarms = (*itr)->alarmsTo(to);
        }

        qDebug() << "loadAlarms:\t" << calendarAlarms.count() << "alarms found in calendar #" << cnt;
        if(!(calendarAlarms.empty()))
        {
            mAlarms.append(calendarAlarms);
        }

        ++cnt;
        ++itr;
    }

    closeStorages();
    endResetModel();
}

void AlarmsModel::setCalendars()
{
    mFileStorages.clear();
    mMemoryCalendars.clear();

    qDebug() << "\nsetCalendars";
    QStringList::const_iterator itr = mCalendarFiles.constBegin();
    while(itr != mCalendarFiles.constEnd())
    {
        MemoryCalendar::Ptr calendar(new MemoryCalendar(QTimeZone::systemTimeZoneId()));
        FileStorage::Ptr storage(new FileStorage(calendar));
        storage->setFileName(*itr);
        if(!(storage->fileName().isNull()))
        {
            qDebug() << "setCalendars:\t"<< "Appending calendar" << *itr;
            mFileStorages.append(storage);
            mMemoryCalendars.append(calendar);
        }
        ++itr;
    }
}


QHash<QString, QVariant> AlarmsModel::params() const
{
    return mParams;
}

void AlarmsModel::setParams(const QHash<QString, QVariant>& parameters)
{
    mParams = parameters;

    QStringList calendarFiles = mParams["calendarFiles"].toStringList();
    QVariantMap period = (mParams["period"].value<QVariant>()).value<QVariantMap>();

    mCalendarFiles = calendarFiles;
    setCalendars();
    mPeriod = period;

    emit paramsChanged();
}

void AlarmsModel::openLoadStorages()
{
    QVector<FileStorage::Ptr>::const_iterator itr = mFileStorages.constBegin();
    while(itr != mFileStorages.constEnd())
    {
        if((*itr)->open())
        {
            qDebug() << "loadAlarms:\t" << (*itr)->fileName() << "opened";
        }

        if((*itr)->load())
        {
            qDebug() << "loadAlarms:\t" << (*itr)->fileName() << "loaded";
        }
        ++itr;
    }
}

void AlarmsModel::closeStorages()
{
    QVector<FileStorage::Ptr>::const_iterator itr = mFileStorages.constBegin();
    while(itr != mFileStorages.constEnd())
    {
        if((*itr)->close())
        {
            qDebug() << "loadAlarms:\t" << (*itr)->fileName() << "closed";
        }
        ++itr;
    }
}


QDateTime AlarmsModel::parentStartDt(const int idx) const
{
    Alarm::Ptr alarm = mAlarms.at(idx);
    Duration offsetDuration;
    QDateTime alarmTime = mAlarms.at(idx)->time();
    if(alarm->hasStartOffset())
    {
         offsetDuration = alarm->startOffset();
    }

    if(!(offsetDuration.isNull()))
    {
        int secondsFromStart = offsetDuration.asSeconds();

        return alarmTime.addSecs(-1*secondsFromStart);
    }

    return alarmTime;
}

