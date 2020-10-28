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

qt5_add_dbus_adaptor(calindac_SRCS org.kde.calindac.xml calalarmclient.h CalAlarmClient)
qt5_add_dbus_adaptor(calindac_SRCS org.kde.wakeupmanager.PowerManagement.xml wakeupmanager.h WakeupManager)

add_executable(calindac ${calindac_SRCS} ${RESOURCES})

target_link_libraries(calindac
    KF5::CalendarCore
    KF5::DBusAddons
    KF5::Notifications
    KF5::Service
    KF5::I18n
    Qt5::DBus
    )

install(TARGETS
    calindac ${KDE_INSTALL_TARGETS_DEFAULT_ARGS}
    )

install(FILES
    org.kde.calindac.desktop
    DESTINATION ${KDE_INSTALL_AUTOSTARTDIR}
    )

install(FILES
    org.kde.calindac.xml
    org.kde.wakeupmanager.PowerManagement.xml
    DESTINATION ${DBUS_INTERFACES_INSTALL_DIR}
    )

install(FILES calindac.notifyrc DESTINATION ${KNOTIFYRC_INSTALL_DIR})

