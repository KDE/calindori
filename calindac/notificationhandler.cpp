/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
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
    while (suspItr != mSuspendedNotifications.end()) {
        if (suspItr.value()->remindAt() < mPeriod["to"].toDateTime()) {
            qDebug() << "sendNotifications:\tSending notification for suspended alarm" <<  suspItr.value()->uid() << ", text is" << suspItr.value()->text();
            suspItr.value()->send();
            suspItr = mSuspendedNotifications.erase(suspItr);
        } else {
            suspItr++;
        }
    }
}

void NotificationHandler::sendActiveNotifications()
{
    for (const auto& n : mActiveNotifications) {
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
