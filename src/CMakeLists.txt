# SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
#
# SPDX-License-Identifier: BSD-2-Clause

qt_add_resources(RESOURCES resources.qrc)

add_executable(calindori
    main.cpp
    calindoriconfig.cpp
    localcalendar.cpp
    incidencealarmsmodel.cpp
    daysofmonthmodel.cpp
    recurrenceperiodmodel.cpp
    daysofmonthincidencemodel.cpp
    incidencemodel.cpp
    alarmchecker.cpp
    datahandler.cpp
    calendarcontroller.cpp
    attendeesmodel.cpp
    ${RESOURCES}
)

target_link_libraries(calindori 
    Qt::Core
    Qt::Qml
    Qt::Quick
    Qt::Svg
    Qt::Network
    Qt::QuickControls2
    KF${QT_MAJOR_VERSION}::ConfigCore 
    KF${QT_MAJOR_VERSION}::I18n 
    KF${QT_MAJOR_VERSION}::CalendarCore 
    KF${QT_MAJOR_VERSION}::CoreAddons 
    KF${QT_MAJOR_VERSION}::People
)
if (BUILD_TESTING)
    target_link_libraries(calindori Qt::Test)
endif()

target_include_directories(calindori PRIVATE ${CMAKE_BINARY_DIR})

if(ANDROID)
    kirigami_package_breeze_icons(ICONS
    appointment-reminder
    calindori
    contact-new-symbolic
    delete
    dialog-cancel
    dialog-ok
    document-edit
    document-import
    document-export
    edit-clear-all
    edit-entry
    editor
    go-down
    go-next
    go-previous
    go-up
    gps
    help-about-symbolic
    hide_table_row
    list-add
    media-playlist-repeat
    meeting-attending
    meeting-attending-tentative
    meeting-participant-no-response
    meeting-participant-request-response
    meeting-organizer
    object-select-symbolic
    remove
    resource-calendar-child-insert
    resource-calendar-insert
    settings-configure
    show_table_row
    tag-events
    user
    view-calendar
    view-calendar-day
    view-calendar-tasks
    view-calendar-timeline
    view-choose
    window-close-symbolic
)
else()
    target_link_libraries(calindori Qt::Widgets Qt::DBus KF${QT_MAJOR_VERSION}::DBusAddons)
endif()

install(TARGETS calindori ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
