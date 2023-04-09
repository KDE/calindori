# SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
#
# SPDX-License-Identifier: BSD-2-Clause

add_definitions(-DTRANSLATION_DOMAIN=\"calindac\")

set(calindac_SRCS
    calalarmclient.cpp
    calindacmain.cpp
    alarmsmodel.cpp
    alarmnotification.cpp
    notificationhandler.cpp
    solidwakeupbackend.cpp
    wakeupmanager.cpp
    )

qt_add_dbus_adaptor(calindac_SRCS org.kde.calindac.xml calalarmclient.h CalAlarmClient)
qt_add_dbus_adaptor(calindac_SRCS org.kde.wakeupmanager.PowerManagement.xml wakeupmanager.h WakeupManager)

add_executable(calindac ${calindac_SRCS} ${RESOURCES})

target_link_libraries(calindac
    KF${QT_MAJOR_VERSION}::CoreAddons
    KF${QT_MAJOR_VERSION}::ConfigCore
    KF${QT_MAJOR_VERSION}::CalendarCore
    KF${QT_MAJOR_VERSION}::DBusAddons
    KF${QT_MAJOR_VERSION}::Notifications
    KF${QT_MAJOR_VERSION}::I18n
    Qt::DBus
    )

install(TARGETS
    calindac ${KDE_INSTALL_TARGETS_DEFAULT_ARGS}
    )

install(FILES
    org.kde.calindac.desktop
    DESTINATION ${KDE_INSTALL_AUTOSTARTDIR}
    )

install(FILES calindac.notifyrc DESTINATION ${KDE_INSTALL_KNOTIFYRCDIR})

set(SERV_EXEC ${KDE_INSTALL_FULL_BINDIR}/calindac)
configure_file(org.kde.calindac.service.in ${CMAKE_CURRENT_BINARY_DIR}/org.kde.calindac.service)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.kde.calindac.service DESTINATION ${KDE_INSTALL_FULL_DBUSSERVICEDIR})
