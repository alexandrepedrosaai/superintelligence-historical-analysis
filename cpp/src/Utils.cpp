#include "timeline/Utils.hpp"
#include <fstream>
#include <sstream>
#include <algorithm>
#include <iomanip>
#include <ctime>

namespace timeline {
namespace utils {

// DateUtils implementation
DateUtils::TimePoint DateUtils::parseDate(const std::string& dateStr) {
    std::tm tm = {};
    std::istringstream ss(dateStr);
    
    // Try different formats
    if (dateStr.find('-') != std::string::npos) {
        ss >> std::get_time(&tm, "%Y-%m-%d");
    } else if (dateStr.find('/') != std::string::npos) {
        ss >> std::get_time(&tm, "%Y/%m/%d");
    }
    
    return std::chrono::system_clock::from_time_t(std::mktime(&tm));
}

std::string DateUtils::formatDate(const TimePoint& tp, const std::string& format) {
    std::time_t tt = std::chrono::system_clock::to_time_t(tp);
    std::tm tm = *std::localtime(&tt);
    std::ostringstream oss;
    oss << std::put_time(&tm, format.c_str());
    return oss.str();
}

bool DateUtils::isValidDate(const std::string& dateStr) {
    try {
        parseDate(dateStr);
        return true;
    } catch (...) {
        return false;
    }
}

int DateUtils::compareDates(const std::string& date1, const std::string& date2) {
    auto tp1 = parseDate(date1);
    auto tp2 = parseDate(date2);
    
    if (tp1 < tp2) return -1;
    if (tp1 > tp2) return 1;
    return 0;
}

// StringUtils implementation
std::string StringUtils::trim(const std::string& str) {
    size_t first = str.find_first_not_of(" \t\n\r");
    if (first == std::string::npos) return "";
    
    size_t last = str.find_last_not_of(" \t\n\r");
    return str.substr(first, last - first + 1);
}

std::vector<std::string> StringUtils::split(const std::string& str, char delimiter) {
    std::vector<std::string> tokens;
    std::istringstream iss(str);
    std::string token;
    
    while (std::getline(iss, token, delimiter)) {
        tokens.push_back(token);
    }
    
    return tokens;
}

std::string StringUtils::join(const std::vector<std::string>& vec, const std::string& delimiter) {
    std::ostringstream oss;
    for (size_t i = 0; i < vec.size(); ++i) {
        oss << vec[i];
        if (i < vec.size() - 1) {
            oss << delimiter;
        }
    }
    return oss.str();
}

std::string StringUtils::toLower(const std::string& str) {
    std::string result = str;
    std::transform(result.begin(), result.end(), result.begin(), ::tolower);
    return result;
}

std::string StringUtils::toUpper(const std::string& str) {
    std::string result = str;
    std::transform(result.begin(), result.end(), result.begin(), ::toupper);
    return result;
}

bool StringUtils::startsWith(const std::string& str, const std::string& prefix) {
    return str.size() >= prefix.size() && 
           str.compare(0, prefix.size(), prefix) == 0;
}

bool StringUtils::endsWith(const std::string& str, const std::string& suffix) {
    return str.size() >= suffix.size() && 
           str.compare(str.size() - suffix.size(), suffix.size(), suffix) == 0;
}

std::string StringUtils::replace(const std::string& str, const std::string& from, const std::string& to) {
    std::string result = str;
    size_t pos = 0;
    while ((pos = result.find(from, pos)) != std::string::npos) {
        result.replace(pos, from.length(), to);
        pos += to.length();
    }
    return result;
}

// JsonUtils implementation
std::string JsonUtils::escape(const std::string& str) {
    std::string result;
    for (char c : str) {
        switch (c) {
            case '"':  result += "\\\""; break;
            case '\\': result += "\\\\"; break;
            case '\b': result += "\\b";  break;
            case '\f': result += "\\f";  break;
            case '\n': result += "\\n";  break;
            case '\r': result += "\\r";  break;
            case '\t': result += "\\t";  break;
            default:   result += c;      break;
        }
    }
    return result;
}

std::string JsonUtils::unescape(const std::string& str) {
    std::string result;
    for (size_t i = 0; i < str.length(); ++i) {
        if (str[i] == '\\' && i + 1 < str.length()) {
            switch (str[i + 1]) {
                case '"':  result += '"';  ++i; break;
                case '\\': result += '\\'; ++i; break;
                case 'b':  result += '\b'; ++i; break;
                case 'f':  result += '\f'; ++i; break;
                case 'n':  result += '\n'; ++i; break;
                case 'r':  result += '\r'; ++i; break;
                case 't':  result += '\t'; ++i; break;
                default:   result += str[i];    break;
            }
        } else {
            result += str[i];
        }
    }
    return result;
}

std::string JsonUtils::wrapString(const std::string& str) {
    return "\"" + escape(str) + "\"";
}

std::string JsonUtils::wrapObject(const std::string& content) {
    return "{" + content + "}";
}

std::string JsonUtils::wrapArray(const std::string& content) {
    return "[" + content + "]";
}

// FileUtils implementation
bool FileUtils::fileExists(const std::string& filename) {
    std::ifstream file(filename);
    return file.good();
}

std::string FileUtils::readFile(const std::string& filename) {
    std::ifstream file(filename);
    if (!file.is_open()) return "";
    
    std::ostringstream oss;
    oss << file.rdbuf();
    return oss.str();
}

bool FileUtils::writeFile(const std::string& filename, const std::string& content) {
    std::ofstream file(filename);
    if (!file.is_open()) return false;
    
    file << content;
    return true;
}

std::string FileUtils::getFileExtension(const std::string& filename) {
    size_t pos = filename.find_last_of('.');
    if (pos == std::string::npos) return "";
    return filename.substr(pos + 1);
}

std::string FileUtils::getBaseName(const std::string& filename) {
    size_t pos = filename.find_last_of("/\\");
    std::string base = (pos == std::string::npos) ? filename : filename.substr(pos + 1);
    
    size_t dotPos = base.find_last_of('.');
    if (dotPos != std::string::npos) {
        base = base.substr(0, dotPos);
    }
    
    return base;
}

} // namespace utils
} // namespace timeline
