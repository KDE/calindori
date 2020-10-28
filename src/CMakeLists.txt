# SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
#
# SPDX-License-Identifier: BSD-2-Clause

if (NOT STATIC_LIBRARY)
    ecm_create_qm_loader(calindori_QM_LOADER calindori_qt)
endif()

set(calindori_SRCS
    main.cpp
    calindoriconfig.cpp
    localcalendar.cpp
    eventcontroller.cpp
    todocontroller.cpp
    incidencealarmsmodel.cpp
    daysofmonthmodel.cpp
    recurrenceperiodmodel.cpp
    daysofmonthincidencemodel.cpp
    incidencemodel.cpp
    alarmchecker.cpp
    )

qt5_add_resources(RESOURCES resources.qrc)

add_executable(calindori ${calindori_SRCS} ${RESOURCES})
target_link_libraries(calindori Qt5::Core Qt5::Qml Qt5::Quick Qt5::Test Qt5::Svg Qt5::DBus KF5::ConfigCore KF5::I18n KF5::CalendarCore KF5::CoreAddons)


if(ANDROID)
    kirigami_package_breeze_icons(ICONS
        delete
        dialog-cancel
        dialog-close
        document-edit-symbolic
        documentinfo
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
        help-about-symbolic
        list-add
        resource-calendar-insert
        tag-events
        text-x-plain
        view-calendar
        view-calendar-day
        view-calendar-tasks
        view-calendar-upcoming-events
        view-calendar-timeline
        view-choose
        find-location
        media-playlist-repeat
        settings-configure
        gps
        edit-clear-all
        window-close-symbolic
        resource-calendar-child-insert
        show_table_row
        hide_table_row
    )
endif()

install(TARGETS calindori ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})
