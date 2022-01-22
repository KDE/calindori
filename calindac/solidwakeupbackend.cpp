/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "solidwakeupbackend.h"
#include <QDBusInterface>
#include <QDBusConnection>
#include <QDBusReply>
#include <QDBusServiceWatcher>
#include <QDebug>
#include <QDateTime>

SolidWakeupBackend::SolidWakeupBackend(QObject *parent) : WakeupBackend(parent)
{
    auto svcName = QStringLiteral("org.kde.Solid.PowerManagement");

    m_interface = new QDBusInterface {svcName,  QStringLiteral("/org/kde/Solid/PowerManagement"), QStringLiteral("org.kde.Solid.PowerManagement"), QDBusConnection::sessionBus(), this};
    m_watcher = new QDBusServiceWatcher {svcName, QDBusConnection::sessionBus(), QDBusServiceWatcher::WatchForRegistration | QDBusServiceWatcher::WatchForUnregistration};

    connect(m_watcher, &QDBusServiceWatcher::serviceRegistered, [this]() {
        Q_EMIT backendChanged(true);
    });
    connect(m_watcher, &QDBusServiceWatcher::serviceUnregistered, [this]() {
        Q_EMIT backendChanged(false);
    });
}

void SolidWakeupBackend::clearWakeup(const QVariant &scheduledWakeup)
{
    m_interface->call(QStringLiteral("clearWakeup"), scheduledWakeup.toInt());
}

QVariant SolidWakeupBackend::scheduleWakeup(const QVariantMap &callbackInfo, const quint64 wakeupAt)
{
    auto scheduledAt = QDateTime::fromSecsSinceEpoch(wakeupAt);

    qDebug() << "SolidWakeupBackend::scheduleWakeup at" << scheduledAt.toString(QStringLiteral("dd.MM.yyyy hh:mm:ss")) << "tz " << scheduledAt.timeZoneAbbreviation() << " epoch" << wakeupAt;

    QDBusReply<uint> reply = m_interface->call(QStringLiteral("scheduleWakeup"), callbackInfo[QStringLiteral("dbus-service")].toString(), QDBusObjectPath(callbackInfo[QStringLiteral("dbus-path")].toString()), wakeupAt);
    if (reply.isValid()) {
        return reply.value();
    }

    return 0;
}

bool SolidWakeupBackend::isValid()
{
    if (m_interface != nullptr) {
        return m_interface->isValid();
    }

    return false;
}

bool SolidWakeupBackend::isWakeupBackend()
{
    auto callMessage = QDBusMessage::createMethodCall(m_interface->service(), m_interface->path(), QStringLiteral("org.freedesktop.DBus.Introspectable"), QStringLiteral("Introspect"));
    QDBusReply<QString> result = QDBusConnection::sessionBus().call(callMessage);

    if (result.isValid() && result.value().indexOf(QStringLiteral("scheduleWakeup")) >= 0) {
        return true;
    }

    return false;

}
