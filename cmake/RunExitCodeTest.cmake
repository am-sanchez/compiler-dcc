# Run application with standard input/output redirection
execute_process(
    COMMAND "${APP_EXEC}"
    INPUT_FILE "${INPUT_FILE}"
    RESULT_VARIABLE ret
)

# Validate return code based on EXPECT_SCAN_EXIT boolean
if(EXPECT_SCAN_ERROR)
    # If TRUE, we expect a non-zero exit code. Fail if it IS zero.
    if(ret EQUAL 0)
        message(FATAL_ERROR "Test failed: Expected a non-zero exit code, but got 0.")
    endif()
else()
    # If FALSE, we expect a zero exit code. Fail if it is NOT zero.
    if(NOT ret EQUAL 0)
        message(FATAL_ERROR "Test failed: Expected 0, but got return code: ${ret}")
    endif()
endif()
