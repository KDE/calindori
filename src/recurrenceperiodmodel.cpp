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

#include "recurrenceperiodmodel.h"
#include <KCalendarCore/Recurrence>
#include <KLocalizedString>

using namespace KCalendarCore;

ReccurencePeriodModel::ReccurencePeriodModel(QObject* parent): QAbstractListModel(parent)
{
    initialize();
}

ReccurencePeriodModel::~ReccurencePeriodModel() = default;

void ReccurencePeriodModel::initialize()
{
    beginResetModel();

    m_periodtypes = {
        {.periodType = Recurrence::rNone, .periodTypeDesc = periodDecription(Recurrence::rNone)},
        {.periodType = Recurrence::rYearlyMonth, .periodTypeDesc = periodDecription(Recurrence::rYearlyMonth)},
        {.periodType = Recurrence::rMonthlyDay, .periodTypeDesc = periodDecription(Recurrence::rMonthlyDay)},
        {.periodType = Recurrence::rWeekly, .periodTypeDesc = periodDecription(Recurrence::rWeekly)},
        {.periodType = Recurrence::rDaily, .periodTypeDesc = periodDecription(Recurrence::rDaily)},
    };

    endResetModel();
}

QHash<int, QByteArray> ReccurencePeriodModel::roleNames() const
{
    return
    {
        {RepeatDescriptionRole, "repeatDescription"},
        {RepeatCodeRole, "repeatCode"}
    };
}

QVariant ReccurencePeriodModel::data(const QModelIndex& index, int role) const
{
    if(!index.isValid())
    {
        return "Invalid index";
    }

    switch(role)
    {
        case Qt::DisplayRole:
            return m_periodtypes.at(index.row()).periodTypeDesc;
        case RepeatDescriptionRole:
            return m_periodtypes.at(index.row()).periodTypeDesc;
        case RepeatCodeRole:
            return m_periodtypes.at(index.row()).periodType;
        default:
            return QStringLiteral();
    }
}

int ReccurencePeriodModel::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid())
    {
        return 0;
    }

    return m_periodtypes.count();
}

ushort ReccurencePeriodModel::noRepeat() const
{
    return Recurrence::rNone;
}

ushort ReccurencePeriodModel::repeatYearlyDay() const
{
    return Recurrence::rYearlyDay;
}

ushort ReccurencePeriodModel::repeatYearlyMonth() const
{
    return Recurrence::rYearlyMonth;
}

ushort ReccurencePeriodModel::repeatYearlyPos() const
{
    return Recurrence::rYearlyPos;
}

ushort ReccurencePeriodModel::repeatMonthlyDay() const
{
    return Recurrence::rMonthlyDay;
}

ushort ReccurencePeriodModel::repeatMonthlyPos() const
{
    return Recurrence::rMonthlyPos;
}

ushort ReccurencePeriodModel::repeatWeekly() const
{
    return Recurrence::rWeekly;
}

ushort ReccurencePeriodModel::repeatDaily() const
{
    return Recurrence::rDaily;
}

QString ReccurencePeriodModel::periodDecription(const int periodType) const
{
    switch(periodType)
    {
        case Recurrence::rNone:
            return i18n("Do not repeat");
        case Recurrence::rYearlyDay:
        case Recurrence::rYearlyMonth:
        case Recurrence::rYearlyPos:
            return i18n("Yearly");
        case Recurrence::rMonthlyDay:
        case Recurrence::rMonthlyPos:
            return i18n("Monthly");
        case Recurrence::rWeekly:
            return i18n("Weekly");
        case Recurrence::rDaily:
            return i18n("Daily");
        default:
            return QString();
    }
}

QString ReccurencePeriodModel::repeatDescription(const int repeatType, const int repeatEvery, const int stopAfter) const
{
    return QString("%1%2").arg((repeatType == Recurrence::rYearlyMonth || repeatType == Recurrence::rYearlyDay || repeatType == Recurrence::rYearlyPos) ? i18np("Every year", "Every %1 years", repeatEvery) :
        (repeatType == Recurrence::rMonthlyPos || repeatType == Recurrence::rMonthlyDay) ? i18np("Every month", "Every %1 months",repeatEvery) :
            (repeatType == Recurrence::rWeekly) ? i18np("Every week", "Every %1 weeks", repeatEvery) :
                (repeatType == Recurrence::rDaily) ? i18np("Every day", "Every %1 days", repeatEvery) : i18n("Never")).arg((repeatType == Recurrence::rNone) || (stopAfter < 1) ? "" : i18np("; once", "; %1 times", stopAfter));
}
