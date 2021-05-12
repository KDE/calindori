/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "alarmchecker.h"

#ifndef Q_OS_ANDROID
#include <QDBusInterface>
#include <QDBusConnection>
#endif
#include <QDebug>

AlarmChecker::AlarmChecker(QObject *parent) : QObject(parent)
{
#ifndef Q_OS_ANDROID
    m_interface = new QDBusInterface(QStringLiteral("org.kde.calindac"), QStringLiteral("/calindac"), QStringLiteral("org.kde.calindac"), QDBusConnection::sessionBus(), this);
#endif
}

void AlarmChecker::scheduleAlarmCheck()
{
#ifndef Q_OS_ANDROID
    m_interface->call(QStringLiteral("scheduleAlarmCheck"));
#endif
}
