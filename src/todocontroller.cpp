/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "todocontroller.h"
#include "localcalendar.h"
#include <KCalendarCore/Todo>
#include <KCalendarCore/Calendar>
#include <KLocalizedString>
#include <QDebug>

TodoController::TodoController(QObject *parent) : QObject(parent) {}

TodoController::~TodoController() = default;

void TodoController::addEdit(LocalCalendar *localCalendar, const QVariantMap &todo)
{
    qDebug() << "Adding/updating todo";
    Calendar::Ptr calendar = localCalendar->calendar();
    Todo::Ptr vtodo;
    QDateTime now = QDateTime::currentDateTime();
    QString uid = todo["uid"].toString();
    QString summary = todo["summary"].toString();
    QDate startDate = todo["startDate"].toDate();
    int startHour = todo["startHour"].value<int>();
    int startMinute = todo["startMinute"].value<int>();
    bool allDayFlg = todo["allDay"].toBool();

    if (uid == "") {
        vtodo = Todo::Ptr(new Todo());
        vtodo->setUid(summary.at(0) + now.toString("yyyyMMddhhmmsszzz"));
    } else {
        vtodo = calendar->todo(uid);
        vtodo->setUid(uid);
    }

    QDateTime startDateTime;
    if (allDayFlg) {
        startDateTime = startDate.startOfDay();
    } else {
        startDateTime = QDateTime(startDate, QTime(startHour, startMinute, 0, 0), QTimeZone::systemTimeZone());
    }

    vtodo->setDtStart(startDateTime);

    QDate dueDate = todo["dueDate"].toDate();

    bool validDueHour {false};
    int dueHour = todo["dueHour"].toInt(&validDueHour);

    bool validDueMinutes {false};
    int dueMinute = todo["dueMinute"].toInt(&validDueMinutes);

    QDateTime dueDateTime = QDateTime();
    if (dueDate.isValid() && validDueHour && validDueMinutes && !allDayFlg) {
        dueDateTime = QDateTime(dueDate, QTime(dueHour, dueMinute, 0, 0), QTimeZone::systemTimeZone());
    } else if (dueDate.isValid() && allDayFlg) {
        dueDateTime = dueDate.startOfDay();
    }

    vtodo->setDtDue(dueDateTime);
    vtodo->setDescription(todo["description"].toString());
    vtodo->setSummary(summary);
    vtodo->setAllDay((startDate.isValid() || dueDate.isValid()) ? allDayFlg : false);
    vtodo->setLocation(todo["location"].toString());
    vtodo->setCompleted(todo["completed"].toBool());

    vtodo->clearAlarms();
    QVariantList newAlarms = todo["alarms"].value<QVariantList>();
    QVariantList::const_iterator itr = newAlarms.constBegin();
    while (itr != newAlarms.constEnd()) {
        Alarm::Ptr newAlarm = vtodo->newAlarm();
        QHash<QString, QVariant> newAlarmHashMap = (*itr).value<QHash<QString, QVariant>>();
        int startOffsetValue = newAlarmHashMap["startOffsetValue"].value<int>();
        int startOffsetType = newAlarmHashMap["startOffsetType"].value<int>();
        int actionType = newAlarmHashMap["actionType"].value<int>();

        newAlarm->setStartOffset(Duration(startOffsetValue, static_cast<Duration::Type>(startOffsetType)));
        newAlarm->setType(static_cast<Alarm::Type>(actionType));
        newAlarm->setEnabled(true);
        newAlarm->setText((vtodo->summary()).isEmpty() ?  vtodo->description() : vtodo->summary());
        ++itr;
    }

    calendar->addTodo(vtodo);
    bool merged = localCalendar->save();

    Q_EMIT localCalendar->todosChanged();

    qDebug() << "Todo added/updated: " << merged;
}

void TodoController::remove(LocalCalendar *localCalendar, const QVariantMap &todo)
{
    qDebug() << "Deleting todo";
    Calendar::Ptr calendar = localCalendar->calendar();
    QString uid = todo["uid"].toString();
    Todo::Ptr vtodo = calendar->todo(uid);

    calendar->deleteTodo(vtodo);
    bool removed = localCalendar->save();

    Q_EMIT localCalendar->todosChanged();
    qDebug() << "Todo deleted: " << removed;
}

QVariantMap TodoController::validate(const QVariantMap &todo) const
{
    QVariantMap result {};

    QDate startDate = todo["startDate"].toDate();
    bool validStartHour {false};
    int startHour = todo["startHour"].toInt(&validStartHour);
    bool validStartMinutes {false};
    int startMinute = todo["startMinute"].toInt(&validStartMinutes);
    QDate dueDate = todo["dueDate"].toDate();
    bool validDueHour {false};
    int dueHour = todo["dueHour"].toInt(&validDueHour);
    bool validDueMinutes {false};
    int dueMinute = todo["dueMinute"].toInt(&validDueMinutes);
    bool allDayFlg = todo["allDay"].toBool();

    if (startDate.isValid() && validStartHour && validStartMinutes && dueDate.isValid() && validDueHour && validDueMinutes) {
        if (allDayFlg && (dueDate != startDate)) {
            result["success"] = false;
            result["reason"] = i18n("In case of all day tasks, start date and due date should be equal");

            return result;
        }

        if (!allDayFlg && (QDateTime(startDate, QTime(startHour, startMinute, 0, 0), QTimeZone::systemTimeZone()) >  QDateTime(dueDate, QTime(dueHour, dueMinute, 0, 0), QTimeZone::systemTimeZone()))) {
            result["success"] = false;
            result["reason"] = i18n("Due date time should be equal to or greater than the start date time");
            return result;
        }
    }

    result["success"] = true;
    result["reason"] = QString();

    return result;
}
