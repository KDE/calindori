/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef INCIDENCEALARMSMODEL_H
#define INCIDENCEALARMSMODEL_H

#include <QAbstractListModel>
#include <KCalendarCore/Alarm>
#include <KCalendarCore/Duration>
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

    enum RoleNames {
        StartOffsetValue = Qt::UserRole + 1,
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
     * @brief Removes all alarms
     */
    void removeAll();

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
