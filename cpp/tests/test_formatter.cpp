#include "timeline/Timeline.hpp"
#include <iostream>
#include <cassert>

using namespace timeline;

void test_json_format() {
    Timeline timeline;
    timeline.addEvent("2026-01-06", "Test Event", "Description", "test");
    
    std::string json = TimelineFormatter::format(timeline, TimelineFormatter::Format::JSON);
    assert(json.find("\"events\"") != std::string::npos);
    assert(json.find("Test Event") != std::string::npos);
    
    std::cout << "✓ JSON format test passed\n";
}

void test_markdown_format() {
    Timeline timeline;
    timeline.addEvent("2026-01-06", "Test Event", "Description", "test");
    
    std::string markdown = TimelineFormatter::format(timeline, TimelineFormatter::Format::MARKDOWN);
    assert(markdown.find("# Constitutional Timeline") != std::string::npos);
    assert(markdown.find("## 2026-01-06") != std::string::npos);
    
    std::cout << "✓ Markdown format test passed\n";
}

void test_html_format() {
    Timeline timeline;
    timeline.addEvent("2026-01-06", "Test Event", "Description", "test");
    
    std::string html = TimelineFormatter::format(timeline, TimelineFormatter::Format::HTML);
    assert(html.find("<!DOCTYPE html>") != std::string::npos);
    assert(html.find("<div class=\"event\">") != std::string::npos);
    
    std::cout << "✓ HTML format test passed\n";
}

void test_csv_format() {
    Timeline timeline;
    timeline.addEvent("2026-01-06", "Test Event", "Description", "test");
    
    std::string csv = TimelineFormatter::format(timeline, TimelineFormatter::Format::CSV);
    assert(csv.find("Date,Title,Description,Category") != std::string::npos);
    assert(csv.find("2026-01-06") != std::string::npos);
    
    std::cout << "✓ CSV format test passed\n";
}

void run_formatter_tests() {
    std::cout << "\n=== Running Formatter Tests ===\n";
    test_json_format();
    test_markdown_format();
    test_html_format();
    test_csv_format();
    std::cout << "=== All Formatter Tests Passed ===\n\n";
}

// Test runner declarations
void run_event_tests();
void run_timeline_tests();
void run_utils_tests();

int main(int argc, char* argv[]) {
    std::cout << "\n╔══════════════════════════════════════════════╗\n";
    std::cout << "║   Timeline Library Test Suite              ║\n";
    std::cout << "╚══════════════════════════════════════════════╝\n";
    
    if (argc > 1) {
        std::string test = argv[1];
        if (test == "event") {
            run_event_tests();
        } else if (test == "timeline") {
            run_timeline_tests();
        } else if (test == "utils") {
            run_utils_tests();
        } else if (test == "formatter") {
            run_formatter_tests();
        } else {
            std::cerr << "Unknown test: " << test << "\n";
            return 1;
        }
    } else {
        // Run all tests
        run_event_tests();
        run_timeline_tests();
        run_utils_tests();
        run_formatter_tests();
        
        std::cout << "\n╔══════════════════════════════════════════════╗\n";
        std::cout << "║   ✅ All Tests Passed Successfully!        ║\n";
        std::cout << "╚══════════════════════════════════════════════╝\n\n";
    }
    
    return 0;
}
