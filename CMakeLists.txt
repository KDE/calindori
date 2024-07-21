# SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
#
# SPDX-License-Identifier: BSD-2-Clause

cmake_minimum_required(VERSION 3.16)

# KDE Applications version, managed by release script.
set(RELEASE_SERVICE_VERSION_MAJOR "24")
set(RELEASE_SERVICE_VERSION_MINOR "07")
set(RELEASE_SERVICE_VERSION_MICRO "80")
set(RELEASE_SERVICE_VERSION "${RELEASE_SERVICE_VERSION_MAJOR}.${RELEASE_SERVICE_VERSION_MINOR}.${RELEASE_SERVICE_VERSION_MICRO}")

project(calindori VERSION ${RELEASE_SERVICE_VERSION})

set(KF_MIN_VERSION "5.240.0")
set(QT_MIN_VERSION "6.5.0")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(ECM ${KF_MIN_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(CTest)
include(FeatureSummary)
include(ECMSetupVersion)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEClangFormat)
include(KDEGitCommitHooks)
include(ECMPoQmTools)
include(ECMConfiguredInstall)
include(ECMAddAndroidApk)

ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX CALINDORI
    VERSION_HEADER ${CMAKE_CURRENT_BINARY_DIR}/version.h
)

find_package(Qt6 ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    Svg
    Network
)

if (BUILD_TESTING)
    find_package(Qt6 ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS Test)
endif()

find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS
    Config
    Kirigami2
    I18n
    CoreAddons
    CalendarCore
    Notifications
    People
)

if(NOT ANDROID)
    find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS DBus)
    find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS DBusAddons)
endif()

add_subdirectory(src)
add_subdirectory(icons)

if(NOT ANDROID)
    add_subdirectory(calindac)
endif()

if (IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/po")
    ki18n_install(po)
endif()

install(FILES org.kde.calindori.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
install(PROGRAMS org.kde.calindori.desktop DESTINATION ${KDE_INSTALL_APPDIR})

ecm_add_android_apk(calindori ANDROID_DIR ${CMAKE_CURRENT_SOURCE_DIR})

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

