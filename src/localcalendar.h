/*
 * SPDX-FileCopyrightText: 2018 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef LOCALCALENDAR_H
#define LOCALCALENDAR_H

#include <QSharedPointer>
#include <KCalendarCore/MemoryCalendar>
#include <KCalendarCore/FileStorage>
#include <KCalendarCore/Event>
#include <QVariantMap>

using namespace KCalendarCore;

class CalindoriConfig;

class LocalCalendar : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QSharedPointer<MemoryCalendar> memorycalendar READ memorycalendar WRITE setMemorycalendar NOTIFY memorycalendarChanged)

public:
    explicit LocalCalendar(QObject *parent = nullptr);
    ~LocalCalendar() override;

    MemoryCalendar::Ptr memorycalendar() const;
    QString name() const;

    void setMemorycalendar(MemoryCalendar::Ptr memoryCalendar);
    void setName(QString calendarName);
    Q_INVOKABLE static QVariantMap importCalendar(const QString &calendarName, const QUrl &sourcePath);
    Q_INVOKABLE static QString fileNameFromUrl(const QUrl &sourcePath);

public Q_SLOTS:
    int todosCount(const QDate &date) const;
    void deleteCalendar();
    int eventsCount(const QDate &date) const;
    bool save();
Q_SIGNALS:
    void memorycalendarChanged();
    void nameChanged();
    void todosChanged();
    void eventsChanged();

private:
    static QVariantMap canCreateFile(const QString &calendarName);
    void loadCalendar(const QString &calendarName);

    MemoryCalendar::Ptr m_calendar;
    FileStorage::Ptr m_cal_storage;
    QString m_name;
    QString m_fullpath;
    CalindoriConfig *m_config;
};

#endif // LOCALCALENDAR_H

