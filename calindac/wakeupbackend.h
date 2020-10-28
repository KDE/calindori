/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef WAKEUPBACKEND_H
#define WAKEUPBACKEND_H

#include <QObject>
#include <QVariantMap>

/**
 * @brief Power management backend that offers scheduling wake up at a time specified
 *
 */
class WakeupBackend : public QObject
{
public:
    explicit WakeupBackend(QObject *parent = nullptr) : QObject(parent) {}
    virtual ~WakeupBackend() = default;

    /**
     * @brief Schedule a wake-up at the time provided
     *
     * @param callbackInfo Information about the method to call back after awaking by the power manager module
     * @return The scheduled wakeup returned by the power manager module
     */
    virtual QVariant scheduleWakeup(const QVariantMap &callbackInfo, const quint64 wakeupAt) = 0;

    /**
     * @brief Clear a scheduled wake-up
     *
     * @param scheduledWakeup The scheduled wake up, as returned by the scheduleWakeup method
     */
    virtual void clearWakeup(const QVariant &scheduledWakeup) = 0;
};

#endif // WAKEUPBACKEND_H
