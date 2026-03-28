#include "timeline/Timeline.hpp"
#include <iostream>

using namespace timeline;

int main() {
    std::cout << "Simple Timeline Example\n";
    std::cout << "=======================\n\n";
    
    // Create a timeline
    Timeline timeline;
    
    // Load default events
    timeline.loadDefaultTimeline();
    
    // Display event count
    std::cout << "Total events: " << timeline.getEventCount() << "\n\n";
    
    // Display all events
    std::cout << "Timeline Events:\n";
    std::cout << "----------------\n";
    for (const auto& event : timeline.getAllEvents()) {
        std::cout << event.getDate() << " - " << event.getTitle() << "\n";
    }
    
    // Export to JSON
    std::cout << "\nExporting to JSON...\n";
    timeline.saveToFile("simple_timeline.json");
    std::cout << "Saved to: simple_timeline.json\n";
    
    return 0;
}
