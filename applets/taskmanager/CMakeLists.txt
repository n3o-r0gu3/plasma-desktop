add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_org.kde.plasma.taskmanager\")

plasma_install_package(package org.kde.plasma.taskmanager)

set(taskmanagerplugin_SRCS
    plugin/backend.cpp
    plugin/taskmanagerplugin.cpp

    plugin/smartlaunchers/smartlauncherbackend.cpp
    plugin/smartlaunchers/smartlauncheritem.cpp
)

ecm_qt_declare_logging_category(taskmanagerplugin_SRCS
    HEADER log_settings.h
    IDENTIFIER TASKMANAGER_DEBUG
    CATEGORY_NAME org.kde.plasma.taskmanager)

install(FILES plugin/qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/taskmanager)

add_library(taskmanagerplugin SHARED ${taskmanagerplugin_SRCS})

# FIXME Cleanup no longer used libs.
target_link_libraries(taskmanagerplugin
                      Qt::Core
                      Qt::DBus
                      Qt::Qml
                      Qt::Quick
                      KF5::Activities
                      KF5::ActivitiesStats
                      KF5::I18n
                      KF5::KIOCore
                      KF5::KIOGui
                      KF5::KIOFileWidgets # KFilePlacesModel
                      KF5::Notifications # KNotificationJobUiDelegate
                      KF5::Plasma
                      KSysGuard::ProcessCore
                      KF5::Service
                      KF5::WindowSystem
                      PW::LibNotificationManager)

install(TARGETS taskmanagerplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/taskmanager)
