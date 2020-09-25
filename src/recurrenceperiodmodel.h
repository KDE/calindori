/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
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
        RepeatDescriptionRole = Qt::UserRole + 1,
        RepeatCodeRole
    };

    explicit ReccurencePeriodModel(QObject *parent = nullptr);
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
