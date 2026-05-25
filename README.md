# compiler-dcc
A compiler for the "Decaf" programming language.

Projects based on Stanford's CS143 - Intro to Compilers, 2012 (http://web.stanford.edu/class/archive/cs/cs143/cs143.1128/)

Scanner uses Fast Lexical Anaylzer (FLEX)

Project is configured to create all build artifacts in `build` directory after running `cmake` command

To compile:
`cmake -S . -B build && cmake --build build`

To run:
`./build/dcc < {INPUTFILE}`

e.g. `./build/dcc < samples/badident.frag`

To execute tests:
`cmake -S . -B build && cmake --build build` && ctest --test-dir build --output-on-failure
