#include "timeline/Timeline.hpp"
#include <iostream>
#include <cassert>

using namespace timeline;

void test_event_creation() {
    Event event("2026-01-06", "Test Event", "Test Description", "test");
    
    assert(event.getDate() == "2026-01-06");
    assert(event.getTitle() == "Test Event");
    assert(event.getDescription() == "Test Description");
    assert(event.getCategory() == "test");
    
    std::cout << "✓ Event creation test passed\n";
}

void test_event_comparison() {
    Event event1("2026-01-01", "Event 1", "Description 1");
    Event event2("2026-01-02", "Event 2", "Description 2");
    
    assert(event1 < event2);
    assert(!(event2 < event1));
    
    std::cout << "✓ Event comparison test passed\n";
}

void test_event_json() {
    Event event("2026-01-06", "Test Event", "Test Description", "test");
    
    std::string json = event.toJson();
    assert(json.find("\"date\":\"2026-01-06\"") != std::string::npos);
    assert(json.find("\"title\":\"Test Event\"") != std::string::npos);
    
    std::cout << "✓ Event JSON serialization test passed\n";
}

void run_event_tests() {
    std::cout << "\n=== Running Event Tests ===\n";
    test_event_creation();
    test_event_comparison();
    test_event_json();
    std::cout << "=== All Event Tests Passed ===\n\n";
}
