/*
 * SPDX-FileCopyrightText: 2021 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "attendeesmodel.h"
#include "localcalendar.h"
#include <KLocalizedString>
#include <KPeople/PersonData>

#include "calendarcontroller.h"

AttendeesModel::AttendeesModel(QObject *parent) : QAbstractListModel {parent}, m_attendees {KCalendarCore::Attendee::List {}}
{
    connect(this, &AttendeesModel::uidChanged, this, &AttendeesModel::loadPersistentData);
}

QHash<int, QByteArray> AttendeesModel::roleNames() const
{
    return {
        {Email, "email"},
        {FullName, "fullName"},
        {Name, "name"},
        {ParticipationStatus, "status"},
        {ParticipationStatusIcon, "statusIcon"},
        {ParticipationStatusDisplay, "displayStatus"},
        {AttendeeRole, "attendeeRole"}
    };
}

QString AttendeesModel::uid() const
{
    return m_uid;
}

void AttendeesModel::setUid(const QString &uid)
{
    if (m_uid != uid) {
        m_uid = uid;

        Q_EMIT uidChanged();
    }
}

QVariant AttendeesModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant {};
    }

    auto row = index.row();

    switch (role) {
    case Email:
        return m_attendees.at(row).email();
    case FullName:
        return m_attendees.at(row).fullName();
    case Name:
        return m_attendees.at(row).name();
    case ParticipationStatus:
        return m_attendees.at(row).status();
    case AttendeeRole:
        return m_attendees.at(row).role();
    case ParticipationStatusIcon:
        return statusIcon(row);
    case ParticipationStatusDisplay:
        return displayStatus(row);
    default:
        return QVariant {};
    }
}

int AttendeesModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_attendees.count();
}

void AttendeesModel::loadPersistentData()
{
    beginResetModel();

    KCalendarCore::Incidence::Ptr incidence;
    KCalendarCore::Calendar::Ptr calendar;

    m_attendees.clear();
    if (!m_uid.isEmpty()) {
        incidence = CalendarController::instance().activeCalendar()->calendar()->incidence(m_uid);
        if (incidence != nullptr) {
            m_attendees = incidence->attendees();
        }
    }

    endResetModel();
}

void AttendeesModel::removeItem(const int row)
{
    beginRemoveRows(QModelIndex(), row, row);

    m_attendees.removeAt(row);

    endRemoveRows();
}

void AttendeesModel::addPersons(const QStringList uris)
{
    if (uris.isEmpty()) {
        return;
    }

    beginResetModel();

    for (const auto &uri : qAsConst(uris)) {
        KPeople::PersonData person {uri, this};
        m_attendees.append({person.name(), person.email(), true});
    }

    endResetModel();
}

QStringList AttendeesModel::emails() const
{
    QStringList emails {};

    for (const auto &a : qAsConst(m_attendees)) {
        emails.append(a.email());
    }

    return emails;
}

QVariantList AttendeesModel::attendees() const
{
    QVariantList l {};
    for (const auto &a : m_attendees) {
        l.append(QVariant::fromValue(a));
    }

    return l;
}

bool AttendeesModel::setData(const QModelIndex &idx, const QVariant &value, int role)
{
    if (role == AttendeeRole) {
        m_attendees[idx.row()].setRole(value.value<KCalendarCore::Attendee::Role>());
        auto m = idx.model();

        Q_EMIT dataChanged(m->index(0, 0), m->index(m->rowCount() - 1, 0), {AttendeeRole});

        return true;
    }

    return false;
}

QString AttendeesModel::statusIcon(const int row) const
{
    switch (m_attendees.at(row).status()) {
    case KCalendarCore::Attendee::PartStat::Accepted: {
        return "meeting-attending";
    }
    case KCalendarCore::Attendee::PartStat::Tentative: {
        return "meeting-attending-tentative";
    }
    case KCalendarCore::Attendee::PartStat::Declined: {
        return "meeting-participant-no-response";
    }
    default: {
        return "meeting-participant-request-response";
    }
    }
}

QString AttendeesModel::displayStatus(const int row) const
{
    switch (m_attendees.at(row).status()) {
    case KCalendarCore::Attendee::PartStat::Accepted: {
        return i18n("Accepted");
    }
    case KCalendarCore::Attendee::PartStat::Tentative: {
        return i18n("Tentative");
    }
    case KCalendarCore::Attendee::PartStat::Declined: {
        return i18n("Declined");
    }
    case KCalendarCore::Attendee::PartStat::Delegated: {
        return i18n("Delegated");
    }
    default: {
        return i18n("Not responded yet");
    }
    }
}
