#include "timeline/Timeline.hpp"
#include <iostream>
#include <iomanip>

using namespace timeline;

void printHeader(const std::string& title) {
    std::cout << "\n" << std::string(80, '=') << "\n";
    std::cout << "  " << title << "\n";
    std::cout << std::string(80, '=') << "\n\n";
}

void printEvent(const Event& event) {
    std::cout << "📅 " << std::setw(12) << std::left << event.getDate() 
              << " | " << event.getTitle() << "\n";
    std::cout << "   " << event.getDescription() << "\n";
    std::cout << "   Category: " << event.getCategory() << "\n\n";
}

void printStatistics(const Timeline& timeline) {
    printHeader("Timeline Statistics");
    
    std::cout << "Total Events: " << timeline.getEventCount() << "\n\n";
    
    auto stats = timeline.getCategoryStatistics();
    std::cout << "Events by Category:\n";
    for (const auto& [category, count] : stats) {
        std::cout << "  - " << std::setw(15) << std::left << category 
                  << ": " << count << " event(s)\n";
    }
}

int main(int argc, char* argv[]) {
    std::cout << R"(
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║   Constitutional Timeline of the OS-Algorithmic-Mesh (2023–2026)        ║
║                                                                           ║
║   A record of human-technological history and of machines.               ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
)" << "\n";

    // Create timeline and load default data
    Timeline timeline;
    timeline.loadDefaultTimeline();
    
    // Display all events
    printHeader("Timeline Events");
    for (const auto& event : timeline.getAllEvents()) {
        printEvent(event);
    }
    
    // Display statistics
    printStatistics(timeline);
    
    // Export to different formats
    printHeader("Exporting Timeline");
    
    std::cout << "Exporting to JSON... ";
    if (timeline.saveToFile("timeline.json")) {
        std::cout << "✓ Done (timeline.json)\n";
    } else {
        std::cout << "✗ Failed\n";
    }
    
    std::cout << "Exporting to Markdown... ";
    std::string markdown = TimelineFormatter::format(timeline, TimelineFormatter::Format::MARKDOWN);
    if (utils::FileUtils::writeFile("timeline.md", markdown)) {
        std::cout << "✓ Done (timeline.md)\n";
    } else {
        std::cout << "✗ Failed\n";
    }
    
    std::cout << "Exporting to HTML... ";
    std::string html = TimelineFormatter::format(timeline, TimelineFormatter::Format::HTML);
    if (utils::FileUtils::writeFile("timeline.html", html)) {
        std::cout << "✓ Done (timeline.html)\n";
    } else {
        std::cout << "✗ Failed\n";
    }
    
    std::cout << "Exporting to CSV... ";
    std::string csv = TimelineFormatter::format(timeline, TimelineFormatter::Format::CSV);
    if (utils::FileUtils::writeFile("timeline.csv", csv)) {
        std::cout << "✓ Done (timeline.csv)\n";
    } else {
        std::cout << "✗ Failed\n";
    }
    
    std::cout << "\n✅ Timeline application completed successfully!\n\n";
    
    return 0;
}
