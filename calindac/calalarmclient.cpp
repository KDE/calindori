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
#include "solidwakeupbackend.h"
#include "wakeupmanager.h"
#include <KSharedConfig>
#include <KConfigGroup>
#include <QDebug>
#include <QVariantMap>
#include <QDateTime>
#include <KLocalizedString>

using namespace KCalendarCore;

CalAlarmClient::CalAlarmClient(QObject *parent)
    : QObject(parent), m_alarms_model {new AlarmsModel(this)}, m_notification_handler {new NotificationHandler(this)}, m_wakeup_manager {new WakeupManager(this)}
{
    new CalindacAdaptor(this);

    QDBusConnection::sessionBus().registerObject(QStringLiteral("/calindac"), this);

    KConfigGroup generalGroup(KSharedConfig::openConfig(), QStringLiteral("General"));
    m_check_interval = generalGroup.readEntry("CheckInterval", 45);
    m_suspend_seconds = generalGroup.readEntry("SuspendSeconds", 60);
    m_last_check = generalGroup.readEntry("CalendarsLastChecked", QDateTime());

    qDebug() << "CalAlarmClient:lastChecked:" << m_last_check.toString(QStringLiteral("dd.MM.yyyy hh:mm:ss"));

    restoreSuspendedFromConfig();
    saveCheckInterval();
    saveSuspendSeconds();
    checkAlarms();

    connect(m_notification_handler, &NotificationHandler::scheduleAlarmCheck, this, &CalAlarmClient::scheduleAlarmCheck);
    connect(&m_check_timer, &QTimer::timeout, this, &CalAlarmClient::checkAlarms);
    connect(m_wakeup_manager, &WakeupManager::wakeupAlarmClient, this, &CalAlarmClient::wakeupCallback);
    connect(m_wakeup_manager, &WakeupManager::activeChanged, this, &CalAlarmClient::setupShceduler);
    setupShceduler((m_wakeup_manager != nullptr) && (m_wakeup_manager->active()));
}

CalAlarmClient::~CalAlarmClient() = default;

QStringList CalAlarmClient::calendarFileList() const
{
    auto filesList { QStringList() };
    KConfigGroup calindoriCfgGeneral(KSharedConfig::openConfig(QStringLiteral("calindorirc")), QStringLiteral("general"));
    auto iCalendars = calindoriCfgGeneral.readEntry("calendars", QString());
    auto eCalendars = calindoriCfgGeneral.readEntry("externalCalendars", QString());

    auto calendarsList = iCalendars.isEmpty() ? QStringList() : iCalendars.split(QStringLiteral(";"));
    if (!(eCalendars.isEmpty())) {
        calendarsList.append(eCalendars.split(QStringLiteral(";")));
    }

    for (const auto &c : std::as_const(calendarsList)) {
        QString fileName = KSharedConfig::openConfig(QStringLiteral("calindorirc"))->group(c).readEntry("file");

        if (!(fileName.isNull())) {
            filesList.append(fileName);
        }
    }

    return filesList;
}

void CalAlarmClient::checkAlarms()
{
    KConfigGroup cfg(KSharedConfig::openConfig(), QStringLiteral("General"));

    if (!cfg.readEntry("Enabled", true)) {
        return;
    }

    auto checkFrom = m_last_check.addSecs(1);
    m_last_check = QDateTime::currentDateTime();

    qDebug() << "\ncheckAlarms:Check:" << checkFrom.toString() << " -" << m_last_check.toString();

    FilterPeriod fPeriod { .from = checkFrom, .to = m_last_check };
    m_alarms_model->setCalendarFiles(calendarFileList());
    m_alarms_model->setPeriod(fPeriod);
    m_notification_handler->setPeriod(fPeriod);

    auto alarms = m_alarms_model->alarms();
    qDebug() << "checkAlarms:Alarms Found: " << alarms.count();

    for (const auto &alarm : std::as_const(alarms)) {
        m_notification_handler->addActiveNotification(alarm->parentUid(), QStringLiteral("%1\n%2").arg(alarm->time().toString(QStringLiteral("hh:mm")), alarm->text()));
    }
    m_notification_handler->sendNotifications();
    saveLastCheckTime();
    flushSuspendedToConfig();
}

void CalAlarmClient::saveLastCheckTime()
{
    KConfigGroup generalGroup(KSharedConfig::openConfig(), QStringLiteral("General"));
    generalGroup.writeEntry("CalendarsLastChecked", m_last_check);
    KSharedConfig::openConfig()->sync();
}

void CalAlarmClient::saveCheckInterval()
{
    KConfigGroup generalGroup(KSharedConfig::openConfig(), QStringLiteral("General"));
    generalGroup.writeEntry("CheckInterval", m_check_interval);
    KSharedConfig::openConfig()->sync();
}

void CalAlarmClient::saveSuspendSeconds()
{
    KConfigGroup generalGroup(KSharedConfig::openConfig(), QStringLiteral("General"));
    generalGroup.writeEntry("SuspendSeconds", m_suspend_seconds);
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
    KConfigGroup cfg(KSharedConfig::openConfig(), QStringLiteral("General"));
    const QDateTime lastChecked = cfg.readEntry("CalendarsLastChecked", QDateTime());

    return QStringLiteral("Last Check: %1").arg(lastChecked.toString());
}

