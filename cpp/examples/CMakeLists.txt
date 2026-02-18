# Simple example
add_executable(simple_example simple_example.cpp)
target_link_libraries(simple_example PRIVATE timeline)

# Custom timeline example
add_executable(custom_timeline custom_timeline.cpp)
target_link_libraries(custom_timeline PRIVATE timeline)
