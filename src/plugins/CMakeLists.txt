set(qmlplugin_SRCS
    qmlplugin.cpp
    MobileCalendarConfig.cpp
)

add_library (mobilecalendarqmlplugin SHARED ${qmlplugin_SRCS})


target_link_libraries (mobilecalendarqmlplugin
    Qt5::Core
    Qt5::Qml
    Qt5::Quick
    KF5::ConfigCore
)

install (TARGETS mobilecalendarqmlplugin DESTINATION ${QML_INSTALL_DIR}/org/kde/phone/mobilecalendar)
install (FILES qmldir DESTINATION ${QML_INSTALL_DIR}/org/kde/phone/mobilecalendar)
