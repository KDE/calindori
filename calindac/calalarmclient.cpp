/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "calalarmclient.h"
#include "alarmnotification.h"
#include "alarmsmodel.h"
#include "notificationhandler.h"
#include "calindacadaptor.h"
#include <KSharedConfig>
#include <KConfigGroup>
#include <QDebug>
#include <QVariantMap>
#include <KLocalizedString>

using namespace KCalendarCore;

CalAlarmClient::CalAlarmClient(QObject* parent)
    : QObject(parent), mAlarmsModel(new AlarmsModel()), mNotificationHandler(new NotificationHandler())
{
    new CalindacAdaptor(this);
    QDBusConnection dbus = QDBusConnection::sessionBus();
    dbus.registerObject("/calindac", this);

    KConfigGroup generalGroup(KSharedConfig::openConfig(), "General");
    mCheckInterval = generalGroup.readEntry("CheckInterval", 45);
    mSuspendSeconds = generalGroup.readEntry("SuspendSeconds", 60);
    mLastChecked = generalGroup.readEntry("CalendarsLastChecked", QDateTime());

    qDebug() << "\nCalAlarmClient:\tcheck interval:" << mCheckInterval << "seconds.";
    qDebug() << "CalAlarmClient:\tLastChecked:" << mLastChecked;

    restoreSuspendedFromConfig();
    saveCheckInterval();
    saveSuspendSeconds();
    connect(&mCheckTimer, &QTimer::timeout, this, &CalAlarmClient::checkAlarms);
    checkAlarms();
    mCheckTimer.start(1000 * mCheckInterval);
}

CalAlarmClient::~CalAlarmClient() = default;

QStringList CalAlarmClient::calendarFileList() const
{
    QStringList filesList = QStringList();
    KConfigGroup calindoriCfgGeneral(KSharedConfig::openConfig("calindorirc"), "general");
    QString calendars = calindoriCfgGeneral.readEntry("calendars", QString());
    QStringList calendarList = calendars.split(";");

    for (const auto& c : calendarList) {
        QString fileName = KSharedConfig::openConfig("calindorirc")->group(c).readEntry("file");

        if (!(fileName.isNull())) {
            filesList.append(fileName);
        }
    }

    qDebug() << "\ncalendarFileList:\tCalindori calendars:" << filesList.join(",");

    return filesList;
}

void CalAlarmClient::checkAlarms()
{
    KConfigGroup cfg(KSharedConfig::openConfig(), "General");

    if (!cfg.readEntry("Enabled", true)) return;

    QDateTime from = mLastChecked.addSecs(1);
    mLastChecked = QDateTime::currentDateTime();

    qDebug() << "\ncheckAlarms:\tCheck:" << from.toString() << " -" << mLastChecked.toString();

    QVariantMap checkPeriod;
    checkPeriod["from"] = from;
    checkPeriod["to"] = mLastChecked;

    QHash<QString, QVariant> modelProperties;
    modelProperties["calendarFiles"] = calendarFileList();
    modelProperties["period"] = checkPeriod;
    mAlarmsModel->setParams(modelProperties);
    mNotificationHandler->setPeriod(checkPeriod);

    qDebug() << "checkAlarms:\tModel Alarms:" << mAlarmsModel->rowCount();

    for (int i = 0; i < mAlarmsModel->rowCount(); ++i) {
        QModelIndex index = mAlarmsModel->index(i, 0, QModelIndex());
        mNotificationHandler->addActiveNotification(mAlarmsModel->data(index, AlarmsModel::Roles::Uid).toString(), QString("%1\n%2").arg(mAlarmsModel->data(index, AlarmsModel::Roles::IncidenceStartDt).toDateTime().toString("hh:mm"), mAlarmsModel->data(index, AlarmsModel::Roles::Text).toString()));
    }

    mNotificationHandler->sendNotifications();
    saveLastCheckTime();
    flushSuspendedToConfig();

    qDebug() << "\ncheckAlarms:\tWaiting for" << mCheckInterval << " seconds";
}

void CalAlarmClient::saveLastCheckTime()
{
    KConfigGroup generalGroup(KSharedConfig::openConfig(), "General");
    generalGroup.writeEntry("CalendarsLastChecked", mLastChecked);
    KSharedConfig::openConfig()->sync();
}

void CalAlarmClient::saveCheckInterval()
{
    KConfigGroup generalGroup(KSharedConfig::openConfig(), "General");
    generalGroup.writeEntry("CheckInterval", mCheckInterval);
    KSharedConfig::openConfig()->sync();
}

void CalAlarmClient::saveSuspendSeconds()
{
    KConfigGroup generalGroup(KSharedConfig::openConfig(), "General");
    generalGroup.writeEntry("SuspendSeconds", mSuspendSeconds);
    KSharedConfig::openConfig()->sync();
}

