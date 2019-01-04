/*
 * Copyright (C) 2018 Dimitris Kardarakos
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

#include "calindoriconfig.h"

#include <KConfig>
#include <KConfigGroup>

class CalindoriConfig::Private
{
public:
    Private()
        : config("calindorirc")
    {};
    KConfig config;
};

CalindoriConfig::CalindoriConfig(QObject* parent)
    : QObject(parent)
    , d(new Private)
{
    QString viewMode = d->config.group("general").readEntry("view_mode", QString());
    if(viewMode.isEmpty()) {
        d->config.sync();
    }
}

CalindoriConfig::~CalindoriConfig()
{
    delete d;
}

QString CalindoriConfig::viewMode() const
{
    QString viewMode = d->config.group("general").readEntry("view_mode", QString());
    return viewMode;
}

void CalindoriConfig::setviewMode(const QString & mode)
{
        d->config.group("general").writeEntry("view_mode", mode);
        d->config.sync();
        emit viewModeChanged();
}

