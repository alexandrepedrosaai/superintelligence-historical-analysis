#include "timeline/Timeline.hpp"
#include <iostream>
#include <cassert>

using namespace timeline;

void test_timeline_add_event() {
    Timeline timeline;
    timeline.addEvent("2026-01-06", "Test Event", "Description", "test");
    
    assert(timeline.getEventCount() == 1);
    
    std::cout << "✓ Timeline add event test passed\n";
}

void test_timeline_find_event() {
    Timeline timeline;
    timeline.addEvent("2026-01-06", "Test Event", "Description", "test");
    
    const Event* event = timeline.findEvent("2026-01-06");
    assert(event != nullptr);
    assert(event->getTitle() == "Test Event");
    
    const Event* notFound = timeline.findEvent("2026-01-01");
    assert(notFound == nullptr);
    
    std::cout << "✓ Timeline find event test passed\n";
}

void test_timeline_remove_event() {
    Timeline timeline;
    timeline.addEvent("2026-01-06", "Test Event", "Description", "test");
    
    assert(timeline.getEventCount() == 1);
    
    bool removed = timeline.removeEvent("2026-01-06");
    assert(removed);
    assert(timeline.getEventCount() == 0);
    
    std::cout << "✓ Timeline remove event test passed\n";
}

void test_timeline_category_filter() {
    Timeline timeline;
    timeline.addEvent("2026-01-01", "Event 1", "Description", "cat1");
    timeline.addEvent("2026-01-02", "Event 2", "Description", "cat2");
    timeline.addEvent("2026-01-03", "Event 3", "Description", "cat1");
    
    auto cat1Events = timeline.getEventsByCategory("cat1");
    assert(cat1Events.size() == 2);
    
    std::cout << "✓ Timeline category filter test passed\n";
}

void test_timeline_date_range() {
    Timeline timeline;
    timeline.addEvent("2026-01-01", "Event 1", "Description");
    timeline.addEvent("2026-01-15", "Event 2", "Description");
    timeline.addEvent("2026-02-01", "Event 3", "Description");
    
    auto rangeEvents = timeline.getEventsByDateRange("2026-01-01", "2026-01-31");
    assert(rangeEvents.size() == 2);
    
    std::cout << "✓ Timeline date range test passed\n";
}

void test_timeline_statistics() {
    Timeline timeline;
    timeline.addEvent("2026-01-01", "Event 1", "Description", "cat1");
    timeline.addEvent("2026-01-02", "Event 2", "Description", "cat2");
    timeline.addEvent("2026-01-03", "Event 3", "Description", "cat1");
    
    auto stats = timeline.getCategoryStatistics();
    assert(stats["cat1"] == 2);
    assert(stats["cat2"] == 1);
    
    std::cout << "✓ Timeline statistics test passed\n";
}

void run_timeline_tests() {
    std::cout << "\n=== Running Timeline Tests ===\n";
    test_timeline_add_event();
    test_timeline_find_event();
    test_timeline_remove_event();
    test_timeline_category_filter();
    test_timeline_date_range();
    test_timeline_statistics();
    std::cout << "=== All Timeline Tests Passed ===\n\n";
}
