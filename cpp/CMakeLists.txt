cmake_minimum_required(VERSION 3.15)
project(SuperintelligenceTimeline VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Compiler flags
if(MSVC)
    add_compile_options(/W4 /WX)
else()
    add_compile_options(-Wall -Wextra -Wpedantic -Werror)
endif()

# Build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# Options
option(BUILD_TESTS "Build tests" ON)
option(BUILD_EXAMPLES "Build examples" ON)
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)

# Include directories
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

# Source files
set(TIMELINE_SOURCES
    src/Event.cpp
    src/Timeline.cpp
    src/TimelineFormatter.cpp
    src/Utils.cpp
)

set(TIMELINE_HEADERS
    include/timeline/Timeline.hpp
    include/timeline/Utils.hpp
)

# Create library
add_library(timeline ${TIMELINE_SOURCES} ${TIMELINE_HEADERS})
target_include_directories(timeline PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

# Main executable
add_executable(timeline_app src/main.cpp)
target_link_libraries(timeline_app PRIVATE timeline)

# Examples
if(BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

# Tests
if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# Installation
install(TARGETS timeline timeline_app
    EXPORT TimelineTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)

install(DIRECTORY include/
    DESTINATION include
    FILES_MATCHING PATTERN "*.hpp"
)

# Export targets
install(EXPORT TimelineTargets
    FILE TimelineTargets.cmake
    NAMESPACE Timeline::
    DESTINATION lib/cmake/Timeline
)

# Create config file
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/TimelineConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/TimelineConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/TimelineConfig.cmake"
    INSTALL_DESTINATION lib/cmake/Timeline
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/TimelineConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/TimelineConfigVersion.cmake"
    DESTINATION lib/cmake/Timeline
)

# CPack configuration
set(CPACK_PACKAGE_NAME "SuperintelligenceTimeline")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Constitutional Timeline of the OS-Algorithmic-Mesh")
set(CPACK_PACKAGE_VENDOR "Alexandre Pedrosa Guimarães")
include(CPack)
