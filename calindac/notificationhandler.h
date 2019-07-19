/*
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

#ifndef NOTIFICATIONHANDLER_H
#define NOTIFICATIONHANDLER_H

#include <QVariantMap>

class AlarmNotification;

/**
 * @brief Manages the creation and triggering of event alarm notifications
 *
 */
class NotificationHandler : public QObject
{
    Q_OBJECT
public:
    explicit NotificationHandler();
    ~NotificationHandler() override;

    /**
     * @brief Parses the internal list of active and suspended notifications and triggers their sending
     *
     */
    void sendNotifications();
    /**
     * @brief Creates an alarm notification object for the Incidence with \p uid. It sets the text to be displayed according to \p text. It adds this alarm notification to the internal list of active notifications (the list of notifications that should be sent at the next check).
     */
    void addActiveNotification(const QString& uid, const QString& text);
    /**
     * @brief  Creates an alarm notification object for the Incidence with \p uid. It sets the text to be displayed according to \p text. It adds this alarm notification to the internal list of suspended notifications.
     *
     */
    void addSuspendedNotification(const QString& uid, const QString& text, const QDateTime& remindTime);
    /**
     * @brief Sets the time period to check for alarms. \p checkPeriod should contain two QDateTime members: from, to
     *
     */
    void setPeriod(const QVariantMap& checkPeriod);
    /**
     * @return The list of active notifications. It is the set of notification that should be sent at the next check
     */
    QHash<QString, AlarmNotification*> activeNotifications() const;
    /**
     * @return The list of suspended notifications
     */
    QHash<QString, AlarmNotification*> suspendedNotifications() const;
    /**
     * @return The time period to check for alarms
     */
    QVariantMap period() const;
public Q_SLOTS:
    /**
     * @brief Dismisses any further notification display for the alarm \p notification.
     *
     */
    void dismiss(AlarmNotification* const notification);
    /**
     * @brief Suspends the display of the alarm \p notification, by removing it from the list of active and putting it to the list of suspended notifications. Remind time is set according to configuration.
     */
    void suspend(AlarmNotification* const notification);
private:
    void sendActiveNotifications();
    void sendSuspendedNotifications();

    QHash<QString, AlarmNotification*> mActiveNotifications;
    QHash<QString, AlarmNotification*> mSuspendedNotifications;
    QVariantMap mPeriod;
    int mSuspendSeconds;
};
#endif
