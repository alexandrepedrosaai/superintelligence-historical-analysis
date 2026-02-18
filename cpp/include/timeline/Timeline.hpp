#ifndef TIMELINE_HPP
#define TIMELINE_HPP

#include <string>
#include <vector>
#include <chrono>
#include <memory>
#include <map>

namespace timeline {

/**
 * @brief Represents a single event in the superintelligence timeline
 */
class Event {
public:
    using TimePoint = std::chrono::system_clock::time_point;
    
    Event(const std::string& date, 
          const std::string& title,
          const std::string& description,
          const std::string& category = "general");
    
    // Getters
    const std::string& getDate() const { return date_; }
    const std::string& getTitle() const { return title_; }
    const std::string& getDescription() const { return description_; }
    const std::string& getCategory() const { return category_; }
    TimePoint getTimePoint() const { return timePoint_; }
    
    // Setters
    void setTitle(const std::string& title) { title_ = title; }
    void setDescription(const std::string& description) { description_ = description; }
    void setCategory(const std::string& category) { category_ = category; }
    
    // Comparison operators
    bool operator<(const Event& other) const;
    bool operator==(const Event& other) const;
    
    // Serialization
    std::string toJson() const;
    static Event fromJson(const std::string& json);
    
private:
    std::string date_;
    std::string title_;
    std::string description_;
    std::string category_;
    TimePoint timePoint_;
    
    void parseDate();
};

/**
 * @brief Manages the constitutional timeline of the OS-Algorithmic-Mesh
 */
class Timeline {
public:
    Timeline();
    ~Timeline();
    
    // Event management
    void addEvent(const Event& event);
    void addEvent(const std::string& date, 
                  const std::string& title,
                  const std::string& description,
                  const std::string& category = "general");
    
    bool removeEvent(const std::string& date);
    Event* findEvent(const std::string& date);
    const Event* findEvent(const std::string& date) const;
    
    // Query operations
    std::vector<Event> getEventsByCategory(const std::string& category) const;
    std::vector<Event> getEventsByDateRange(const std::string& startDate, 
                                            const std::string& endDate) const;
    std::vector<Event> getAllEvents() const;
    
    size_t getEventCount() const { return events_.size(); }
    bool isEmpty() const { return events_.empty(); }
    
    // Sorting
    void sortByDate();
    void sortByCategory();
    
    // Serialization
    std::string toJson() const;
    void fromJson(const std::string& json);
    
    // File I/O
    bool loadFromFile(const std::string& filename);
    bool saveToFile(const std::string& filename) const;
    
    // Statistics
    std::map<std::string, size_t> getCategoryStatistics() const;
    
    // Populate with default data
    void loadDefaultTimeline();
    
private:
    std::vector<Event> events_;
    
    void sortEvents();
};

/**
 * @brief Formats timeline events for various output formats
 */
class TimelineFormatter {
public:
    enum class Format {
        JSON,
        XML,
        MARKDOWN,
        HTML,
        CSV
    };
    
    static std::string format(const Timeline& timeline, Format format);
    static std::string formatEvent(const Event& event, Format format);
    
private:
    static std::string toJson(const Timeline& timeline);
    static std::string toXml(const Timeline& timeline);
    static std::string toMarkdown(const Timeline& timeline);
    static std::string toHtml(const Timeline& timeline);
    static std::string toCsv(const Timeline& timeline);
};

} // namespace timeline

#endif // TIMELINE_HPP
