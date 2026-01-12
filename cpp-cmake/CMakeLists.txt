cmake_minimum_required(VERSION 3.31)

project(dummy LANGUAGES CXX)

set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")

include(FetchContent)

FetchContent_Declare(
  Crow
  GIT_REPOSITORY https://github.com/CrowCpp/Crow
  GIT_TAG        v1.3.0
  GIT_SHALLOW    TRUE
)

FetchContent_Declare(
  fmt
  GIT_REPOSITORY https://github.com/fmtlib/fmt
  GIT_TAG        12.1.0
  GIT_SHALLOW    TRUE
)

FetchContent_MakeAvailable(Crow fmt)

add_library(MyStr ./src/my_str.cc ./src/my_str.h)

add_executable(main ./src/main.cc)
target_link_libraries(main MyStr Crow::Crow fmt::fmt)
