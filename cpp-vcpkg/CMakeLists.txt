cmake_minimum_required(VERSION 3.16)

set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")

project(LANGUAGES CXX)

find_package(Crow CONFIG REQUIRED)
find_package(fmt CONFIG REQUIRED)

add_library(MyStr ./src/my_str.cc ./src/my_str.h)

add_executable(main_http ./src/main_http.cc)
target_link_libraries(main_http MyStr Crow::Crow fmt::fmt)
