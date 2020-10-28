/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef CALALARMCLIENT_H
#define CALALARMCLIENT_H

#include <QTimer>
#include <QDateTime>

class WakeupBackend;
class AlarmsModel;
class NotificationHandler;
class WakeupManager;
/**
 * @brief Client that orchestrates the parsing of calendars and the display of notifications for event alarms. It exposes a D-Bus Interface containing a set of callable methods.
 *
 */
class CalAlarmClient : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.kde.calindac")

public:
    explicit CalAlarmClient(QObject *parent = nullptr);
    ~CalAlarmClient() override;

    // DBUS interface
    /**
     * @brief Quits the application
     *
     */
    Q_SCRIPTABLE void quit();

    /**
     * @brief Checks the calendars for event alarms
     *
     */
    Q_SCRIPTABLE void forceAlarmCheck();

    /**
     * @return The date time of the last check done for event alarms
     */
    Q_SCRIPTABLE QString dumpLastCheck() const;

    /**
     * @return The list of today's event alarms
     */
    Q_SCRIPTABLE QStringList dumpAlarms() const;

    /**
     * @return Schedule alarm check
     */
    Q_SCRIPTABLE void scheduleAlarmCheck();

    /**
     * @return The method that should be triggered by the wakeup backend
     */
    void wakeupCallback();

private:
    QString alarmText(const QString &uid) const;
    void checkAlarms();
    void saveLastCheckTime();
    void saveCheckInterval();
    void saveSuspendSeconds();
    void restoreSuspendedFromConfig();
    void flushSuspendedToConfig();
    QStringList calendarFileList() const;

    AlarmsModel *m_alarms_model;
    QDateTime m_last_check;
    QTimer m_check_timer;
    NotificationHandler *m_notification_handler;
    int m_check_interval;
    int m_suspend_seconds;
    WakeupManager *m_wakeup_manager;
};
#endif
