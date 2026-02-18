#include "timeline/Utils.hpp"
#include <iostream>
#include <cassert>

using namespace timeline::utils;

void test_string_trim() {
    assert(StringUtils::trim("  hello  ") == "hello");
    assert(StringUtils::trim("hello") == "hello");
    assert(StringUtils::trim("   ") == "");
    
    std::cout << "✓ String trim test passed\n";
}

void test_string_split() {
    auto parts = StringUtils::split("a,b,c", ',');
    assert(parts.size() == 3);
    assert(parts[0] == "a");
    assert(parts[1] == "b");
    assert(parts[2] == "c");
    
    std::cout << "✓ String split test passed\n";
}

void test_string_case() {
    assert(StringUtils::toLower("HELLO") == "hello");
    assert(StringUtils::toUpper("hello") == "HELLO");
    
    std::cout << "✓ String case conversion test passed\n";
}

void test_string_prefix_suffix() {
    assert(StringUtils::startsWith("hello world", "hello"));
    assert(!StringUtils::startsWith("hello world", "world"));
    assert(StringUtils::endsWith("hello world", "world"));
    assert(!StringUtils::endsWith("hello world", "hello"));
    
    std::cout << "✓ String prefix/suffix test passed\n";
}

void test_json_escape() {
    assert(JsonUtils::escape("hello\"world") == "hello\\\"world");
    assert(JsonUtils::escape("line1\nline2") == "line1\\nline2");
    
    std::cout << "✓ JSON escape test passed\n";
}

void run_utils_tests() {
    std::cout << "\n=== Running Utils Tests ===\n";
    test_string_trim();
    test_string_split();
    test_string_case();
    test_string_prefix_suffix();
    test_json_escape();
    std::cout << "=== All Utils Tests Passed ===\n\n";
}
