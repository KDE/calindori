set(qmlplugin_SRCS
    qmlplugin.cpp
    calindoriconfig.cpp
    todosmodel.cpp
    localcalendar.cpp
)

add_library (calindoriqmlplugin SHARED ${qmlplugin_SRCS})


target_link_libraries (calindoriqmlplugin
    Qt5::Core
    Qt5::Qml
    Qt5::Quick
    KF5::ConfigCore
    KF5::CalendarCore
)

install (TARGETS calindoriqmlplugin DESTINATION ${QML_INSTALL_DIR}/org/kde/phone/calindori)
install (FILES qmldir DESTINATION ${QML_INSTALL_DIR}/org/kde/phone/calindori)
