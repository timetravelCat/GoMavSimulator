# Perpose 
# - Generate required flags used for configure SConstruct.in
# - MAVSDK_TARGET
# - MAVSDK_LIBRARY_DIR
# - MAVSDK_INCLUDE_DIR

# 1. CURL
    # CURL_LIBRARIES
    # CURL_INCLUDE_DIRS

# TinyXML2
ExternalProject_Add(tinyxml2
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

set(TINYXML2_LIBRARY ${CMAKE_BINARY_DIR}/mavsdk/tinyxml2-prefix/src/tinyxml2-build/install/lib)
set(TINYXML2_INCLUDE_DIR ${CMAKE_BINARY_DIR}/mavsdk/tinyxml2-prefix/src/tinyxml2-build/install/include)

# 3. JsonCPP
ExternalProject_Add(jsoncpp
GIT_REPOSITORY https://github.com/open-source-parsers/jsoncpp
GIT_TAG ed1ab7ac452b0fe51f3b0a8364770774175a060e
CMAKE_ARGS 
    -DCMAKE_POLICY_DEFAULT_CMP0091:STRING=NEW 
    -DCMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreaded$<$<CONFIG:Debug>:Debug>DLL
    -DCMAKE_INSTALL_PREFIX:PATH=install
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
    -DBUILD_SHARED_LIBS=OFF
    -DJSONCPP_WITH_CMAKE_PACKAGE=ON
    -DJSONCPP_WITH_TESTS=OFF
BUILD_COMMAND  ${CMAKE_COMMAND} --build <BINARY_DIR> --config Release
INSTALL_COMMAND  ${CMAKE_COMMAND} --install <BINARY_DIR> --config Release
)

# 4. MAVSDK
ExternalProject_Add(MAVSDK
GIT_REPOSITORY https://github.com/timetravelCat/MAVSDK.git
GIT_TAG ${MAVSDK_VERSION}
DEPENDS jsoncpp tinyxml2
CMAKE_ARGS 
    -DCMAKE_POLICY_DEFAULT_CMP0091:STRING=NEW 
    -DCMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreaded$<$<CONFIG:Debug>:Debug>DLL
    -DCMAKE_INSTALL_PREFIX:PATH=install
    -DCMAKE_BUILD_TYPE:STRING=Release 
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
    -DBUILD_SHARED_LIBS:BOOL=OFF
    -DSUPERBUILD:BOOL=OFF
    -DBUILD_MAVSDK_SERVER:BOOL=OFF
    -DBUILD_TESTS:BOOL=OFF
    -DTINYXML2_LIBRARY:STRING=${TINYXML2_LIBRARY}
    -DTINYXML2_INCLUDE_DIR:STRING=${TINYXML2_INCLUDE_DIR}
    -DCURL_INCLUDE_DIR:STRING=${CURL_INCLUDE_DIRS}
    -DCURL_LIBRARY:STRING=${CURL_LIBRARIES}
    -DJsonCpp_LIBRARY:STRING=${CMAKE_BINARY_DIR}/mavsdk/jsoncpp-prefix/src/jsoncpp-build/install/lib/jsoncpp.lib
    -DJsonCpp_INCLUDE_DIR:STRING=${CMAKE_BINARY_DIR}/mavsdk/jsoncpp-prefix/src/jsoncpp-build/install/include
BUILD_COMMAND  ${CMAKE_COMMAND} --build <BINARY_DIR> --config Release
INSTALL_COMMAND  ${CMAKE_COMMAND} --install <BINARY_DIR> --config Release
)

set(MAVSDK_TARGET mavsdk)
set(MAVSDK_LIBRARY_DIR ${CMAKE_BINARY_DIR}/mavsdk/MAVSDK-prefix/src/MAVSDK-build/install/lib)
set(MAVSDK_INCLUDE_DIR ${CMAKE_BINARY_DIR}/mavsdk/MAVSDK-prefix/src/MAVSDK-build/install/include)

# ====================================================== #
# ================= Configure SConstruct =============== #
# ====================================================== #
configure_file (
    "${CMAKE_CURRENT_SOURCE_DIR}/SConstruct.in"
    "${CMAKE_CURRENT_SOURCE_DIR}/SConstruct")