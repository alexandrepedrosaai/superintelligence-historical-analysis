#include "timeline/Timeline.hpp"
#include "timeline/Utils.hpp"
#include <sstream>
#include <iomanip>

namespace timeline {

Event::Event(const std::string& date, 
             const std::string& title,
             const std::string& description,
             const std::string& category)
    : date_(date)
    , title_(title)
    , description_(description)
    , category_(category) {
    parseDate();
}

void Event::parseDate() {
    timePoint_ = utils::DateUtils::parseDate(date_);
}

bool Event::operator<(const Event& other) const {
    return timePoint_ < other.timePoint_;
}

bool Event::operator==(const Event& other) const {
    return date_ == other.date_ && title_ == other.title_;
}

std::string Event::toJson() const {
    std::ostringstream oss;
    oss << "{"
        << "\"date\":\"" << utils::JsonUtils::escape(date_) << "\","
        << "\"title\":\"" << utils::JsonUtils::escape(title_) << "\","
        << "\"description\":\"" << utils::JsonUtils::escape(description_) << "\","
        << "\"category\":\"" << utils::JsonUtils::escape(category_) << "\""
        << "}";
    return oss.str();
}

Event Event::fromJson(const std::string& json) {
    // Simplified JSON parsing - in production use a proper JSON library
    std::string date, title, description, category = "general";
    
    // Extract date
    size_t datePos = json.find("\"date\":\"");
    if (datePos != std::string::npos) {
        size_t start = datePos + 8;
        size_t end = json.find("\"", start);
        date = json.substr(start, end - start);
    }
    
    // Extract title
    size_t titlePos = json.find("\"title\":\"");
    if (titlePos != std::string::npos) {
        size_t start = titlePos + 9;
        size_t end = json.find("\"", start);
        title = json.substr(start, end - start);
    }
    
    // Extract description
    size_t descPos = json.find("\"description\":\"");
    if (descPos != std::string::npos) {
        size_t start = descPos + 15;
        size_t end = json.find("\"", start);
        description = json.substr(start, end - start);
    }
    
    // Extract category
    size_t catPos = json.find("\"category\":\"");
    if (catPos != std::string::npos) {
        size_t start = catPos + 12;
        size_t end = json.find("\"", start);
        category = json.substr(start, end - start);
    }
    
    return Event(date, title, description, category);
}

} // namespace timeline
