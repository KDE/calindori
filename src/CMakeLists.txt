
if (NOT STATIC_LIBRARY)
    ecm_create_qm_loader(calindori_QM_LOADER calindori_qt)
endif()

set(calindori_SRCS
    main.cpp
    )

qt5_add_resources(RESOURCES resources.qrc)

# Plugin directory
add_subdirectory(plugins)

add_executable(calindori ${calindori_SRCS} ${RESOURCES})
target_link_libraries(calindori Qt5::Core Qt5::Qml Qt5::Quick Qt5::Test Qt5::Svg KF5::ConfigCore KF5::Plasma KF5::I18n)

install(TARGETS calindori ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})

install(FILES contents/ui/calindori.svg DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps)
