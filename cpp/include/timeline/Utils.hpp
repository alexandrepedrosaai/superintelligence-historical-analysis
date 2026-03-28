#ifndef TIMELINE_UTILS_HPP
#define TIMELINE_UTILS_HPP

#include <string>
#include <vector>
#include <chrono>

namespace timeline {
namespace utils {

/**
 * @brief Date parsing and formatting utilities
 */
class DateUtils {
public:
    using TimePoint = std::chrono::system_clock::time_point;
    
    static TimePoint parseDate(const std::string& dateStr);
    static std::string formatDate(const TimePoint& tp, const std::string& format = "%Y-%m-%d");
    static bool isValidDate(const std::string& dateStr);
    static int compareDates(const std::string& date1, const std::string& date2);
};

/**
 * @brief String manipulation utilities
 */
class StringUtils {
public:
    static std::string trim(const std::string& str);
    static std::vector<std::string> split(const std::string& str, char delimiter);
    static std::string join(const std::vector<std::string>& vec, const std::string& delimiter);
    static std::string toLower(const std::string& str);
    static std::string toUpper(const std::string& str);
    static bool startsWith(const std::string& str, const std::string& prefix);
    static bool endsWith(const std::string& str, const std::string& suffix);
    static std::string replace(const std::string& str, const std::string& from, const std::string& to);
};

/**
 * @brief JSON utilities
 */
class JsonUtils {
public:
    static std::string escape(const std::string& str);
    static std::string unescape(const std::string& str);
    static std::string wrapString(const std::string& str);
    static std::string wrapObject(const std::string& content);
    static std::string wrapArray(const std::string& content);
};

/**
 * @brief File I/O utilities
 */
class FileUtils {
public:
    static bool fileExists(const std::string& filename);
    static std::string readFile(const std::string& filename);
    static bool writeFile(const std::string& filename, const std::string& content);
    static std::string getFileExtension(const std::string& filename);
    static std::string getBaseName(const std::string& filename);
};

} // namespace utils
} // namespace timeline

#endif // TIMELINE_UTILS_HPP
