/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "solidwakeupbackend.h"
#include <QDBusInterface>
#include <QDBusConnection>
#include <QDBusReply>
#include <QDebug>
#include <QDateTime>

SolidWakeupBackend::SolidWakeupBackend(QObject *parent) : WakeupBackend(parent)
{
    m_interface = new QDBusInterface(QStringLiteral("org.kde.Solid.PowerManagement"), QStringLiteral("/org/kde/Solid/PowerManagement"), QStringLiteral("org.kde.Solid.PowerManagement"), QDBusConnection::sessionBus(), this);
}

void SolidWakeupBackend::clearWakeup(const QVariant &scheduledWakeup)
{
    m_interface->call(QStringLiteral("clearWakeup"), scheduledWakeup.toInt());
}

QVariant SolidWakeupBackend::scheduleWakeup(const QVariantMap &callbackInfo, const quint64 wakeupAt)
{
    auto scheduledAt = QDateTime::fromSecsSinceEpoch(wakeupAt);

    qDebug() << "SolidWakeupBackend::scheduleWakeup at" << scheduledAt.toString("dd.MM.yyyy hh:mm:ss") << "tz " << scheduledAt.timeZoneAbbreviation() << " epoch" << wakeupAt;

    if (m_interface->isValid()) {
        QDBusReply<uint> reply = m_interface->call(QStringLiteral("scheduleWakeup"), callbackInfo["dbus-service"].toString(), QDBusObjectPath(callbackInfo["dbus-path"].toString()), wakeupAt);
        return reply.value();
    }

    return 0;
}
