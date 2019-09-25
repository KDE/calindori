/*
  Copyright (c) 2019 Dimitris Kardarakos <dimkard@posteo.net>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

  As a special exception, permission is given to link this program
  with any edition of Qt, and distribute the resulting executable,
  without including the source code for Qt in the source distribution.
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
    enum Roles
    {
        Uid = Qt::UserRole+1,
        Time,
        Text,
        IncidenceStartDt
    };

    explicit AlarmsModel(QObject *parent = nullptr);
    ~AlarmsModel() override;

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex & parent = QModelIndex()) const override;

    /**
     * @return A QHash< QString, QVariant > of the input parameters of the model
     */
    QHash<QString, QVariant> params() const;
    /**
     * @brief Sets the input parameters for the model to be populated
     *
     * @param parameters A QHash< QString, QVariant > that should contain two members: 1) calendarFiles: a QStringList of the calendar files 2) period: a QVariantMap that represents the time period. This QVariantMap expects two QDateTimes (from, to)
     */
    void setParams(const QHash<QString, QVariant> & parameters);


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
