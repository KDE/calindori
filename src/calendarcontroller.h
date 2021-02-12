/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef CALENDAR_CONTROLLER_H
#define CALENDAR_CONTROLLER_H

#include <QObject>
#include <QVector>
#include <QSharedDataPointer>
#include <QVariantMap>
#include <KCalendarCore/Event>
#include <KCalendarCore/Todo>
#include "attendeesmodel.h"

class LocalCalendar;

class CalendarController : public QObject
{
    Q_OBJECT

public:
    enum MessageType {
        Question = 0,
        PositiveAnswer,
        NegativeAnswer
    };

    explicit CalendarController(QObject *parent = nullptr);

    void importCalendarData(const QByteArray &data);
    Q_INVOKABLE void importFromBuffer(const QString &targetCalendar);
    Q_INVOKABLE void importFromBuffer(LocalCalendar *localCalendar);
    Q_INVOKABLE void abortImporting();
    Q_INVOKABLE void removeEvent(LocalCalendar *localCalendar, const QVariantMap &event);
    Q_INVOKABLE void upsertEvent(LocalCalendar *localCalendar, const QVariantMap &event, const QVariantList &attendeesList);
    /**
     * @brief Returns the current datetime in the local time zone
     *
     * @return QDateTime
     */
    Q_INVOKABLE QDateTime localSystemDateTime() const;
    /**
     * @brief Validate an event before saving
     *
     * @return A QVariantMap response to be handled by the caller
     */
    Q_INVOKABLE QVariantMap validateEvent(const QVariantMap &eventMap) const;
    Q_INVOKABLE void removeTodo(LocalCalendar *localCalendar, const QVariantMap &todo);
    Q_INVOKABLE void upsertTodo(LocalCalendar *localCalendar, const QVariantMap &todo);
    Q_INVOKABLE QVariantMap validateTodo(const QVariantMap &todo) const;
    Q_INVOKABLE QString fileNameFromUrl(const QUrl &sourcePath);
    Q_INVOKABLE QVariantMap exportData(const QString &calendarName);

Q_SIGNALS:
    void statusMessageChanged(const QString &statusMessage, const int messageType);

private:
    void sendMessage(const bool positive);
    QVector<QSharedPointer<KCalendarCore::Event>> m_events;
    QVector<QSharedPointer<KCalendarCore::Todo>> m_todos;
};
#endif
