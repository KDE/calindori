/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef ALARMSMODEL_H
#define ALARMSMODEL_H

#include <QAbstractListModel>
#include <KCalendarCore/Alarm>
#include <KCalendarCore/MemoryCalendar>
#include <KCalendarCore/FileStorage>
#include <QVariantMap>

using namespace KCalendarCore;

/**
 * @brief Model that serves the alarms found in a set of calendar files for a specific time period, as set in the model input parameters
 *
 */
class AlarmsModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QHash<QString, QVariant> params READ params WRITE setParams NOTIFY paramsChanged);
public:
    enum Roles {
        Uid = Qt::UserRole + 1,
        Time,
        Text,
        IncidenceStartDt
    };

    explicit AlarmsModel(QObject *parent = nullptr);
    ~AlarmsModel() override;

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    /**
     * @return A QHash< QString, QVariant > of the input parameters of the model
     */
    QHash<QString, QVariant> params() const;
    /**
     * @brief Sets the input parameters for the model to be populated
     *
     * @param parameters A QHash< QString, QVariant > that should contain two members: 1) calendarFiles: a QStringList of the calendar files 2) period: a QVariantMap that represents the time period. This QVariantMap expects two QDateTimes (from, to)
     */
    void setParams(const QHash<QString, QVariant> &parameters);

Q_SIGNALS:
    void periodChanged();
    void calendarFilesChanged();
    void uidsChanged();
    void paramsChanged();

private:
    void loadAlarms();
    void setCalendars();
    void openLoadStorages();
    void closeStorages();
    QDateTime parentStartDt(const int idx) const;

    QVariantMap mPeriod;
    QVector<MemoryCalendar::Ptr> mMemoryCalendars;
    QVector<FileStorage::Ptr> mFileStorages;
    Alarm::List mAlarms;
    QStringList mCalendarFiles;
    QHash<QString, QVariant> mParams;
};
#endif