QStringList CalAlarmClient::dumpAlarms() const
{
    const auto start = QDateTime(QDate::currentDate(), QTime(0, 0));
    const auto end = start.date().endOfDay();

    AlarmsModel model {};
    model.setCalendarFiles(calendarFileList());
    model.setPeriod({.from =  start, .to = end});

    auto lst = QStringList();
    const auto alarms = model.alarms();

    for (const auto &alarm : std::as_const(alarms)) {
        lst << QStringLiteral("%1: \"%2\"").arg(alarm->time().toString(QStringLiteral("hh:mm")), alarm->parentUid());
    }

    return lst;
}

void CalAlarmClient::restoreSuspendedFromConfig()
{
    qDebug() << "\nrestoreSuspendedFromConfig:Restore suspended alarms from config";
    KConfigGroup suspendedGroup(KSharedConfig::openConfig(), QStringLiteral("Suspended"));
    const auto suspendedAlarms = suspendedGroup.groupList();

    for (const auto &s : suspendedAlarms) {
        KConfigGroup suspendedAlarm(&suspendedGroup, s);
        QString uid = suspendedAlarm.readEntry("UID");
        QString txt = alarmText(uid);
        QDateTime remindAt = QDateTime::fromString(suspendedAlarm.readEntry("RemindAt"), QStringLiteral("yyyy,M,d,HH,m,s"));
        qDebug() << "restoreSuspendedFromConfig:Restoring alarm" << uid << "," << txt << "," << remindAt.toString();

        if (!(uid.isEmpty() && remindAt.isValid() && !(txt.isEmpty()))) {
            m_notification_handler->addSuspendedNotification(uid, txt, remindAt);
        }
    }
}

QString CalAlarmClient::alarmText(const QString &uid) const
{
    AlarmsModel model {};
    model.setCalendarFiles(calendarFileList());
    model.setPeriod({.from = QDateTime(), .to = QDateTime::currentDateTime()});
    const auto alarms = model.alarms();

    for (const auto &alarm : std::as_const(alarms)) {
        if (alarm->parentUid() == uid) {
            return alarm->text();
        }
    }

    return QString();
}

void CalAlarmClient::flushSuspendedToConfig()
{
    KConfigGroup suspendedGroup(KSharedConfig::openConfig(), QStringLiteral("Suspended"));
    suspendedGroup.deleteGroup();

    const auto suspendedNotifications = m_notification_handler->suspendedNotifications();

    if (suspendedNotifications.isEmpty()) {
        qDebug() << "flushSuspendedToConfig:No suspended notification exists, nothing to write to config";
        KSharedConfig::openConfig()->sync();

        return;
    }

    for (const auto &s : suspendedNotifications) {
        qDebug() << "flushSuspendedToConfig:Flushing suspended alarm" << s->uid() << " to config";
        KConfigGroup notificationGroup(&suspendedGroup, s->uid());
        notificationGroup.writeEntry("UID", s->uid());
        notificationGroup.writeEntry("RemindAt", s->remindAt());
    }
    KSharedConfig::openConfig()->sync();
}

void CalAlarmClient::scheduleAlarmCheck()
{
    if ((m_wakeup_manager == nullptr) || !(m_wakeup_manager->active())) {
        qDebug() << "Wakeup manager is not active, alarms are handled by a timer";
        return;
    }

    // Look for alarms over the next days
    AlarmsModel model {};
    model.setCalendarFiles(calendarFileList());
    model.setPeriod({.from = m_last_check.addSecs(1), .to = (m_last_check.addDays(15)).date().startOfDay()});

    // Next schedule time: the trigger time of the first alarm or scheduled notification
    QDateTime scheduleWakeupAt {};
    auto firstAlarmTime = model.firstAlarmTime();
    auto firstSuspendedTime = m_notification_handler->firstSuspended();

    if (firstAlarmTime.isValid() && firstSuspendedTime.isValid()) {
        scheduleWakeupAt = (firstAlarmTime < firstSuspendedTime) ? firstAlarmTime : firstSuspendedTime;
    } else {
        scheduleWakeupAt = firstAlarmTime.isValid() ? firstAlarmTime : firstSuspendedTime;
    }

    if (scheduleWakeupAt.isValid()) {
        qDebug() << "scheduleAlarmCheck:" << "Shecdule next alarm check at" << scheduleWakeupAt.addSecs(1).toString(QStringLiteral("dd.MM.yyyy hh:mm:ss"));
        m_wakeup_manager->scheduleWakeup(scheduleWakeupAt.addSecs(1));
    } else { // If no alarms/suspended notifications exist, do not schedule anything and remove any scheduled wakeup call.
        qDebug() << "scheduleAlarmCheck:" << "Cancel scheduled wake up";
        m_wakeup_manager->removeWakeup();
    }
}

void CalAlarmClient::wakeupCallback()
{
    qDebug() << "CalAlarmClient wakeupCallback";

    checkAlarms();
    scheduleAlarmCheck();
}

void CalAlarmClient::setupShceduler(const bool wakeupManagerActive)
{
    if (wakeupManagerActive && m_wakeup_manager->hasWakeupFeatures()) {
        qDebug() << "setupShceduler: wake up manager offers an active backend with wakeup features";
        if (m_check_timer.isActive()) {
            m_check_timer.stop();
        }
        scheduleAlarmCheck();
    } else {
        qDebug() << "setupShceduler: No wakeup backend, alarms will be checked by a timer";
        if (!m_check_timer.isActive()) {
            m_check_timer.start(1000 * m_check_interval);
        }
    }
}
