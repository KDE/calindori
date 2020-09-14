/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
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
    return {
        {Uid, "uid"},
        {Text, "text"},
        {Time, "time"},
        {IncidenceStartDt, "incidenceStartDt"}
    };
}

QVariant AlarmsModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
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
    if (parent.isValid()) {
        return 0;
    }

    return mAlarms.count();
}

void AlarmsModel::loadAlarms()
{
    beginResetModel();
    mAlarms.clear();
    openLoadStorages();

    int cnt = 0;

    for (const auto& m : mMemoryCalendars) {
        QDateTime from = mPeriod["from"].toDateTime();
        QDateTime to = mPeriod["to"].toDateTime();
        qDebug() << "loadAlarms:\tLooking for alarms in calendar #" << cnt << ", from" << from.toString("dd.MM.yyyy hh:mm:ss") << "to" << to.toString("dd.MM.yyyy hh:mm:ss");

        Alarm::List calendarAlarms;

        if (from.isValid() && to.isValid()) {
            calendarAlarms = m->alarms(from, to, true);
        } else if (!(from.isValid()) && to.isValid()) {
            calendarAlarms = m->alarmsTo(to);
        }

        qDebug() << "loadAlarms:\t" << calendarAlarms.count() << "alarms found in calendar #" << cnt;
        if (!(calendarAlarms.empty())) {
            mAlarms.append(calendarAlarms);
        }

        ++cnt;
    }

    closeStorages();
    endResetModel();
}

void AlarmsModel::setCalendars()
{
    mFileStorages.clear();
    mMemoryCalendars.clear();

    for (const auto& cf : mCalendarFiles) {
        MemoryCalendar::Ptr calendar(new MemoryCalendar(QTimeZone::systemTimeZoneId()));
        FileStorage::Ptr storage(new FileStorage(calendar));
        storage->setFileName(cf);
        if (!(storage->fileName().isNull())) {
            qDebug() << "setCalendars:\t" << "Appending calendar" << cf;
            mFileStorages.append(storage);
            mMemoryCalendars.append(calendar);
        }
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
    for (const auto& fs : mFileStorages) {
        auto opened = fs->open();
        qDebug() << "openLoadStorages:\t" << fs->fileName() << "opened: " << opened;
        auto loaded = fs->load();
        qDebug() << "openLoadStorages:\t" << fs->fileName() << "loaded: " << loaded;
    }
}

void AlarmsModel::closeStorages()
{
    for (const auto& fs : mFileStorages) {
        auto closed = fs->close();
        qDebug() << "closeStorages:\t" << fs->fileName() << "closed: " << closed;
    }
}

QDateTime AlarmsModel::parentStartDt(const int idx) const
{
    Alarm::Ptr alarm = mAlarms.at(idx);
    Duration offsetDuration;
    QDateTime alarmTime = mAlarms.at(idx)->time();
    if (alarm->hasStartOffset()) {
        offsetDuration = alarm->startOffset();
    }

    if (!(offsetDuration.isNull())) {
        int secondsFromStart = offsetDuration.asSeconds();

        return alarmTime.addSecs(-1 * secondsFromStart);
    }

    return alarmTime;
}
