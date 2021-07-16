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
        alarmMap["startOffsetType"] = KCalendarCore::Duration::Days;
    } else {
        alarmMap["startOffsetValue"] = -1 * secondsFromStart;
        alarmMap["startOffsetType"] = KCalendarCore::Duration::Seconds;
    }
    alarmMap["actionType"] = KCalendarCore::Alarm::Type::Display;
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
    KCalendarCore::Calendar::Ptr memCalendar;
    KCalendarCore::Incidence::Ptr alarmIncidence;
    KCalendarCore::Alarm::List persistentAlarms = KCalendarCore::Alarm::List();

    qDebug() << "\nloadPersistentAlarms: uid" << uid;

    if (localCalendar != nullptr) {
        memCalendar = localCalendar->calendar();
        alarmIncidence = memCalendar->incidence(uid);
    }

    if (alarmIncidence != nullptr) {
        persistentAlarms = alarmIncidence->alarms();
    }

    KCalendarCore::Alarm::List::const_iterator alarmItr = persistentAlarms.constBegin();

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
    case KCalendarCore::Duration::Type::Days: {
        return QString(i18n("days before start"));
    }
    case KCalendarCore::Duration::Type::Seconds: {
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

    // Duration in days
    if (durationType == KCalendarCore::Duration::Type::Days) {
        return i18np("1 day before start", "%1 days before start", durationValue);
    }

    // Duration in seconds
    if ((durationValue % 86400) == 0) {
        return i18np("1 day before start", "%1 days before start", durationValue / 86400);
    }

    if ((durationValue % 3600) == 0) {
        return i18np("1 hour before start", "%1 hours before start", durationValue / 3600);
    }

    if ((durationValue % 60) == 0) {
        return i18np("1 minute before start", "%1 minutes before start", durationValue / 60);
    }

    return i18np("1 second before start", "%1 seconds before start", durationValue);
}

