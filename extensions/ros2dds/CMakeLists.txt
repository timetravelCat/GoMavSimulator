# option(ROS2_IDL_TOOL    "build fast-dds-gen for new idl generation"                             OFF)
# option(IDL_GENERATION   "generate idls after ROS2_IDL_TOOL enabled"                             OFF)

# Windows SDK
if(WIN32)
    include(cmake/FindWindowsSDK.cmake)
    if(NOT WINDOWSSDK_FOUND)
        message(FATAL_ERROR "WINDOWS SDK NOT FOUND")
    endif()
    set(SHLWAPI_TARGET ShLwApi)
    set(SHLWAPI_LIB_DIR ${WINDOWSSDK_LATEST_DIR}/Lib/${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION}/um/x64)
    message("${SHLWAPI_LIB_DIR}")
else()
    set(SHLWAPI_TARGET rt)
endif()

# OpenSSL
get_property(OPENSSL_SSL_PATH TARGET OpenSSL::SSL PROPERTY LOCATION)
get_property(OPENSSL_CRYPTO_PATH TARGET OpenSSL::Crypto PROPERTY LOCATION)
get_filename_component(OPENSSL_SSL_DIR ${OPENSSL_SSL_PATH} DIRECTORY)
get_filename_component(OPENSSL_CRYPTO_DIR ${OPENSSL_CRYPTO_PATH} DIRECTORY)

if(WIN32)
    set(OPENSSL_SSL_TARGET libssl64MD)
    set(OPENSSL_CRYPTO_TARGET libcrypto64MD)
else()
    set(OPENSSL_SSL_TARGET ssl)
    set(OPENSSL_CRYPTO_TARGET crypto)
endif()

# TinyXML2
ExternalProject_Add(tinyxml2u # added suffix u (due to same target exists in mavsdk)
GIT_REPOSITORY https://github.com/leethomason/tinyxml2.git
GIT_TAG        9.0.0
CMAKE_ARGS
    -DCMAKE_POLICY_DEFAULT_CMP0091:STRING=NEW 
    -DCMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreaded$<$<CONFIG:Debug>:Debug>DLL
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
CMAKE_CACHE_ARGS  
    -DCMAKE_INSTALL_PREFIX:PATH=install
    -DCMAKE_BUILD_TYPE:STRING=Release
    -DBUILD_TESTING:BOOL=OFF
    -Dtinyxml2_BUILD_TESTING:BOOL=OFF
    -DBUILD_SHARED_LIBS:BOOL=OFF
BUILD_COMMAND  ${CMAKE_COMMAND} --build <BINARY_DIR> --config Release
INSTALL_COMMAND  ${CMAKE_COMMAND} --install <BINARY_DIR> --config Release
)

set(TINYXML2_LIB_DIR ${CMAKE_BINARY_DIR}/ros2dds/tinyxml2u-prefix/src/tinyxml2u-build/install/lib)

# foonathan_memory
ExternalProject_Add(foonathan_memory
    GIT_REPOSITORY https://github.com/foonathan/memory.git
    GIT_TAG        ${FOONATHAN_MEMORY_VERSION}
    CMAKE_ARGS
        -DCMAKE_POLICY_DEFAULT_CMP0091:STRING=NEW 
        -DCMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreaded$<$<CONFIG:Debug>:Debug>DLL
        -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
    CMAKE_CACHE_ARGS  
        -DCMAKE_INSTALL_PREFIX:PATH=install
        -DCMAKE_BUILD_TYPE:STRING=Release 
        -DDOCTEST_WITH_MAIN_IN_STATIC_LIB:BOOL=OFF 
        -DFOONATHAN_MEMORY_BUILD_TESTS:BOOL=OFF 
        -DFOONATHAN_MEMORY_BUILD_EXAMPLES:BOOL=OFF 
        -DFOONATHAN_MEMORY_BUILD_TOOLS:BOOL=OFF
    BUILD_COMMAND  ${CMAKE_COMMAND} --build <BINARY_DIR> --config Release
    INSTALL_COMMAND  ${CMAKE_COMMAND} --install <BINARY_DIR> --config Release
)

string(REPLACE "v" "" FOONATHAN_MEMORY_VERSION ${FOONATHAN_MEMORY_VERSION})
string(REPLACE "-" "." FOONATHAN_MEMORY_VERSION ${FOONATHAN_MEMORY_VERSION})
set(FOONATHAN_MEMORY_TARGET foonathan_memory-${FOONATHAN_MEMORY_VERSION})
set(FOONATHAN_MEMORY_LIBRARY_DIR ${CMAKE_BINARY_DIR}/ros2dds/foonathan_memory-prefix/src/foonathan_memory-build/install/lib)
set(FOONATHAN_MEMORY_INCLUDE_DIR ${CMAKE_BINARY_DIR}/ros2dds/foonathan_memory-prefix/src/foonathan_memory-build/install/include)

