/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "alarmchecker.h"

#include <QDBusInterface>
#include <QDBusConnection>
#include <QDebug>

AlarmChecker::AlarmChecker(QObject *parent) : QObject(parent)
{
    m_interface = new QDBusInterface(QStringLiteral("org.kde.calindac"), QStringLiteral("/calindac"), QStringLiteral("org.kde.calindac"), QDBusConnection::sessionBus(), this);
}

void AlarmChecker::scheduleAlarmCheck()
{
    m_interface->call(QStringLiteral("scheduleAlarmCheck"));
}
