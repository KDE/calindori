/*
 * SPDX-FileCopyrightText: 2018 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <QDir>
#include <QDebug>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <QVariant>
#include <QWindow>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <KCalendarCore/Incidence>
#include <KCalendarCore/Attendee>
#ifndef Q_OS_ANDROID
#include <KDBusService>
#endif
#include "calindoriconfig.h"
#include "localcalendar.h"
#include "incidencealarmsmodel.h"
#include "daysofmonthmodel.h"
#include "recurrenceperiodmodel.h"
#include "daysofmonthincidencemodel.h"
#include "incidencemodel.h"
#include "datahandler.h"
#include "calendarcontroller.h"
#include "attendeesmodel.h"
#include "version.h"

void handleArgument(DataHandler *dataHandler, const QStringList &args)
{
    if (!args.isEmpty()) {
        const auto file = args.constFirst();
        const auto localUrl = QUrl::fromLocalFile(file);
        if (QFile::exists(localUrl.toLocalFile())) {
            dataHandler->importFromUrl(localUrl);
        } else {
            dataHandler->importFromUrl(QUrl::fromUserInput(file));
        }
    }
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
#else
    QApplication app(argc, argv);
#endif
    KLocalizedString::setApplicationDomain("calindori");

    KAboutData aboutData(QStringLiteral("calindori"), i18n("Calindori"), QStringLiteral(CALINDORI_VERSION_STRING), i18nc("@title", "Calendar application"), KAboutLicense::GPL_V3, i18nc("@info:credit", "(c) 2018-2021 The Calindori Team"));

    aboutData.setOrganizationDomain(QByteArray("kde.org"));
    aboutData.setProductName(QByteArray("calindori"));

    aboutData.addAuthor(i18nc("@info:credit", "Dimitris Kardarakos"), i18nc("@info:credit", "Developer"), QStringLiteral("dimkard@posteo.net"));

    aboutData.addAuthor(i18nc("@info:credit", "Nicolas Fella"), i18nc("@info:credit", "Developer"), QStringLiteral("nicolas.fella@gmx.de"));

    aboutData.setHomepage(QStringLiteral("https://invent.kde.org/kde/calindori"));

    KAboutData::setApplicationData(aboutData);

    QCommandLineParser parser;
    aboutData.setupCommandLine(&parser);
    parser.process(app);
    aboutData.processCommandLine(&parser);

#ifndef Q_OS_ANDROID
    KDBusService service(KDBusService::Unique);
#endif

    QGuiApplication::setApplicationName(aboutData.componentName());
    QGuiApplication::setApplicationDisplayName(aboutData.displayName());
    QGuiApplication::setOrganizationDomain(aboutData.organizationDomain());
    QGuiApplication::setApplicationVersion(aboutData.version());

    qmlRegisterType<LocalCalendar>("org.kde.calindori", 0, 1, "LocalCalendar");
    qmlRegisterType<IncidenceAlarmsModel>("org.kde.calindori", 0, 1, "IncidenceAlarmsModel");
    qmlRegisterType<DaysOfMonthModel>("org.kde.calindori", 0, 1, "DaysOfMonthModel");
    qmlRegisterType<ReccurencePeriodModel>("org.kde.calindori", 0, 1, "ReccurencePeriodModel");
    qmlRegisterType<DaysOfMonthIncidenceModel>("org.kde.calindori", 0, 1, "DaysOfMonthIncidenceModel");
    qmlRegisterType<IncidenceModel>("org.kde.calindori", 0, 1, "IncidenceModel");
    qmlRegisterType<AttendeesModel>("org.kde.calindori", 0, 1, "AttendeesModel");
    qmlRegisterUncreatableType<KCalendarCore::Incidence>("org.kde.calindori", 0, 1, "CalendarIncidence", "Use Enums");
    qmlRegisterUncreatableType<KCalendarCore::Attendee>("org.kde.calindori", 0, 1, "CalendarAttendee", "Use Enums");

    qmlRegisterSingletonType<DataHandler>("org.kde.calindori", 0, 1, "DataHandler", [](QQmlEngine * engine, QJSEngine *) -> QObject* {
        auto instance = DataHandler::instance();
        engine->setObjectOwnership(instance, QQmlEngine::CppOwnership);

        return instance;
    });

    qmlRegisterSingletonInstance("org.kde.calindori", 0, 1, "CalindoriConfig", &CalindoriConfig::instance());
    qmlRegisterSingletonInstance("org.kde.calindori", 0, 1, "CalendarController", &CalendarController::instance());

    DataHandler dataHandler;

#ifndef Q_OS_ANDROID
    QObject::connect(&service, &KDBusService::activateRequested, [&parser, &dataHandler](const QStringList & args, const QString & workingDir) {
        qDebug() << "remote activation" << args << workingDir;
        if (!args.isEmpty()) {
            QDir::setCurrent(workingDir);
            parser.parse(args);
            handleArgument(&dataHandler, parser.positionalArguments());
        }
        if (!QGuiApplication::allWindows().isEmpty()) {
            QGuiApplication::allWindows().at(0)->requestActivate();
        }
    });
#endif

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    ReccurencePeriodModel repeatModel;
    engine.rootContext()->setContextProperty(QStringLiteral("_repeatModel"), &repeatModel);

    engine.rootContext()->setContextProperty(QStringLiteral("_aboutData"), QVariant::fromValue(aboutData));
    engine.rootContext()->setContextProperty(QStringLiteral("_appLocale"), QLocale::system());

    engine.load(QUrl(QStringLiteral("qrc:///Main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    handleArgument(&dataHandler, parser.positionalArguments());

    int ret = app.exec();
    return ret;
}
