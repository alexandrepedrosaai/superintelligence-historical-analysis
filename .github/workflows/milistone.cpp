name: C/C++ CI

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Install C++ build dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y build-essential cmake

      - name: Configure CMake
        working-directory: stickler-protocol
        run: |
          mkdir -p build
          cd build
          cmake ..

      - name: Build all executables
        working-directory: stickler-protocol/build
        run: make

      - name: Verify build artifacts
        working-directory: stickler-protocol/build
        run: |
          echo "Built executables:"
