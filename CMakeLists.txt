cmake_minimum_required(VERSION 3.5)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")
message("CMake Modules: ${CMAKE_MODULE_PATH}")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set( project_name "dcc" )
message("Project Name: ${project_name}")
project(${project_name})
find_package(FLEX)
FLEX_TARGET(MyScanner scanner.l  ${CMAKE_CURRENT_BINARY_DIR}/lex.yy.cc COMPILE_FLAGS -Ld)

include_directories(${CMAKE_CURRENT_BINARY_DIR}/include/)
include_directories(${CMAKE_CURRENT_BINARY_DIR}/)
add_executable(${project_name}
   src/main.cc
   src/errors.cc
   src/utility.cc
   ${FLEX_MyScanner_OUTPUTS}
)

# Enable CTest
enable_testing()

# Helper function to add a test case
# Optional 4th argument: EXPECT_SCAN_ERROR (Defaults to FALSE if not provided)
function(add_comparison_test TEST_NAME INPUT_FILE EXPECTED_FILE)
    set(ACTUAL_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${TEST_NAME}_actual.txt")

    # Check if a 4th argument was passed, otherwise default to FALSE
    if(${ARGC} GREATER 3)
        set(EXPECT_SCAN_ERROR ${ARGV3})
    else()
        set(EXPECT_SCAN_ERROR FALSE)
    endif()

    # Pass the native OS-configured paths and EXPECT_SCAN_ERROR into the script
    add_test(NAME ${TEST_NAME}-comparison
             COMMAND ${CMAKE_COMMAND}
             -D APP_EXEC=$<TARGET_FILE:${PROJECT_NAME}>
             -D INPUT_FILE=${CMAKE_CURRENT_SOURCE_DIR}/samples/${INPUT_FILE}
             -D ACTUAL_OUTPUT=${ACTUAL_OUTPUT}
             -D EXPECTED_FILE=${CMAKE_CURRENT_SOURCE_DIR}/samples/${EXPECTED_FILE}
             -P "${CMAKE_CURRENT_SOURCE_DIR}/RunComparisonTest.cmake"
    )
    add_test(NAME ${TEST_NAME}-exitcode
            COMMAND ${CMAKE_COMMAND}
            -D APP_EXEC=$<TARGET_FILE:${PROJECT_NAME}>
            -D INPUT_FILE=${CMAKE_CURRENT_SOURCE_DIR}/samples/${INPUT_FILE}
            -D EXPECT_SCAN_ERROR=${EXPECT_SCAN_ERROR}
            -P "${CMAKE_CURRENT_SOURCE_DIR}/RunExitCodeTest.cmake"
    )
endfunction()


# (Omitted 4th argument defaults to FALSE -> expects exit code 0)

add_comparison_test(Case1-program2 program2.decaf program2.out)
add_comparison_test(Case2-program3 program3.decaf program3.out)

# For tests that check lexical errors (e.g., badbool, baddouble),
# append TRUE as the 4th argument if your scanner is designed to exit with an error code.
add_comparison_test(Case3-badbool badbool.frag badbool.out)
add_comparison_test(Case4-baddouble baddouble.frag baddouble.out)
add_comparison_test(Case5-badident badident.frag badident.out TRUE)
add_comparison_test(Case6-badint badint.frag badint.out)
add_comparison_test(Case7-badop badop.frag badop.out TRUE)
add_comparison_test(Case10-badpre badpre.frag badpre.out TRUE)
add_comparison_test(Case11-badreserve badreserve.frag badreserve.out)
add_comparison_test(Case12-badstring badstring.frag badstring.out TRUE)

# Happy path tests (expects exit code 0)
add_comparison_test(Case13-comment comment.frag comment.out)
add_comparison_test(Case14-ident ident.frag ident.out)
add_comparison_test(Case15-number number.frag number.out)
add_comparison_test(Case16-reserve_op reserve_op.frag reserve_op.out)
add_comparison_test(Case17-string string.frag string.out)
