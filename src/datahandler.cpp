/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 * SPDX-FileCopyrightText: 2018 Volker Krause <vkrause@kde.org>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "datahandler.h"
#include "calendarcontroller.h"
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QStandardPaths>
#include <QFile>
#include <QMimeData>
#include <QMimeDatabase>
#include <QUrl>

DataHandler *DataHandler::s_instance {nullptr};

DataHandler::DataHandler(QObject *parent) : QObject {parent}, m_network_manager {nullptr}, m_calendar_controller {nullptr}
{
    s_instance = this;
}

DataHandler::~DataHandler()
{
    s_instance = nullptr;
}

DataHandler *DataHandler::instance()
{
    return s_instance;
}

void DataHandler::setCalendarController(CalendarController *calendarController)
{
    m_calendar_controller = calendarController;
}

void DataHandler::importFromUrl(const QUrl &url)
{
    if (!url.isValid()) {
        return;
    }

    if (url.isLocalFile() || url.scheme() == QLatin1String("content")) {
        importLocalFile(url);
        return;
    }

    if (url.scheme().startsWith(QLatin1String("http"))) {
        if (m_network_manager == nullptr) {
            m_network_manager = new QNetworkAccessManager {this};
        }

        auto reqUrl {url};
        reqUrl.setScheme(QLatin1String("https"));
        QNetworkRequest req {reqUrl};
        req.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::NoLessSafeRedirectPolicy);
        m_network_manager->get(req);
        connect(m_network_manager, &QNetworkAccessManager::finished, [this](QNetworkReply * reply) {
            if (reply->error() != QNetworkReply::NoError) {
                qDebug() << reply->url() << reply->errorString();
                return;
            }
            importData(reply->readAll());
        });
        return;
    }

    qDebug() << "Unhandled URL type:" << url;
}

void DataHandler::importLocalFile(const QUrl &url)
{
    if (url.isEmpty()) {
        return;
    }

    QFile f(url.isLocalFile() ? url.toLocalFile() : url.toString());

    if (!f.open(QFile::ReadOnly)) {
        qDebug() << "Failed to open" << f.fileName() << f.errorString();
        return;
    }

    if (f.size() > 4000000) {
        qDebug() << "File too large, ignoring" << f.fileName() << f.size();
        return;
    }

    const auto data = f.readAll();

    QMimeDatabase db;
    const auto mt = db.mimeTypeForFileNameAndData(f.fileName(), data);

    if (mt.name() != QLatin1String("text/calendar")) {
        qDebug() << "The file given is not a valid calendar";

        return;
    }

    importData(data);
}

void DataHandler::importData(const QByteArray &data)
{
    if (data.size() < 4) {
        return;
    }

    if (m_calendar_controller != nullptr) {
        m_calendar_controller->importCalendarData(data);
    }
}
