/*
 * SPDX-FileCopyrightText: 2018 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
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
#include "localcalendar.h"
#include "eventcontroller.h"
#include "todocontroller.h"
#include "incidencealarmsmodel.h"
#include "daysofmonthmodel.h"
#include "recurrenceperiodmodel.h"
#include "daysofmonthincidencemodel.h"
#include "incidencemodel.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    KLocalizedString::setApplicationDomain("calindori");

    KAboutData aboutData(QStringLiteral("calindori"), i18n("Calindori"), QStringLiteral("1.2.90"), i18nc("@title", "Calendar application"), KAboutLicense::GPL_V3, i18nc("@info:credit", "(c) 2018-2020 The Calindori Team"));

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

    qmlRegisterType<CalindoriConfig>("org.kde.calindori", 0, 1, "CalindoriConfig");
    qmlRegisterType<LocalCalendar>("org.kde.calindori", 0, 1, "LocalCalendar");
    qmlRegisterType<EventController>("org.kde.calindori", 0, 1, "EventController");
    qmlRegisterType<TodoController>("org.kde.calindori", 0, 1, "TodoController");
    qmlRegisterType<IncidenceAlarmsModel>("org.kde.calindori", 0, 1, "IncidenceAlarmsModel");
    qmlRegisterType<DaysOfMonthModel>("org.kde.calindori", 0, 1, "DaysOfMonthModel");
    qmlRegisterType<ReccurencePeriodModel>("org.kde.calindori", 0, 1, "ReccurencePeriodModel");
    qmlRegisterType<DaysOfMonthIncidenceModel>("org.kde.calindori", 0, 1, "DaysOfMonthIncidenceModel");
    qmlRegisterType<IncidenceModel>("org.kde.calindori", 0, 1, "IncidenceModel");

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

    engine.rootContext()->setContextProperty(QStringLiteral("_aboutData"), QVariant::fromValue(aboutData));

    engine.load(QUrl(QStringLiteral("qrc:///Main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    int ret = app.exec();
    return ret;
}
