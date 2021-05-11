# SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
#
# SPDX-License-Identifier: BSD-2-Clause

cmake_minimum_required(VERSION 3.0)

project(calindori)
set(PROJECT_VERSION "21.05")

set(KF5_MIN_VERSION "5.62.0")
set(QT_MIN_VERSION "5.14.0")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(CTest)
include(FeatureSummary)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMPoQmTools)
include(ECMSetupVersion)

ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX CALINDORI
    VERSION_HEADER ${CMAKE_CURRENT_BINARY_DIR}/version.h
)

find_package(Qt5 ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    DBus
    Svg
    Network
)
if (BUILD_TESTING)
    find_package(Qt5 ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS Test)
endif()

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
    Config
    Kirigami2
    I18n
    CoreAddons
    CalendarCore
    DBusAddons
    Notifications
    People
)

add_subdirectory(src)
add_subdirectory(icons)
add_subdirectory(calindac)

if (IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/po")
    ki18n_install(po)
endif()

install(FILES org.kde.calindori.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
install(PROGRAMS org.kde.calindori.desktop DESTINATION ${KDE_INSTALL_APPDIR})

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

