/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "incidencealarmsmodel.h"
#include "localcalendar.h"
#include <QVector>
#include <KLocalizedString>
#include <QDebug>

IncidenceAlarmsModel::IncidenceAlarmsModel(QObject *parent) : QAbstractListModel(parent), mAlarms(QVariantList())
{
    connect(this, &IncidenceAlarmsModel::alarmPropertiesChanged, this, &IncidenceAlarmsModel::loadPersistentAlarms);
}

IncidenceAlarmsModel::~IncidenceAlarmsModel() = default;

QHash<int, QByteArray> IncidenceAlarmsModel::roleNames() const
{
    QHash<int, QByteArray> roles = QAbstractItemModel::roleNames();
    roles.insert(StartOffsetType, "startOffsetType");
    roles.insert(StartOffsetValue, "startOffsetValue");
    roles.insert(ActionType, "actionType");
    return roles;
}

void IncidenceAlarmsModel::removeAlarm(const int row)
{
    beginRemoveRows(QModelIndex(), row, row);

    mAlarms.removeAt(row);

    endRemoveRows();
}

void IncidenceAlarmsModel::removeAll()
{
    beginResetModel();
    mAlarms.clear();
    endResetModel();
}

void IncidenceAlarmsModel::addAlarm(const int secondsFromStart)
{
    qDebug() << "\nAddAlarm:\tAdding alarm. Seconds before start: " << secondsFromStart;

    beginInsertRows(QModelIndex(), mAlarms.count(), mAlarms.count());

    QHash<QString, QVariant> alarmMap;
    if (secondsFromStart % 86400 == 0) {
        alarmMap["startOffsetValue"] = -1 * secondsFromStart / 86400;
        alarmMap["startOffsetType"] = Duration::Days;
    } else {
        alarmMap["startOffsetValue"] = -1 * secondsFromStart;
        alarmMap["startOffsetType"] = Duration::Seconds;
    }
    alarmMap["actionType"] = Alarm::Type::Display;
    mAlarms.append(alarmMap);

    endInsertRows();
}

QVariantMap IncidenceAlarmsModel::alarmProperties() const
{
    return mAlarmProperties;
}

void IncidenceAlarmsModel::setAlarmProperties(const QVariantMap &alarmProps)
{
    mAlarmProperties = alarmProps;

    emit alarmPropertiesChanged();
}

QVariant IncidenceAlarmsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
    case Qt::DisplayRole:
        return displayText(index.row());
    case StartOffsetType:
        return alarmStartOffsetType(index.row());
    case StartOffsetValue:
        return alarmStartOffsetValue(index.row());
    case ActionType:
        return alarmActionType(index.row());
    }

    return QVariant();
}

int IncidenceAlarmsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return mAlarms.count();
}

void IncidenceAlarmsModel::loadPersistentAlarms()
{

    beginResetModel();

    LocalCalendar *localCalendar = mAlarmProperties["calendar"].value<LocalCalendar *>();
    QString uid = mAlarmProperties["uid"].toString();
    MemoryCalendar::Ptr memCalendar;
    Incidence::Ptr alarmIncidence;
    Alarm::List persistentAlarms = Alarm::List();

    qDebug() << "\nloadPersistentAlarms: uid" << uid;

    if (localCalendar != nullptr) {
        memCalendar = localCalendar->memorycalendar();
        alarmIncidence = memCalendar->incidence(uid);
    }

    if (alarmIncidence != nullptr) {
        persistentAlarms = alarmIncidence->alarms();
    }

    Alarm::List::const_iterator alarmItr = persistentAlarms.constBegin();

    while (alarmItr != persistentAlarms.constEnd()) {
        QHash<QString, QVariant> alarmMap;
        alarmMap["startOffsetValue"] = (*alarmItr)->startOffset().value();
        alarmMap["startOffsetType"] = (*alarmItr)->startOffset().type();
        alarmMap["actionType"] = (*alarmItr)->type();

        mAlarms.append(alarmMap);
        ++alarmItr;
    }
    endResetModel();
}

QString IncidenceAlarmsModel::alarmText(const int idx) const
{
    QHash<QString, QVariant> alarm = mAlarms.at(idx).value<QHash<QString, QVariant>>();

    return alarm["text"].toString();
}

QString IncidenceAlarmsModel::alarmStartOffsetType(const int idx) const
{
    QHash<QString, QVariant> alarm = mAlarms.at(idx).value<QHash<QString, QVariant>>();

    int durationType = alarm["startOffsetType"].value<int>();

    switch (durationType) {
    case Duration::Type::Days: {
        return QString(i18n("days before start"));
    }
    case Duration::Type::Seconds: {
        return QString(i18n("seconds before start"));
    }
    default: {
        return QString();
    }
    }
}

int IncidenceAlarmsModel::alarmStartOffsetValue(const int idx) const
{
    QHash<QString, QVariant> alarm = mAlarms.at(idx).value<QHash<QString, QVariant>>();

    return alarm["startOffsetValue"].value<int>();
}

QString IncidenceAlarmsModel::alarmUid(const int idx) const
{
    QHash<QString, QVariant> alarm = mAlarms.at(idx).value<QHash<QString, QVariant>>();

    return alarm["uid"].toString();
}

int IncidenceAlarmsModel::alarmActionType(const int idx) const
{
    QHash<QString, QVariant> alarm = mAlarms.at(idx).value<QHash<QString, QVariant>>();

    return alarm["actionType"].value<int>();
}

QVariantList IncidenceAlarmsModel::alarms() const
{
    return mAlarms;
}

QString IncidenceAlarmsModel::displayText(const int idx) const
{
    QHash<QString, QVariant> alarm = mAlarms.at(idx).value<QHash<QString, QVariant>>();

    int durationType = alarm["startOffsetType"].value<int>();
    int durationValue = -1 * alarm["startOffsetValue"].value<int>();

    if (durationValue == 0) {
        return i18n("At start time");
    }
    if (durationType == Duration::Type::Days) {
        return i18np("1 day before start", "%1 days before start", durationValue);
    }

    QString alarmText;
    int durDays = durationValue / 86400;
    alarmText = (durDays != 0) ? i18np("1 day", "%1 days", durDays) : QString();
    int durHours = (durationValue - durDays * 86400) / 3600;
    alarmText = (durHours != 0) ? QString("%1 %2").arg(alarmText, i18np("1 hour", "%1 hours", durHours)) : alarmText;
    int durMins = (durationValue - durHours * 3600 - durDays * 86400) / 60 ;
    alarmText = (durMins != 0) ? QString("%1 %2").arg(alarmText, i18np("1 minute", "%1 minutes", durMins)) : alarmText;
    int durSeconds = durationValue - durMins * 60 - durHours * 3600 - durDays * 86400;
    alarmText = (durSeconds != 0) ? QString("%1 %2").arg(alarmText, i18np("1 second", "%1 seconds", durSeconds)) : alarmText;

    return QString("%1 %2").arg(alarmText, i18n("before start"));
}

