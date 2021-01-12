/*
 * SPDX-FileCopyrightText: 2018 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef LOCALCALENDAR_H
#define LOCALCALENDAR_H

#include <QSharedPointer>
#include <KCalendarCore/Calendar>
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
    Q_PROPERTY(QString ownerName READ ownerName WRITE setOwnerName NOTIFY ownerNameChanged)
    Q_PROPERTY(QString ownerEmail READ ownerEmail WRITE setOwnerEmail NOTIFY ownerEmailChanged)
    Q_PROPERTY(bool isExternal READ isExternal NOTIFY isExternalChanged)
    Q_PROPERTY(QSharedPointer<Calendar> calendar READ calendar WRITE setCalendar NOTIFY calendarChanged)

public:
    explicit LocalCalendar(QObject *parent = nullptr);
    ~LocalCalendar() override;

    Calendar::Ptr calendar();
    QString name() const;
    QString ownerName() const;
    QString ownerEmail() const;
    bool isExternal() const;

    void setCalendar(Calendar::Ptr calendar);
    void setName(QString &calendarName);
    void setOwnerName(QString &ownerName);
    void setOwnerEmail(QString &ownerEmail);

    Q_INVOKABLE int todosCount(const QDate &date) const;
    Q_INVOKABLE int eventsCount(const QDate &date) const;

public Q_SLOTS:
    void deleteCalendar();
    bool save();

Q_SIGNALS:
    void calendarChanged();
    void nameChanged();
    void todosChanged();
    void eventsChanged();
    void ownerNameChanged();
    void ownerEmailChanged();
    void isExternalChanged();

private:
    static QVariantMap canCreateFile(const QString &calendarName);
    void loadCalendar(const QString &calendarName);
    bool loadStorage();
    void reloadStorage();

    Calendar::Ptr m_calendar;
    FileStorage::Ptr m_cal_storage;
    QString m_name;
    QString m_fullpath;
    CalindoriConfig *m_config;
    QDateTime m_fs_sync_dt;
    AlarmChecker *m_alarm_checker;
};

#endif // LOCALCALENDAR_H
