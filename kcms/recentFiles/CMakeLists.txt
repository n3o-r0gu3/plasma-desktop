# vim:set softtabstop=3 shiftwidth=3 tabstop=3 expandtab:
add_definitions(-DTRANSLATION_DOMAIN=\"kcm_recentFiles\")

find_package (Qt${QT_MAJOR_VERSION} REQUIRED NO_MODULE COMPONENTS Core Quick Sql Qml DBus)
find_package (KF5KCMUtils ${KF5_DEP_VERSION} CONFIG REQUIRED)
find_package (KF5Declarative ${KF5_DEP_VERSION} CONFIG REQUIRED)
find_package (KF5XmlGui ${KF5_DEP_VERSION} CONFIG REQUIRED)
find_package (KF5GlobalAccel ${KF5_DEP_VERSION} CONFIG REQUIRED)
find_package (KF5Activities ${KF5_DEP_VERSION} CONFIG REQUIRED)

set (KAMD_KCM_DATADIR
   ${KDE_INSTALL_DATADIR_KF5}/kcm_recentFiles/workspace/settings/
   )

if (NOT IS_ABSOLUTE "${KDE_INSTALL_DATADIR_KF5}")
   set (KAMD_KCM_DATADIR "${CMAKE_INSTALL_PREFIX}/${KAMD_KCM_DATADIR}")
endif ()

configure_file (recentFiles-kcm-features.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/recentFiles-kcm-features.h)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set (KAMD_KCM_SRCS
   kcm_recentFiles.cpp

   BlacklistedApplicationsModel.cpp
   )

ki18n_wrap_ui (
   KAMD_KCM_SRCS
   ui/RecentFiles.ui
   )

qt_add_dbus_interface (
   KAMD_KCM_SRCS

   common/dbus/org.kde.ActivityManager.ResourceScoring.xml
   resourcescoring_interface
   )


kcmutils_generate_module_data(
    KAMD_KCM_SRCS
    MODULE_DATA_HEADER kactivitiesdata.h
    MODULE_DATA_CLASS_NAME KActivitiesData
    SETTINGS_HEADERS kactivitymanagerd_settings.h kactivitymanagerd_plugins_settings.h
    SETTINGS_CLASSES KActivityManagerdSettings KActivityManagerdPluginsSettings
)

kconfig_add_kcfg_files(KAMD_KCM_SRCS kactivitymanagerd_settings.kcfgc GENERATE_MOC)
kconfig_add_kcfg_files(KAMD_KCM_SRCS kactivitymanagerd_plugins_settings.kcfgc GENERATE_MOC)

add_library (kcm_recentFiles MODULE ${KAMD_KCM_SRCS})

kcmutils_generate_desktop_file(kcm_recentFiles)
target_link_libraries (kcm_recentFiles
   Qt::Quick
   Qt::QuickWidgets
   Qt::Core
   Qt::Sql
   Qt::Qml
   Qt::DBus
   KF5::KCMUtils
   KF5::I18n
   KF5::Service
   KF5::Declarative
   KF5::XmlGui
   KF5::Activities
   )

install (
   TARGETS kcm_recentFiles
   DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/kcms/systemsettings_qwidgets
   )

install (
   DIRECTORY

   qml/recentFiles

   DESTINATION ${KAMD_KCM_DATADIR}/qml
   )

install(FILES kactivitymanagerd_settings.kcfg DESTINATION ${KDE_INSTALL_KCFGDIR})
install(FILES kactivitymanagerd_plugins_settings.kcfg DESTINATION ${KDE_INSTALL_KCFGDIR})
