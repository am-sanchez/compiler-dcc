# compiler-dcc
A compiler for the "Decaf" programming language.

Projects based on Stanford's CS143 - Intro to Compilers, 2012 (http://web.stanford.edu/class/archive/cs/cs143/cs143.1128/)

## Enhancements to Original Project
I've updated the original assigment files to also:
* Use C++
    * Including modern C++ STL constructs like Smart Pointers
    * Original project files were entirely in C
* Utilize CMake to
    * Simplify compilation commands
    * Automate Tests
        * Place original assignment project's test files into a directory and write CTest cases to invoke `dcc` application with input files and compare against files of expected output (provided by original assignment author)
    * Add Cross-platform support
* Utilize CI/CD (Github actions)
    * Cross-platform support
        * Project compiles and successfully executes automated tests on Windows, Linux, and Mac
        * TODO - archive artifacts

## CMake File
* Invokes FLEX to take in src/scanner.l and output to src/lex.yy.cc
* Compiles src/main.cc to create `dcc` executable

## Scanner
* Scanner uses Fast Lexical Anaylzer (FLEX)
* **My contributions to "complete the assignment" for this section only update the FLEX scanner input file located at src/scanner.l**
* All other files and code (outside of CMake) were distributed as part of original assignment project
    * **Note**: Minor changes were made to some source files to transition project to C++17 and make use of STL Smart Pointers

## Building and Running
This project is configured to create all build artifacts in `build` directory after running `cmake` command

To compile:
`cmake -S . -B build && cmake --build build`

To run:
`./build/dcc < {INPUTFILE}`

- e.g. `./build/dcc < samples/badident.frag`

To execute tests:
`cmake -S . -B build && cmake --build build && ctest --test-dir build --output-on-failure`
