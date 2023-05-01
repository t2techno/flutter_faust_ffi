cmake_minimum_required(VERSION 3.24 FATAL_ERROR)
project(faust_c_library VERSION 1.0.0 LANGUAGES C)
add_library(faust_c_library SHARED FaustFlutterC.c FaustFlutterC.def)
target_link_libraries(faust_c_library PUBLIC)
add_executable(faust_c_test FaustFlutterC.c)
target_link_libraries(faust_c_test PUBLIC)

set_target_properties(faust_c_library PROPERTIES
    PUBLIC_HEADER FaustFlutterC.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "faust_c"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)