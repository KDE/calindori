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
// #include <KCalCore/MemoryCalendar>
// #include <KCalCore/FileStorage>
// using namespace KCalCore;


Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName("KDE");
    QCoreApplication::setOrganizationDomain("phone.kde.org");
    QCoreApplication::setApplicationName("Mobile Calendar");

    QQmlApplicationEngine engine;

    if (!(QString::fromLatin1(qgetenv("DESKTOP_SESSION")).isEmpty())) {
        engine.load(QUrl(QStringLiteral("qrc:///desktopmain.qml")));
    }
    else {
        engine.load(QUrl(QStringLiteral("qrc:///mobilemain.qml")));
    }

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }
    
/**     
 * Calendar POC

    QDateTime now = QDateTime::currentDateTime();
    MemoryCalendar::Ptr localCalendar(new MemoryCalendar(QTimeZone::systemTimeZone()));
    QUrl localUrl("./localfile");
    FileStorage storage(localCalendar);
    storage.setFileName(localUrl.path());
 
    bool success = false;
    success = storage.load();
 
    Todo::List todos;
    todos = localCalendar->rawTodos();
    
    int todosCnt = todos.length();
    for(int i = 0; i < todosCnt; ++i) {
        qDebug() << i << ": " << todos.at(i)->summary() ;
    }
    

    Create todos
    Todo::Ptr todo = Todo::Ptr(new Todo());
    QString todoSuffix(now.toString("hhmmsszzz"));
    todo->setUid(QStringLiteral("todo") + todoSuffix);
    todo->setDtStart(QDateTime::currentDateTimeUtc());
    todo->setSummary(QStringLiteral("summary") + todoSuffix);
    localCalendar->addTodo(todo);
    qDebug() << now.toString("hh:mm:ss.zzz") << ": Hello calendar POC";
    success = storage.save();
*/
    int ret = app.exec();
    return ret;


}
