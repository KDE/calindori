/*
 * Copyright (C) 2019 Dimitris Kardarakos
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 3 of
 * the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#ifndef INCIDENCEALARMSMODEL_H
#define INCIDENCEALARMSMODEL_H

#include <QAbstractListModel>
#include <KCalCore/Alarm>
#include <KCalCore/Duration>
#include <QVariantList>
#include <QVariantMap>
#include <QHash>

class LocalCalendar;
/**
 * @brief Model that serves the alarms of an Incidence set in the input properties
 *
 */
class IncidenceAlarmsModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QVariantMap alarmProperties READ alarmProperties WRITE setAlarmProperties NOTIFY alarmPropertiesChanged)

public:
    explicit IncidenceAlarmsModel(QObject* parent = nullptr);
    ~IncidenceAlarmsModel() override;

    enum RoleNames
    {
        StartOffsetValue = Qt::UserRole+1,
        StartOffsetType,
        ActionType
    };

    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex & parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;

    /**
     * @return A QVariantMap of the input properties
     */
    QVariantMap alarmProperties() const;
    /**
     * @brief Sets the input properties of the model. \p alarmProps should be a QVariantMap with the following members: 1) uid: the uid of the Incidence 2) calendar: the LocalCalendar* that the Incidence belongs to
     */
    void setAlarmProperties(const QVariantMap & alarmProps);

public Q_SLOTS:
    /**
     * @brief Removes an alarm from the model
     */
    void removeAlarm(const int row);
    /**
     * @brief Creates a model item and adds it to the model
     */
    void addAlarm(const int secondsFromStart);
    /**
     * @return A QVariantList of the items of the model. The members of the list are QHash<QString, QVariant> items that contain the following members: startOffsetValue, startOffsetType and actionType
     */
    QVariantList alarms() const;

Q_SIGNALS:
    void alarmPropertiesChanged();

private:
    void loadPersistentAlarms();
    QString alarmText(const int idx) const;
    QString alarmUid(const int idx) const;
    int alarmStartOffsetValue(const int idx) const;
    QString alarmStartOffsetType(const int idx) const;
    int alarmActionType(const int idx) const;
    QString displayText(const int idx) const;

    QVariantList mAlarms;
    QVariantMap mAlarmProperties;
};

#endif
