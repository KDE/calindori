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
#include <KCalendarCore/Event>
#include <KCalendarCore/Todo>

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
    Q_INVOKABLE void importFromBuffer(LocalCalendar *localCalendar);
    Q_INVOKABLE void abortImporting();

Q_SIGNALS:
    void statusMessageChanged(const QString &statusMessage, const int messageType);

private:
    QVector<QSharedPointer<KCalendarCore::Event>> m_events;
    QVector<QSharedPointer<KCalendarCore::Todo>> m_todos;
};
#endif
