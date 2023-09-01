#!/usr/bin/env bash

# Copy pre-build binaries for ubuntu
if [[ $(lsb_release -rs) == "20.04" ]]; then
    cp addons/mavsdk/bin/libmavsdk_binding_debug_2004.so addons/mavsdk/bin/libmavsdk_binding_debug.so
    cp addons/mavsdk/bin/libmavsdk_binding_release_2004.so addons/mavsdk/bin/libmavsdk_binding_release.so
    cp addons/ros2dds/bin/libros2dds_binding_debug_2004.so addons/ros2dds/bin/libros2dds_binding_debug.so
    cp addons/ros2dds/bin/libros2dds_binding_release_2004.so addons/ros2dds/bin/libros2dds_binding_release.so
    cp addons/serial/bin/libserial_binding_debug_2004.so addons/serial/bin/libserial_binding_debug.so
    cp addons/serial/bin/libserial_binding_release_2004.so addons/serial/bin/libserial_binding_release.so
elif [[ $(lsb_release -rs) == "22.04" ]]; then
    cp addons/mavsdk/bin/libmavsdk_binding_debug_2204.so addons/mavsdk/bin/libmavsdk_binding_debug.so
    cp addons/mavsdk/bin/libmavsdk_binding_release_2204.so addons/mavsdk/bin/libmavsdk_binding_release.so
    cp addons/ros2dds/bin/libros2dds_binding_debug_2204.so addons/ros2dds/bin/libros2dds_binding_debug.so
    cp addons/ros2dds/bin/libros2dds_binding_release_2204.so addons/ros2dds/bin/libros2dds_binding_release.so
    cp addons/serial/bin/libserial_binding_debug_2204.so addons/serial/bin/libserial_binding_debug.so
    cp addons/serial/bin/libserial_binding_release_2204.so addons/serial/bin/libserial_binding_release.so
else
    echo "Non-compatible version"
fi