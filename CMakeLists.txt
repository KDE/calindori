# SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
#
# SPDX-License-Identifier: BSD-2-Clause

cmake_minimum_required(VERSION 3.0)

project(calindori VERSION "1.2.90")

set(KF5_MIN_VERSION "5.62.0")
set(QT_MIN_VERSION "5.14.0")

################# Disallow in-source build #################

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
   message(FATAL_ERROR "Calindori requires an out of source build. Please create a separate build directory.")
endif()

include(FeatureSummary)

################# set KDE specific information #################

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMPoQmTools)

find_package(Qt5 ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS DBus Core Quick Gui Svg Test Qml QuickControls2)

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
    Config
    Kirigami2
    I18n
    CoreAddons
    CalendarCore
)

find_package(KF5DBusAddons CONFIG REQUIRED)
find_package(KF5Notifications CONFIG REQUIRED)
find_package(KF5Service CONFIG REQUIRED)

################# Enable C++11 features for clang and gcc #################

if(UNIX)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++0x")
endif()

################# now find all used packages #################

find_package(PkgConfig)
#########################################################################

add_subdirectory(src)
add_subdirectory(icons)
add_subdirectory(calindac)

if (IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/po")
    ecm_install_po_files_as_qm(po)
endif()

install(FILES org.kde.calindori.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
install(PROGRAMS org.kde.calindori.desktop DESTINATION ${KDE_INSTALL_APPDIR})

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

