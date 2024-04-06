cmake_minimum_required(VERSION 3.27)
include("cmake/MakeCMakeUserPresets.cmake")

if(MAKE_CMAKE_USER_PRESETS)
  make_cmake_user_presets()
endif()

project(
  tester
  VERSION 0.0.0
  LANGUAGES C CXX)

add_executable(tester source/tester.cpp)

print_message(STATUS_INFO "Project Tester works!")
