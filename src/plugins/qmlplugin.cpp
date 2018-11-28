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

#include "qmlplugin.h"

#include "mobilecalendarconfig.h"
#include "localcalendar.h"
#include "todosmodel.h"
#include <QQmlEngine>
#include <QtQml/qqml.h>


void QmlPlugins::registerTypes(const char *uri)
{
    qmlRegisterType<MobileCalendarConfig>(uri, 0, 1, "Config");
    qmlRegisterType<TodosModel>(uri, 0, 1, "TodosModel");
    qmlRegisterType<LocalCalendar>(uri, 0, 1, "LocalCalendar");
}