# Fast-CDR
ExternalProject_Add(Fast-CDR
    GIT_REPOSITORY https://github.com/eProsima/Fast-CDR.git
    GIT_TAG        ${FAST_CDR_VERSION}
    CMAKE_ARGS
        -DCMAKE_POLICY_DEFAULT_CMP0091:STRING=NEW 
        -DCMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreaded$<$<CONFIG:Debug>:Debug>DLL
        -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
    CMAKE_CACHE_ARGS  
        -DCMAKE_INSTALL_PREFIX:PATH=install
        -DCMAKE_BUILD_TYPE:STRING=Release 
        -DBUILD_SHARED_LIBS:BOOL=OFF
        -DBUILD_DOCUMENTATION:BOOL=OFF
    BUILD_COMMAND  ${CMAKE_COMMAND} --build <BINARY_DIR> --config Release
    INSTALL_COMMAND  ${CMAKE_COMMAND} --install <BINARY_DIR> --config Release
)

if(WIN32)
    string(REPLACE "v" "" FAST_CDR_VERSION ${FAST_CDR_VERSION})
    string(REPLACE "." ";" FAST_CDR_VERSION_LIST ${FAST_CDR_VERSION})
    list(GET FAST_CDR_VERSION_LIST 0 FAST_CDR_VERSION_MAJOR)
    list(GET FAST_CDR_VERSION_LIST 1 FAST_CDR_VERSION_MINOR)
    list(GET FAST_CDR_VERSION_LIST 2 FAST_CDR_VERSION_PATCH)
    set(FAST_CDR_TARGET libfastcdr-${FAST_CDR_VERSION_MAJOR}.${FAST_CDR_VERSION_MINOR})
else()
    set(FAST_CDR_TARGET fastcdr)
endif()

set(FAST_CDR_LIBRARY_DIR ${CMAKE_BINARY_DIR}/ros2dds/Fast-CDR-prefix/src/Fast-CDR-build/install/lib)
set(FAST_CDR_INCLUDE_DIR ${CMAKE_BINARY_DIR}/ros2dds/Fast-CDR-prefix/src/Fast-CDR-build/install/include)

if(WIN32)
    set(FOONATHAN_MEMORY_CMAKE_DIR share)
else()
    set(FOONATHAN_MEMORY_CMAKE_DIR lib)
endif()

# Fast-DDS
ExternalProject_Add(Fast-DDS
GIT_REPOSITORY https://github.com/eProsima/Fast-DDS.git
GIT_TAG        ${FAST_DDS_VERSION}
DEPENDS
    foonathan_memory
    Fast-CDR
CMAKE_ARGS
    -DCMAKE_POLICY_DEFAULT_CMP0091:STRING=NEW 
    -DCMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreaded$<$<CONFIG:Debug>:Debug>DLL
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
CMAKE_CACHE_ARGS  
    -DCMAKE_INSTALL_PREFIX:PATH=install
    -DCMAKE_BUILD_TYPE:STRING=Release  
    -DBUILD_SHARED_LIBS:BOOL=OFF
    -DBUILD_DOCUMENTATION:BOOL=OFF
    -DBUILD_TESTING:BOOL=OFF
    -DCOMPILE_EXAMPLES:BOOL=OFF
    -DFASTDDS_STATISTICS:BOOL=OFF
    -DINSTALL_EXAMPLES:BOOL=OFF
    -DINSTALL_TOOLS:BOOL=OFF
    -DSQLITE3_SUPPORT:BOOL=OFF
    -Dfastcdr_DIR:STRING=${FAST_CDR_LIBRARY_DIR}/cmake/fastcdr
    -Dfoonathan_memory_DIR:STRING=${FOONATHAN_MEMORY_LIBRARY_DIR}/../${FOONATHAN_MEMORY_CMAKE_DIR}/foonathan_memory/cmake
BUILD_COMMAND  ${CMAKE_COMMAND} --build <BINARY_DIR> --config Release
INSTALL_COMMAND  ${CMAKE_COMMAND} --install <BINARY_DIR> --config Release
)

if(WIN32)
    string(REPLACE "v" "" FAST_DDS_VERSION ${FAST_DDS_VERSION})
    string(REPLACE "." ";" FAST_DDS_VERSION_LIST ${FAST_DDS_VERSION})
    list(GET FAST_DDS_VERSION_LIST 0 FAST_DDS_VERSION_MAJOR)
    list(GET FAST_DDS_VERSION_LIST 1 FAST_DDS_VERSION_MINOR)
    list(GET FAST_DDS_VERSION_LIST 2 FAST_DDS_VERSION_PATCH)
    set(FAST_DDS_TARGET libfastrtps-${FAST_DDS_VERSION_MAJOR}.${FAST_DDS_VERSION_MINOR})
else()
    set(FAST_DDS_TARGET fastrtps)
endif()

set(FAST_DDS_LIBRARY_DIR ${CMAKE_BINARY_DIR}/ros2dds/Fast-DDS-prefix/src/Fast-DDS-build/install/lib)
set(FAST_DDS_INCLUDE_DIR ${CMAKE_BINARY_DIR}/ros2dds/Fast-DDS-prefix/src/Fast-DDS-build/install/include)

# ====================================================== #
# ================= Configure SConstruct =============== #
# ====================================================== #
configure_file (
    "${CMAKE_CURRENT_SOURCE_DIR}/SConstruct.in"
    "${CMAKE_CURRENT_SOURCE_DIR}/SConstruct")