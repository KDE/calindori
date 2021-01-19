/*
 * SPDX-FileCopyrightText: 2021 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef ATTENDEES_MODEL_H
#define ATTENDEES_MODEL_H

#include <QAbstractListModel>
#include <QVariantList>
#include <KCalendarCore/Attendee>

class LocalCalendar;

/**
 * @brief Model that serves the attendees of an Incidence
 *
 */
class AttendeesModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QString uid READ uid WRITE setUid NOTIFY uidChanged)
    Q_PROPERTY(LocalCalendar *calendar READ calendar WRITE setCalendar NOTIFY calendarChanged)
public:
    explicit AttendeesModel(QObject *parent = nullptr);

    enum RoleNames {
        Email = Qt::UserRole + 1,
        FullName,
        Name,
        ParticipationStatus,
        ParticipationStatusIcon,
        ParticipationStatusDisplay,
        AttendeeRole
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString uid() const;
    void setUid(const QString &uid);

    LocalCalendar *calendar() const;
    void setCalendar(LocalCalendar *calendarPtr);

    Q_INVOKABLE void removeItem(const int row);
    Q_INVOKABLE void addPersons(const QStringList uris);
    Q_INVOKABLE QStringList emails() const;
    Q_INVOKABLE QVariantList attendees() const;

Q_SIGNALS:
    void uidChanged();
    void calendarChanged();

public Q_SLOTS:
    void loadPersistentData();

private:
    QString m_uid;
    LocalCalendar *m_calendar;
    KCalendarCore::Attendee::List m_attendees;

    QString statusIcon(const int row) const;
    QString displayStatus(const int row) const;
};
#endif
