/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef SOLIDWAKEUPBACKEND_H
#define SOLIDWAKEUPBACKEND_H

#include "wakeupbackend.h"

class QDBusInterface;

class SolidWakeupBackend : public WakeupBackend
{
public:
    explicit SolidWakeupBackend(QObject *parent = nullptr);
    virtual ~SolidWakeupBackend() = default;

    /**
     * @brief Schedule a wakeup at the time provided
     *
     * @param callbackInfo should provide:
     * dbus-service: the D-Bus service to call back after waking up
     * dbus-path: The path of the D-Bus service to call back after waking up
     * @param wakeupAt The exact time (in seconds) to schedule the wake-up
     * @return The scheduled wakeup returned by the power manager module
     */
    virtual QVariant scheduleWakeup(const QVariantMap &callbackInfo, const quint64 wakeupAt) override;

    /**
     * @brief Clear a scheduled wake-up
     *
     * @param scheduledWakeup The integer cookie of the scheduled wake up
     */
    virtual void clearWakeup(const QVariant &scheduledWakeup) override;

private:
    QDBusInterface *m_interface;
};

#endif // SOLIDWAKEUPBACKEND_H
