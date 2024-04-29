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