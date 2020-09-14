/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "alarmnotification.h"
#include "notificationhandler.h"
#include <KLocalizedString>
#include <QDebug>

AlarmNotification::AlarmNotification(NotificationHandler* handler, const QString & uid) : mUid(uid), mRemindAt(QDateTime()), mNotificationHandler(handler)
{
    mNotification = new KNotification("alarm");
    mNotification->setActions({i18n("Suspend"), i18n("Dismiss")});

    connect(mNotification, &KNotification::action1Activated, this, &AlarmNotification::suspend);
    connect(mNotification, &KNotification::action2Activated, this, &AlarmNotification::dismiss);
    connect(this, &AlarmNotification::suspend, mNotificationHandler, [ = ]() {
        mNotificationHandler->suspend(this);
    });
    connect(this, &AlarmNotification::dismiss, mNotificationHandler, [ = ]() {
        mNotificationHandler->dismiss(this);
    });
}

AlarmNotification::~AlarmNotification()
{
    delete mNotification;
}

void AlarmNotification::send() const
{
    mNotification->sendEvent();
}

QString AlarmNotification::uid() const
{
    return mUid;
}

QString AlarmNotification::text() const
{
    return mNotification->text();
}

void AlarmNotification::setText(const QString& alarmText)
{
    mNotification->setText(alarmText);
}

QDateTime AlarmNotification::remindAt() const
{
    return mRemindAt;
}

void AlarmNotification::setRemindAt(const QDateTime& remindAtDt)
{
    mRemindAt = remindAtDt;
}
