add_definitions(-DTRANSLATION_DOMAIN=\"calindac\")

set(calindac_SRCS
    calalarmclient.cpp
    )

set(calindac_SRCS ${calindac_SRCS} calindacmain.cpp)

set(calindac_SRCS
    ${calindac_SRCS}
    alarmsmodel.cpp
    alarmnotification.cpp
    notificationhandler.cpp
    )

qt5_add_dbus_adaptor(calindac_SRCS org.kde.phone.calindac.xml calalarmclient.h CalAlarmClient)

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
    org.kde.phone.calindac.desktop
    DESTINATION ${KDE_INSTALL_AUTOSTARTDIR}
    )


install(FILES
    org.kde.phone.calindac.xml
    DESTINATION ${DBUS_INTERFACES_INSTALL_DIR}
    )

install(FILES calindac.notifyrc DESTINATION ${KNOTIFYRC_INSTALL_DIR})

