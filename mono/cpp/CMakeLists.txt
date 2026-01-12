cmake_minimum_required(VERSION 3.31)

project(dummy LANGUAGES CXX)

set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")

function(export_libraries)
  file(RELATIVE_PATH relative_path "${PROJECT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}")
  string(REPLACE "/" "__" internal_name "${relative_path}")
  string(REPLACE "/" "::" alias_name "${relative_path}")

  get_property(all_targets DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" PROPERTY BUILDSYSTEM_TARGETS)

  add_library(${internal_name} INTERFACE)
  add_library(${alias_name} ALIAS ${internal_name})

  target_include_directories(${internal_name} INTERFACE "${PROJECT_SOURCE_DIR}")

  foreach(t IN LISTS all_targets)
    get_target_property(t_type ${t} TYPE)
    if(t_type MATCHES ".*_LIBRARY")
      target_link_libraries(${internal_name} INTERFACE ${t})
    endif()
  endforeach()
endfunction()

function(add_all_subdirectories)
  file(GLOB_RECURSE all_cmakelists CONFIGURE_DEPENDS "*/CMakeLists.txt")
  list(FILTER all_cmakelists EXCLUDE REGEX "^${CMAKE_BINARY_DIR}")
  # list(FILTER all_cmakelists EXCLUDE REGEX "vcpkg_installed")

  foreach(cmakelists_path ${all_cmakelists})
    get_filename_component(subdir_abs_path ${cmakelists_path} DIRECTORY)
    file(RELATIVE_PATH relative_path "${PROJECT_SOURCE_DIR}" "${subdir_abs_path}")
    add_subdirectory(${relative_path})
  endforeach()
endfunction()

add_all_subdirectories()
