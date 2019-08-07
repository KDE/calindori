/*
  This program used korgac as a starting point. korgac can be found here: https://cgit.kde.org/korganizer.git/tree/korgac. It has been created by Cornelius Schumacher.

  Copyright (c) 2019 Dimitris Kardarakos <dimkard@posteo.net>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

  As a special exception, permission is given to link this program
  with any edition of Qt, and distribute the resulting executable,
  without including the source code for Qt in the source distribution.
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
    Q_CLASSINFO( "D-Bus Interface", "org.kde.calindac" )

public:
    explicit CalAlarmClient(QObject* parent = nullptr);
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
    QString alarmText(const QString& uid) const;
    void checkAlarms();
    void saveLastCheckTime();
    void saveCheckInterval();
    void saveSuspendSeconds();
    void restoreSuspendedFromConfig();
    void flushSuspendedToConfig();
    QStringList calendarFileList() const;

    AlarmsModel* mAlarmsModel;
    QDateTime mLastChecked;
    QTimer mCheckTimer;
    NotificationHandler* mNotificationHandler;
    int mCheckInterval;
    int mSuspendSeconds;
};
#endif
