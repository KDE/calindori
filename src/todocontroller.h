/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef TODOCONTROLLER_H
#define TODOCONTROLLER_H
#include <QObject>
#include <QVariantMap>

class LocalCalendar;

class TodoController : public QObject
{
    Q_OBJECT

public:
    explicit TodoController(QObject *parent = nullptr);
    ~TodoController() override;

    Q_INVOKABLE void remove(LocalCalendar *calendar, const QVariantMap &todo);
    Q_INVOKABLE void addEdit(LocalCalendar *calendar, const QVariantMap &todo);
    Q_INVOKABLE QVariantMap validate(const QVariantMap &todo) const;
};
#endif

