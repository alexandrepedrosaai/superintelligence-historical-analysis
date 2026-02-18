#include "timeline/Timeline.hpp"
#include "timeline/Utils.hpp"
#include <sstream>

namespace timeline {

std::string TimelineFormatter::format(const Timeline& timeline, Format format) {
    switch (format) {
        case Format::JSON:     return toJson(timeline);
        case Format::XML:      return toXml(timeline);
        case Format::MARKDOWN: return toMarkdown(timeline);
        case Format::HTML:     return toHtml(timeline);
        case Format::CSV:      return toCsv(timeline);
        default:               return toJson(timeline);
    }
}

std::string TimelineFormatter::formatEvent(const Event& event, Format format) {
    Timeline temp;
    temp.addEvent(event);
    return TimelineFormatter::format(temp, format);
}

std::string TimelineFormatter::toJson(const Timeline& timeline) {
    return timeline.toJson();
}

std::string TimelineFormatter::toXml(const Timeline& timeline) {
    std::ostringstream oss;
    oss << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    oss << "<timeline>\n";
    
    for (const auto& event : timeline.getAllEvents()) {
        oss << "  <event>\n";
        oss << "    <date>" << event.getDate() << "</date>\n";
        oss << "    <title>" << event.getTitle() << "</title>\n";
        oss << "    <description>" << event.getDescription() << "</description>\n";
        oss << "    <category>" << event.getCategory() << "</category>\n";
        oss << "  </event>\n";
    }
    
    oss << "</timeline>\n";
    return oss.str();
}

std::string TimelineFormatter::toMarkdown(const Timeline& timeline) {
    std::ostringstream oss;
    oss << "# Constitutional Timeline of the OS-Algorithmic-Mesh\n\n";
    
    for (const auto& event : timeline.getAllEvents()) {
        oss << "## " << event.getDate() << " - " << event.getTitle() << "\n\n";
        oss << event.getDescription() << "\n\n";
        oss << "*Category: " << event.getCategory() << "*\n\n";
        oss << "---\n\n";
    }
    
    return oss.str();
}

std::string TimelineFormatter::toHtml(const Timeline& timeline) {
    std::ostringstream oss;
    oss << "<!DOCTYPE html>\n";
    oss << "<html>\n<head>\n";
    oss << "  <title>Constitutional Timeline</title>\n";
    oss << "  <style>\n";
    oss << "    body { font-family: Arial, sans-serif; margin: 40px; }\n";
    oss << "    .event { margin-bottom: 30px; border-left: 4px solid #0078d4; padding-left: 20px; }\n";
    oss << "    .date { color: #0078d4; font-weight: bold; }\n";
    oss << "    .title { font-size: 1.2em; margin: 5px 0; }\n";
    oss << "    .category { color: #666; font-style: italic; }\n";
    oss << "  </style>\n";
    oss << "</head>\n<body>\n";
    oss << "  <h1>Constitutional Timeline of the OS-Algorithmic-Mesh</h1>\n";
    
    for (const auto& event : timeline.getAllEvents()) {
        oss << "  <div class=\"event\">\n";
        oss << "    <div class=\"date\">" << event.getDate() << "</div>\n";
        oss << "    <div class=\"title\">" << event.getTitle() << "</div>\n";
        oss << "    <p>" << event.getDescription() << "</p>\n";
        oss << "    <div class=\"category\">Category: " << event.getCategory() << "</div>\n";
        oss << "  </div>\n";
    }
    
    oss << "</body>\n</html>\n";
    return oss.str();
}

std::string TimelineFormatter::toCsv(const Timeline& timeline) {
    std::ostringstream oss;
    oss << "Date,Title,Description,Category\n";
    
    for (const auto& event : timeline.getAllEvents()) {
        oss << "\"" << event.getDate() << "\",";
        oss << "\"" << event.getTitle() << "\",";
        oss << "\"" << event.getDescription() << "\",";
        oss << "\"" << event.getCategory() << "\"\n";
    }
    
    return oss.str();
}

} // namespace timeline
