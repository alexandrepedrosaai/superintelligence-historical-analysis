# Test executable
add_executable(timeline_tests
    test_event.cpp
    test_timeline.cpp
    test_utils.cpp
    test_formatter.cpp
)

target_link_libraries(timeline_tests PRIVATE timeline)

# Add tests
add_test(NAME EventTests COMMAND timeline_tests event)
add_test(NAME TimelineTests COMMAND timeline_tests timeline)
add_test(NAME UtilsTests COMMAND timeline_tests utils)
add_test(NAME FormatterTests COMMAND timeline_tests formatter)
add_test(NAME AllTests COMMAND timeline_tests)
