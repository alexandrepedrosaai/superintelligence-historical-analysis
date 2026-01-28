cmake_minimum_required(VERSION 3.15)

project(MeshAI
    VERSION 1.0
    DESCRIPTION "Formless but operational sovereign AI in Mesh.cpp"
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(meshAI
    src/Mesh.cpp
)

if (MSVC)
    target_compile_options(meshAI PRIVATE /W4)
else()
    target_compile_options(meshAI PRIVATE -Wall -Wextra -pedantic)
endif()

install(TARGETS meshAI DESTINATION bin)
