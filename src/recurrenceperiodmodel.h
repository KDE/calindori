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

#ifndef RECURRENCEPERIODMODEL_H
#define RECURRENCEPERIODMODEL_H

#include <QAbstractListModel>

struct PeriodModelType {
    ushort periodType;
    QString periodTypeDesc;
};

class ReccurencePeriodModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(ushort noRepeat READ noRepeat CONSTANT);
    Q_PROPERTY(ushort repeatYearlyDay READ repeatYearlyDay CONSTANT);
    Q_PROPERTY(ushort repeatYearlyMonth READ repeatYearlyMonth CONSTANT);
    Q_PROPERTY(ushort repeatYearlyPos READ repeatYearlyPos CONSTANT);
    Q_PROPERTY(ushort repeatMonthlyDay READ repeatMonthlyDay CONSTANT);
    Q_PROPERTY(ushort repeatMonthlyPos READ repeatMonthlyPos CONSTANT);
    Q_PROPERTY(ushort repeatWeekly READ repeatWeekly CONSTANT);
    Q_PROPERTY(ushort repeatDaily READ repeatDaily CONSTANT);

public:
    enum RoleNames {
        RepeatDescriptionRole = Qt::UserRole +1,
        RepeatCodeRole
    };

    explicit ReccurencePeriodModel(QObject* parent = nullptr);
    ~ReccurencePeriodModel() override;

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent) const override;

    ushort noRepeat() const;
    ushort repeatYearlyDay() const;
    ushort repeatYearlyMonth() const;
    ushort repeatYearlyPos() const;
    ushort repeatMonthlyDay() const;
    ushort repeatMonthlyPos() const;
    ushort repeatWeekly() const;
    ushort repeatDaily() const;

    Q_INVOKABLE QString periodDecription(const int periodType) const;
    Q_INVOKABLE QString repeatDescription(const int repeatType, const int repeatEvery, const int stopAfter) const;

private:
    void initialize();
    QVector<PeriodModelType> m_periodtypes;
};

#endif
