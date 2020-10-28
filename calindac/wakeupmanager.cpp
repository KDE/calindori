/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "wakeupmanager.h"
#include "solidwakeupbackend.h"
#include "powermanagementadaptor.h"
#include <QDBusInterface>
#include <QDBusConnection>
#include <QDBusReply>
#include <QDebug>

WakeupManager::WakeupManager(QObject *parent) : QObject(parent), m_cookie {-1}, m_active {false}
{
    m_callback_info = QVariantMap({
        {"dbus-service", QString { "org.kde.calindac"} },
        {"dbus-path", QString {"/wakeupmanager"} }
    });

    new PowerManagementAdaptor(this);
    m_wakeup_backend = new SolidWakeupBackend(this);

    QDBusConnection dbus = QDBusConnection::sessionBus();
    dbus.registerObject(m_callback_info["dbus-path"].toString(), this);

    checkBackend();
}

void WakeupManager::scheduleWakeup(const QDateTime wakeupAt)
{
    if (wakeupAt <= QDateTime::currentDateTime()) {
        qDebug() << "WakeupManager:" << "Requested to schedule wake up at" << wakeupAt.toString("dd.MM.yyyy hh:mm:ss") << "Can't chedule a wakeup in the past";
        return;
    }

    auto scheduledCookie = m_wakeup_backend->scheduleWakeup(m_callback_info, wakeupAt.toSecsSinceEpoch()).toInt();

    if (scheduledCookie > 0) {
        qDebug() << "WakeupManager: wake up has been scheduled, wakeup time:" << wakeupAt.toString("dd.MM.yyyy hh:mm:ss") << "Received cookie" << scheduledCookie;

        if (m_cookie > 0) {
            removeWakeup(m_cookie);
        }

        m_cookie = scheduledCookie;
    }

}

void WakeupManager::wakeupCallback(int cookie)
{
    qDebug() << "WakeupManager: awaken by cookie" << cookie;

    if (m_cookie == cookie) {
        m_cookie = -1;
        Q_EMIT wakeupAlarmClient();
    } else {
        qDebug() << "WakeupManager: the cookie is invalid";
    }
}

void WakeupManager::removeWakeup(int cookie)
{
    qDebug() << "WakeupManager: clearing cookie" << cookie;

    m_wakeup_backend->clearWakeup(cookie);
    m_cookie = -1;
}

void WakeupManager::checkBackend()
{
    auto checkCookie = m_wakeup_backend->scheduleWakeup(m_callback_info, QDateTime::currentDateTime().addDays(1).toSecsSinceEpoch()).toInt();

    if (checkCookie > 0) {
        qDebug() << "WakeupManager: the backend is active";
        m_wakeup_backend->clearWakeup(checkCookie);
        setActive(true);
    } else {
        qDebug() << "WakeupManager: the backend does not offer wake up features";
        setActive(false);
    }
}

bool WakeupManager::active() const
{
    return m_active;
}

void WakeupManager::setActive(const bool activeBackend)
{
    if (activeBackend != m_active) {
        m_active = activeBackend;
        Q_EMIT activeChanged();
    }
}
