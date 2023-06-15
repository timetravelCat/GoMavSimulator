if(WIN32)
    include(cmake/FindWindowsSDK.cmake)
    if(NOT WINDOWSSDK_FOUND)
        message(FATAL_ERROR "WINDOWS SDK NOT FOUND")
    endif()
    set(SETUPAPI_TARGET SetupAPI)
    set(ADVAPI32_TARGET AdvAPI32)
    set(WINDOWS_SDK_LIB_DIR ${WINDOWSSDK_LATEST_DIR}/Lib/${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION}/um/x64)
    
    set(serial_SRC_1 src/impl/win.cc)
    set(serial_SRC_2 src/impl/list_ports/list_ports_win.cc)

else()

    set(serial_SRC_1 src/impl/unix.cc)
    set(serial_SRC_2 src/impl/list_ports/list_ports_linux.cc)
    # DEPENDS rt pthread
endif()

configure_file (
    "${CMAKE_CURRENT_SOURCE_DIR}/SConstruct.in"
    "${CMAKE_CURRENT_SOURCE_DIR}/SConstruct")