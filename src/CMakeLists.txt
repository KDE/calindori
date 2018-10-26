
if (NOT STATIC_LIBRARY)
    ecm_create_qm_loader(mobilecalendar_QM_LOADER mobilecalendar_qt)
endif()

set(mobilecalendar_SRCS
    main.cpp
    )

qt5_add_resources(RESOURCES resources.qrc)

# Plugin directory
add_subdirectory(plugins)

add_executable(mobilecalendar ${mobilecalendar_SRCS} ${RESOURCES})
target_link_libraries(mobilecalendar Qt5::Core Qt5::Qml Qt5::Quick Qt5::Test Qt5::Svg KF5::ConfigCore KF5::Plasma)

install(TARGETS mobilecalendar ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})

install(FILES contents/ui/mobilecalendar.svg DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps)
