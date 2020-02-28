/*
  Copyright (c) 2019-2020 Dimitris Kardarakos <dimkard@posteo.net>

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

#include "notificationhandler.h"
#include "alarmnotification.h"
#include <KLocalizedString>
#include <KSharedConfig>
#include <KConfigGroup>
#include <QDebug>

NotificationHandler::NotificationHandler() : mActiveNotifications(QHash<QString, AlarmNotification*>()), mSuspendedNotifications(QHash<QString, AlarmNotification*>())
{
    KConfigGroup generalGroup(KSharedConfig::openConfig(), "General");
    mSuspendSeconds = generalGroup.readEntry("SuspendSeconds", 60);
}

NotificationHandler::~NotificationHandler() = default;

void NotificationHandler::addActiveNotification(const QString& uid, const QString& text)
{
    AlarmNotification* notification = new AlarmNotification(this, uid);
    notification->setText(text);
    mActiveNotifications[notification->uid()] = notification;
}

void NotificationHandler::addSuspendedNotification(const QString& uid, const QString& txt, const QDateTime& remindTime)
{
    qDebug() << "addSuspendedNotification:\tAdding notification to suspended list, uid:" << uid << "text:" << txt << "remindTime:" << remindTime;
    AlarmNotification* notification = new AlarmNotification(this, uid);
    notification->setText(txt);
    notification->setRemindAt(remindTime);
    mSuspendedNotifications[notification->uid()] = notification;
}

void NotificationHandler::sendSuspendedNotifications()
{
    auto suspItr = mSuspendedNotifications.begin();
    while(suspItr != mSuspendedNotifications.end())
    {
        if(suspItr.value()->remindAt() < mPeriod["to"].toDateTime())
        {
            qDebug() << "sendNotifications:\tSending notification for suspended alarm" <<  suspItr.value()->uid() << ", text is" << suspItr.value()->text();
            suspItr.value()->send();
            suspItr = mSuspendedNotifications.erase(suspItr);
       }
       else
       {
           suspItr++;
       }
    }
}

void NotificationHandler::sendActiveNotifications()
{
    for(const auto& n: mActiveNotifications)
    {
        qDebug() << "sendNotifications:\tSending notification for alarm" <<  n->uid();
        n->send();
    }
}

void NotificationHandler::sendNotifications()
{
    qDebug() << "\nsendNotifications:\tLooking for notifications, total Active:" << mActiveNotifications.count() << ", total Suspended:" << mSuspendedNotifications.count();

    sendSuspendedNotifications();
    sendActiveNotifications();
}

void NotificationHandler::dismiss(AlarmNotification* const notification)
{
    mActiveNotifications.remove(notification->uid());

    qDebug() << "\ndismiss:\tAlarm" << notification->uid() << "dismissed";
}

void NotificationHandler::suspend(AlarmNotification* const notification)
{
    AlarmNotification* suspendedNotification = new AlarmNotification(this, notification->uid());
    suspendedNotification->setText(notification->text());
    suspendedNotification->setRemindAt(QDateTime(QDateTime::currentDateTime()).addSecs(mSuspendSeconds));

    mSuspendedNotifications[notification->uid()] = suspendedNotification;
    mActiveNotifications.remove(notification->uid());

    qDebug() << "\nsuspend\t:Alarm " << notification->uid() << "suspended";
}

QVariantMap NotificationHandler::period() const
{
    return mPeriod;
}

void NotificationHandler::setPeriod(const QVariantMap & checkPeriod)
{
    mPeriod = checkPeriod;
}

QHash<QString, AlarmNotification *> NotificationHandler::activeNotifications() const
{
    return mActiveNotifications;
}

QHash<QString, AlarmNotification *> NotificationHandler::suspendedNotifications() const
{
    return mSuspendedNotifications;
}