void CalAlarmClient::quit()
{
    flushSuspendedToConfig();
    saveLastCheckTime();
    qDebug("\nquit");
    qApp->quit();
}

void CalAlarmClient::forceAlarmCheck()
{
    checkAlarms();
    saveLastCheckTime();
}

QString CalAlarmClient::dumpLastCheck() const
{
    KConfigGroup cfg(KSharedConfig::openConfig(), "General");
    const QDateTime lastChecked = cfg.readEntry("CalendarsLastChecked", QDateTime());

    return QStringLiteral("Last Check: %1").arg(lastChecked.toString());
}

QStringList CalAlarmClient::dumpAlarms() const
{
    const QDateTime start = QDateTime(QDate::currentDate(), QTime(0, 0), Qt::LocalTime);
    const QDateTime end = start.addDays(1).addSecs(-1);

    QVariantMap checkPeriod;
    checkPeriod["from"] = start;
    checkPeriod["to"] = end;

    AlarmsModel* model = new AlarmsModel();

    QHash<QString, QVariant> modelProperties;
    modelProperties["calendarFiles"] = calendarFileList();
    modelProperties["period"] = checkPeriod;
    model->setParams(modelProperties);

    QStringList lst = QStringList();

    for (int i = 0; i < model->rowCount(); ++i) {
        QModelIndex index = model->index(i, 0, QModelIndex());
        lst << QStringLiteral("%1: \"%2\"").arg(model->data(index, AlarmsModel::Roles::Time).toString(), model->data(index, AlarmsModel::Roles::Uid).toString());
    }

    return lst;
}

void CalAlarmClient::restoreSuspendedFromConfig()
{
    qDebug() << "\nrestoreSuspendedFromConfig:\tRestore suspended alarms from config";
    KConfigGroup suspendedGroup(KSharedConfig::openConfig(), "Suspended");
    QStringList suspendedAlarms = suspendedGroup.groupList();

    for (const auto& s : suspendedAlarms) {
        KConfigGroup suspendedAlarm(&suspendedGroup, s);
        QString uid = suspendedAlarm.readEntry("UID");
        QString txt = alarmText(uid);
        QDateTime remindAt = QDateTime::fromString(suspendedAlarm.readEntry("RemindAt"), "yyyy,M,d,HH,m,s");
        qDebug() << "restoreSuspendedFromConfig:\tRestoring alarm" << uid << "," << txt << "," << remindAt.toString();

        if (!(uid.isEmpty() && remindAt.isValid() && !(txt.isEmpty()))) {
            mNotificationHandler->addSuspendedNotification(uid, txt, remindAt);
        }
    }
}

QString CalAlarmClient::alarmText(const QString& uid) const
{
    QVariantMap checkPeriod;
    checkPeriod["to"] = QDateTime::currentDateTime();

    AlarmsModel* model = new AlarmsModel();
    QHash<QString, QVariant> modelProperties;
    modelProperties["calendarFiles"] = calendarFileList();
    modelProperties["period"] = checkPeriod;
    model->setParams(modelProperties);

    for (int i = 0; i < model->rowCount(); ++i) {
        QModelIndex index = model->index(i, 0, QModelIndex());
        if (model->data(index, AlarmsModel::Roles::Uid).toString() == uid) {
            qDebug() << "alarmText: text of" << model->data(index, AlarmsModel::Roles::Uid).toString() << " is" << model->data(index, AlarmsModel::Roles::Text).toString();
            return model->data(index, AlarmsModel::Roles::Text).toString();
        }
    }

    return QString();
}

void CalAlarmClient::flushSuspendedToConfig()
{
    qDebug("\nflushSuspendedToConfig");
    KConfigGroup suspendedGroup(KSharedConfig::openConfig(), "Suspended");
    suspendedGroup.deleteGroup();

    QHash<QString, AlarmNotification*> suspendedNotifications = mNotificationHandler->suspendedNotifications();

    if (suspendedNotifications.isEmpty()) {
        qDebug() << "flushSuspendedToConfig:\tNo suspended notification exists, nothing to write to config";
        KSharedConfig::openConfig()->sync();

        return;
    }

    for (const auto& s : suspendedNotifications) {
        qDebug() << "flushSuspendedToConfig:\tFlushing suspended alarm" << s->uid() << " to config";
        KConfigGroup notificationGroup(&suspendedGroup, s->uid());
        notificationGroup.writeEntry("UID", s->uid());
        notificationGroup.writeEntry("RemindAt", s->remindAt());
    }
    KSharedConfig::openConfig()->sync();
}
