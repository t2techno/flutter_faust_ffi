cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(faust_c_library VERSION 1.0.0 LANGUAGES C)
add_library(faust_c_library SHARED FaustFlutterC.c FaustFlutterC.def)
target_link_libraries(faust_c_library PUBLIC)

set_target_properties(faust_c_library PROPERTIES
    PUBLIC_HEADER FaustFlutterC.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "faust_c"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)

if (WIN32)
    set_target_properties(faust_c_library PROPERTIES
        WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif (WIN32)

target_compile_definitions(faust_c_library PUBLIC DART_SHARED_LIB)