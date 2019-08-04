
if (NOT STATIC_LIBRARY)
    ecm_create_qm_loader(calindori_QM_LOADER calindori_qt)
endif()

set(calindori_SRCS
    main.cpp
    calindoriconfig.cpp
    todosmodel.cpp
    localcalendar.cpp
    eventmodel.cpp
    eventcontroller.cpp
    todocontroller.cpp
    incidencealarmsmodel.cpp
    daysofmonthmodel.cpp
    recurrenceperiodmodel.cpp
    daysofmonthincidencemodel.cpp
    )

qt5_add_resources(RESOURCES resources.qrc)

add_executable(calindori ${calindori_SRCS} ${RESOURCES})
target_link_libraries(calindori Qt5::Core Qt5::Qml Qt5::Quick Qt5::Test Qt5::Svg KF5::ConfigCore KF5::I18n KF5::CalendarCore)

if(ANDROID)
    kirigami_package_breeze_icons(ICONS
        delete
        dialog-cancel
        dialog-close
        dialog-ok
        document-import
        documentinfo
        editor
        emblem-ok-symbolic
        go-down
        go-next
        go-parent-folder
        go-previous
        go-up
        list-add
        resource-calendar-insert
        tag-events
        text-x-plain
        view-calendar
        view-calendar-day
        view-calendar-tasks
        view-calendar-upcoming-events
        view-choose
        find-location
        media-playlist-repeat
    )
endif()

install(TARGETS calindori ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})

install(FILES contents/ui/calindori.svg DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps)
