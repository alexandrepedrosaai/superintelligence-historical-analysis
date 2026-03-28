# C++ Timeline Library

This directory contains a complete C++ project that implements a library for managing and formatting the "Constitutional Timeline of the OS-Algorithmic-Mesh".

## ✨ Features

- **Modern C++17**: Clean, modern, and efficient code.
- **Object-Oriented Design**: Clear separation of concerns with `Event`, `Timeline`, and `TimelineFormatter` classes.
- **Multiple Output Formats**: Export the timeline to JSON, XML, Markdown, HTML, and CSV.
- **CMake Build System**: Professional, cross-platform build system.
- **Unit Tests**: Comprehensive test suite to ensure code quality.
- **Examples**: Simple and custom examples to demonstrate library usage.
- **Documentation**: Doxygen-ready comments for automatic documentation generation.

## 📂 Directory Structure

```
cpp/
├── include/          # Public headers
│   └── timeline/
│       ├── Timeline.hpp
│       └── Utils.hpp
├── src/              # Source files
│   ├── Event.cpp
│   ├── Timeline.cpp
│   ├── TimelineFormatter.cpp
│   ├── Utils.cpp
│   └── main.cpp
├── tests/            # Unit tests
│   ├── test_event.cpp
│   ├── test_timeline.cpp
│   ├── test_utils.cpp
│   └── test_formatter.cpp
├── examples/         # Example usage
│   ├── simple_example.cpp
│   └── custom_timeline.cpp
├── build/            # Build directory (generated)
├── docs/             # Documentation (generated)
├── lib/              # External libraries (if any)
└── CMakeLists.txt    # Main CMake build script
```

## 🚀 How to Build and Run

### Prerequisites

- C++17 compiler (GCC, Clang, MSVC)
- CMake (version 3.15 or higher)

### Build Steps

1.  **Create a build directory**:
    ```bash
    mkdir -p build
    cd build
    ```

2.  **Configure with CMake**:
    ```bash
    cmake ..
    ```

3.  **Build the project**:
    ```bash
    cmake --build .
    ```

### Running the Application

After building, you can run the main application:

```bash
./timeline_app
```

This will load the default timeline, display it on the console, and export it to `timeline.json`, `timeline.md`, `timeline.html`, and `timeline.csv`.

### Running Examples

```bash
# Run the simple example
./examples/simple_example

# Run the custom timeline example
./examples/custom_timeline
```

### Running Tests

To run the test suite:

```bash
ctest
```

Or run the test executable directly:

```bash
./tests/timeline_tests
```

## 📚 Documentation

To generate documentation with Doxygen:

1.  Install Doxygen.
2.  Run `doxygen Doxyfile` in the `cpp` directory (Doxyfile not included, but can be generated).

## 🛠️ CMake Options

- `BUILD_TESTS` (ON/OFF): Build the test suite.
- `BUILD_EXAMPLES` (ON/OFF): Build the example applications.
- `BUILD_SHARED_LIBS` (ON/OFF): Build as a shared library instead of static.

To configure these options:

```bash
cmake .. -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF
```

## 🤝 Contributing

Feel free to fork the repository and submit pull requests. For major changes, please open an issue first to discuss what you would like to change.
