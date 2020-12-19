/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef DATAHANDLER_H
#define DATAHANDLER_H

#include <QObject>

class QNetworkAccessManager;
class CalendarController;

class DataHandler : public QObject
{
    Q_OBJECT

public:
    explicit DataHandler(QObject *parent = nullptr);
    ~DataHandler();

    void setCalendarController(CalendarController *calendarController);
    void importFromUrl(const QUrl &url);
    void importData(const QByteArray &data);

    static DataHandler *instance();

private:
    void importLocalFile(const QUrl &url);

    static DataHandler *s_instance;

    QNetworkAccessManager *m_network_manager;
    CalendarController *m_calendar_controller;
};
#endif // DATAHANDLER_H

