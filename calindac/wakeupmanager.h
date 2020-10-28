/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef WAKEUPMANAGER_H
#define WAKEUPMANAGER_H

#include <QObject>
#include <QDateTime>
#include <QVariantMap>

class WakeupBackend;

class WakeupManager : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.kde.PowerManagement")

public:
    explicit WakeupManager(QObject *parent = nullptr);
    virtual ~WakeupManager() = default;

    /**
     * @brief Schedule a wake-up at the time given
     */
    void scheduleWakeup(const QDateTime wakeupAt);

    /**
     * @return True if there is a backend that offers wake-up features
     */
    bool active() const;

Q_SIGNALS:
    /**
     * @brief To be emited when the parent should take over and manage the wake-up
     *
     */
    void wakeupAlarmClient();

    /**
     * @brief To be emited when wake-up manager status (active/not active) is changed
     *
     */
    void activeChanged();

public Q_SLOTS:

    /**
     * @return Handles a wake-up
     */
    void wakeupCallback(int cookie);

    /**
     * @return Clear a scheduled wakeup
     */
    void removeWakeup(int cookie);

private:
    void checkBackend();
    void setActive(const bool activeBackend);

    WakeupBackend *m_wakeup_backend;
    int m_cookie;
    QVariantMap m_callback_info;
    int m_active;
};
#endif //WAKEUPMANAGER_H
