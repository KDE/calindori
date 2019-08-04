/*
  Copyright (c) 2019 Dimitris Kardarakos <dimkard@posteo.net>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

  As a special exception, permission is given to link this program
  with any edition of Qt, and distribute the resulting executable,
  without including the source code for Qt in the source distribution.
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
