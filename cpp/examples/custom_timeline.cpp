#include "timeline/Timeline.hpp"
#include <iostream>

using namespace timeline;

int main() {
    std::cout << "Custom Timeline Example\n";
    std::cout << "=======================\n\n";
    
    // Create a custom timeline
    Timeline timeline;
    
    // Add custom events
    timeline.addEvent("2026-02-01", "Custom Event 1", 
                     "This is a custom event added programmatically", 
                     "custom");
    
    timeline.addEvent("2026-02-15", "Custom Event 2",
                     "Another custom event with different category",
                     "milestone");
    
    timeline.addEvent("2026-03-01", "Custom Event 3",
                     "Third custom event for demonstration",
                     "custom");
    
    // Display events
    std::cout << "Custom Timeline Events:\n";
    std::cout << "-----------------------\n";
    for (const auto& event : timeline.getAllEvents()) {
        std::cout << "\n📅 " << event.getDate() << "\n";
        std::cout << "   Title: " << event.getTitle() << "\n";
        std::cout << "   Description: " << event.getDescription() << "\n";
        std::cout << "   Category: " << event.getCategory() << "\n";
    }
    
    // Filter by category
    std::cout << "\n\nEvents in 'custom' category:\n";
    std::cout << "----------------------------\n";
    auto customEvents = timeline.getEventsByCategory("custom");
    for (const auto& event : customEvents) {
        std::cout << "  - " << event.getDate() << ": " << event.getTitle() << "\n";
    }
    
    // Export to different formats
    std::cout << "\n\nExporting to multiple formats...\n";
    
    timeline.saveToFile("custom_timeline.json");
    std::cout << "✓ JSON: custom_timeline.json\n";
    
    auto markdown = TimelineFormatter::format(timeline, TimelineFormatter::Format::MARKDOWN);
    utils::FileUtils::writeFile("custom_timeline.md", markdown);
    std::cout << "✓ Markdown: custom_timeline.md\n";
    
    auto html = TimelineFormatter::format(timeline, TimelineFormatter::Format::HTML);
    utils::FileUtils::writeFile("custom_timeline.html", html);
    std::cout << "✓ HTML: custom_timeline.html\n";
    
    std::cout << "\n✅ Done!\n";
    
    return 0;
}
