/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "calalarmclient.h"
#include <KAboutData>
#include <KDBusService>
#include <KLocalizedString>
#include <QApplication>
#include <QCommandLineParser>

int main(int argc, char **argv)
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    app.setAttribute(Qt::AA_UseHighDpiPixmaps, true);

    KAboutData aboutData(QStringLiteral("calindac"), i18n("Calindori Alarm Check Daemon"),
                         QString(), i18n("Calindori Alarm Check Daemon"),
                         KAboutLicense::GPL,
                         i18n("(c) 2019 Dimitris Kardarakos"),
                         QString(), QStringLiteral("https://invent.kde.org/kde/calindori"));
    aboutData.addAuthor(i18n("Dimitris Kardarakos"), i18n("Maintainer"),
                        QStringLiteral("dimkard@posteo.net"));

    QCommandLineParser parser;
    KAboutData::setApplicationData(aboutData);
    aboutData.setupCommandLine(&parser);
    parser.process(app);
    aboutData.processCommandLine(&parser);

    KDBusService service(KDBusService::Unique);

    CalAlarmClient client;

    return app.exec();
}
