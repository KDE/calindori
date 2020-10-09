/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef CALALARMCLIENT_H
#define CALALARMCLIENT_H

#include <QTimer>
#include <QDateTime>

class AlarmsModel;
class NotificationHandler;
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

public Q_SLOTS:
    // DBUS interface
    /**
     * @brief Quits the application. It is included in the DBUS interface methods.
     *
     */
    void quit();

    /**
     * @brief Checks the calendars for event alarms. It is included in the DBUS interface methods.
     *
     */
    void forceAlarmCheck();

    /**
     * @return The date time of the last check done for event alarms. It is included in the DBUS interface methods.
     */
    QString dumpLastCheck() const;

    /**
     * @return The list of today's event alarms
     */
    QStringList dumpAlarms() const;

private:
    QString alarmText(const QString &uid) const;
    void checkAlarms();
    void saveLastCheckTime();
    void saveCheckInterval();
    void saveSuspendSeconds();
    void restoreSuspendedFromConfig();
    void flushSuspendedToConfig();
    QStringList calendarFileList() const;

    AlarmsModel *mAlarmsModel;
    QDateTime mLastChecked;
    QTimer mCheckTimer;
    NotificationHandler *mNotificationHandler;
    int mCheckInterval;
    int mSuspendSeconds;
};
#endif
