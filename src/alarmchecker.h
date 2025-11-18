/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef ALARM_CHECKER_H
#define ALARM_CHECKER_H

#include <QObject>

class QDBusInterface;

class AlarmChecker : public QObject
{
    Q_OBJECT

public:
    explicit AlarmChecker(QObject *parent = nullptr);
    virtual ~AlarmChecker() = default;

    /**
     * @brief Schedule the next alarm check
     *
     */
    void scheduleAlarmCheck();

private:
#ifndef Q_OS_ANDROID
    QDBusInterface *m_interface;
#endif
};
#endif //ALARM_CHECKER_H
