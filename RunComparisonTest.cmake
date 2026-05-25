# RunComparisonTest.cmake

# Run dcc with a given input and compare results of application output
# with file of expected results

# Execute the application with standard input/output redirection
execute_process(
    COMMAND "${APP_EXEC}"
    INPUT_FILE "${INPUT_FILE}"
    OUTPUT_FILE "${ACTUAL_OUTPUT}"
    ERROR_FILE "${ACTUAL_OUTPUT}" # Merges stderr into stdout, equivalent to &>
)

# Compare the output file with the expected file
execute_process(
    COMMAND "${CMAKE_COMMAND}" -E compare_files --ignore-eol "${ACTUAL_OUTPUT}" "${EXPECTED_FILE}"
    RESULT_VARIABLE COMPARE_RESULT
)

# Remove generated output file before exiting
if(EXISTS "${ACTUAL_OUTPUT}")
    file(REMOVE "${ACTUAL_OUTPUT}")
endif()

# Fail if the files do not match
if(NOT COMPARE_RESULT EQUAL 0)
    message(FATAL_ERROR "Files do not match!")
endif()