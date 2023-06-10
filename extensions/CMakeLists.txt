cmake_minimum_required(VERSION 3.15)
project(GoMavSimulator)
include(ExternalProject)
SET(CMAKE_BUILD_TYPE Release CACHE STRING "Enforce Release Build" FORCE)

# ===================================================== #
# ====================== Options ====================== #
# ===================================================== #

option(ROS2_DDS         "build ros2-dds libraries (foonathan-memory, fast-cdr, fast-dds ...)"   ON)
option(MAVSDK           "build mavsdk library"                                                  ON)

set(FOONATHAN_MEMORY_VERSION "v0.7-3" CACHE STRING "version of foonathan_memory(https://github.com/foonathan/memory.git)")
set(FAST_CDR_VERSION "v1.0.27" CACHE STRING "version of Fast-CDR(https://github.com/eProsima/Fast-CDR.git)")
set(FAST_DDS_VERSION "v2.10.1" CACHE STRING "version of Fast-DDS(https://github.com/eProsima/Fast-DDS.git)")
# MAVSDK original repository(https://github.com/mavlink/MAVSDK) has minor bug on windows, so used forked version. 
set(MAVSDK_VERSION "v1.4.14-fix" CACHE STRING "version of MAVSDK(https://github.com/timetravelCat/MAVSDK)")

# ====================================================== # 
# ================= dependency check =================== #
# ====================================================== #
find_package(TinyXML2 REQUIRED)

if(MAVSDK)
    if(WIN32)
        # MAVSDK requires CURL. you need to set manually for windows. 
        set(CURL_INCLUDE_DIRS "C:/ProgramData/chocolatey/lib/curl/tools/curl-8.1.2_1-win64-mingw/include" CACHE STRING "CURL INCLUDE PATH")
        set(CURL_LIBRARIES "C:/ProgramData/chocolatey/lib/curl/tools/curl-8.1.2_1-win64-mingw/lib/libcurl.a" CACHE STRING "CURL LIBRARY PATH")
    else()
        find_package(CURL REQUIRED)
    endif()
endif()

if(WIN32 AND ROS2_DDS)
    SET(OPENSSL_MSVC_STATIC_RT OFF CACHE BOOL "OpenSSL RT option" FORCE)
endif()

if(ROS2_DDS)
    find_package(OpenSSL REQUIRED)
endif()

# ======================================================= #
# ============== Mandatory configurations =============== #
# ======================================================= #

if(WIN32)
    cmake_policy(SET CMP0091 NEW)
    set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded$<$<CONFIG:Debug>:Debug>DLL)
endif()

if(MAVSDK)
    add_subdirectory(mavsdk)
endif()

if(ROS2_DDS)
    add_subdirectory(ros2dds)
endif()
