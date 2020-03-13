/*
 *   Copyright 2018 Dimitris Kardarakos <dimkard@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <QVariant>
#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>

#include "calindoriconfig.h"
#include "todosmodel.h"
#include "localcalendar.h"
#include "eventmodel.h"
#include "eventcontroller.h"
#include "todocontroller.h"
#include "incidencealarmsmodel.h"
#include "daysofmonthmodel.h"
#include "recurrenceperiodmodel.h"
#include "daysofmonthincidencemodel.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    KLocalizedString::setApplicationDomain("calindori");

    KAboutData aboutData(QStringLiteral("calindori"), i18n("Calindori"), QStringLiteral("1.1"), i18nc("@title", "Calendar application"), KAboutLicense::GPL_V3, i18nc("@info:credit", "(c) 2018-2020 The Calindori Team"));

    aboutData.setOrganizationDomain(QByteArray("kde.org"));
    aboutData.setProductName(QByteArray("calindori"));

    aboutData.addAuthor(i18nc("@info:credit", "Dimitris Kardarakos"), i18nc("@info:credit", "Maintainer and Developer"), QStringLiteral("dimkard@posteo.net"));

    aboutData.addAuthor(i18nc("@info:credit", "Nicolas Fella"), i18nc("@info:credit", "Developer"), QStringLiteral("nicolas.fella@gmx.de"));

    aboutData.setHomepage(QStringLiteral("https://invent.kde.org/kde/calindori"));

    KAboutData::setApplicationData(aboutData);

    QCommandLineParser parser;
    aboutData.setupCommandLine(&parser);
    parser.process(app);
    aboutData.processCommandLine(&parser);

    QApplication::setApplicationName(aboutData.componentName());
    QApplication::setApplicationDisplayName(aboutData.displayName());
    QApplication::setOrganizationDomain(aboutData.organizationDomain());
    QApplication::setApplicationVersion(aboutData.version());

    qmlRegisterType<CalindoriConfig>("org.kde.phone.calindori", 0, 1, "CalindoriConfig");
    qmlRegisterType<TodosModel>("org.kde.phone.calindori", 0, 1, "TodosModel");
    qmlRegisterType<LocalCalendar>("org.kde.phone.calindori", 0, 1, "LocalCalendar");
    qmlRegisterType<EventModel>("org.kde.phone.calindori", 0, 1, "EventModel");
    qmlRegisterType<EventController>("org.kde.phone.calindori",0,1,"EventController");
    qmlRegisterType<TodoController>("org.kde.phone.calindori",0,1,"TodoController");
    qmlRegisterType<IncidenceAlarmsModel>("org.kde.phone.calindori",0,1,"IncidenceAlarmsModel");
    qmlRegisterType<DaysOfMonthModel>("org.kde.phone.calindori",0,1,"DaysOfMonthModel");
    qmlRegisterType<ReccurencePeriodModel>("org.kde.phone.calindori",0,1,"ReccurencePeriodModel");
    qmlRegisterType<DaysOfMonthIncidenceModel>("org.kde.phone.calindori",0,1,"DaysOfMonthIncidenceModel");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    TodoController todoController;
    engine.rootContext()->setContextProperty(QStringLiteral("_todoController"), &todoController);

    EventController eventController;
    engine.rootContext()->setContextProperty(QStringLiteral("_eventController"), &eventController);

    ReccurencePeriodModel repeatModel;
    engine.rootContext()->setContextProperty(QStringLiteral("_repeatModel"), &repeatModel);

    CalindoriConfig calindoriConfig;
    engine.rootContext()->setContextProperty(QStringLiteral("_calindoriConfig"), &calindoriConfig);

    engine.rootContext()->setContextProperty(QStringLiteral("_nullDate"), QDateTime());

    engine.rootContext()->setContextProperty(QStringLiteral("_aboutData"), QVariant::fromValue(aboutData));

    engine.load(QUrl(QStringLiteral("qrc:///Main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    int ret = app.exec();
    return ret;


}
