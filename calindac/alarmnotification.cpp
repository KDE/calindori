/*
 *  Copyright (c) 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  As a special exception, permission is given to link this program
 *  with any edition of Qt, and distribute the resulting executable,
 *  without including the source code for Qt in the source distribution.
 */

#include "alarmnotification.h"
#include <KLocalizedString>
#include <QDebug>
#include "notificationhandler.h"

AlarmNotification::AlarmNotification(NotificationHandler* handler, const QString & uid) : mUid(uid), mRemindAt(QDateTime()), mNotificationHandler(handler)
{
    mNotification = new KNotification("alarm");
    mNotification->setActions({i18n("Suspend"),i18n("Dismiss")});

    connect(mNotification, &KNotification::action1Activated, this, &AlarmNotification::suspend);
    connect(mNotification, &KNotification::action2Activated, this, &AlarmNotification::dismiss);
    connect(this, &AlarmNotification::suspend, mNotificationHandler, [=](){ mNotificationHandler->suspend(this);});
    connect(this, &AlarmNotification::dismiss, mNotificationHandler, [=](){ mNotificationHandler->dismiss(this);});
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

