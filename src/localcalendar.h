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
class AlarmChecker;

class LocalCalendar : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QSharedPointer<MemoryCalendar> memorycalendar READ memorycalendar WRITE setMemorycalendar NOTIFY memorycalendarChanged)

public:
    explicit LocalCalendar(QObject *parent = nullptr);
    ~LocalCalendar() override;

    MemoryCalendar::Ptr memorycalendar();
    QString name() const;

    void setMemorycalendar(MemoryCalendar::Ptr memoryCalendar);
    void setName(QString calendarName);
    Q_INVOKABLE static QVariantMap importCalendar(const QString &calendarName, const QUrl &sourcePath);
    Q_INVOKABLE static QString fileNameFromUrl(const QUrl &sourcePath);
    Q_INVOKABLE int todosCount(const QDate &date) const;
    Q_INVOKABLE int eventsCount(const QDate &date) const;
public Q_SLOTS:
    void deleteCalendar();
    bool save();
Q_SIGNALS:
    void memorycalendarChanged();
    void nameChanged();
    void todosChanged();
    void eventsChanged();

private:
    static QVariantMap canCreateFile(const QString &calendarName);
    void loadCalendar(const QString &calendarName);
    bool loadStorage();
    void reloadStorage();

    MemoryCalendar::Ptr m_calendar;
    FileStorage::Ptr m_cal_storage;
    QString m_name;
    QString m_fullpath;
    CalindoriConfig *m_config;
    QDateTime m_fs_sync_dt;
    AlarmChecker *m_alarm_checker;
};

#endif // LOCALCALENDAR_H

