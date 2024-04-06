#[=============================================================================[

Module MakeCMakeUserPresets
===========================
Provides a function to create a CMakeUserPresets.json file.
Tested only on Linux Fedora 39.

For more information, see modules:
  - HandleErrorMessage
  - PrintMessage

Function make_cmake_user_presets()
----------------------------------
Creates CMakeUserPresets.json file which is intended for developers to specify
their own local build details.

Syntax:
  make_cmake_user_presets()

Function has no arguments, but some conditions must be met to create the file:
  - CMakePresets.json file exist in project root directory
  - MakeCMakeUserPresets.json file exist in modules directory (cmake)
  - CMakeUserPresets.json file does not exist in project root directory
  - Ninja and/or Clang programs are installed on system and works from terminal

If any of these conditions are not met, the CMakeUserPresets.json file will no
longer be created.

The function does not impose specific build details, however a correlation of
these in CMakePresets.json and MakeCMakeUserPresets.json files is recommended.
File MakeCMakeUserPresets.json is a template for future CMakeUserPresets.json
file, just as <file_name>.h.in is for a <file_name>.h file.

For simplicity and because they are often used, following presets are used in:
  - CMakePresets.json:
    - base    - base inherited by other presets, it's hidden
    - debug   - with debug info, code or asserts, but no optimization
    - release - with speed optimization, but no debug info, code or asserts
    - relinfo - with some optimization, debug info, but no debug code or asserts
    - relsize - with size optimization, but no debug info, code or asserts
  - MakeCMakeUserPresets.json:
    - user-base, user-debug, user-release, user-relinfo, user-relsize
    - all are equivalent with the above presets

See above files for more information about variables used in configurations and
their relationships (inherits).

File CMakePresets.json does not enforce a specific generator or compiler for
its presets, the default system options are used. However, if Ninja generator
and/or Clang compiler are found (works), they are used in CMakeUserPresets.json
file, for user presets.

IMPORTANT
  In all preset files there is a MAKE_CMAKE_USER_PRESETS variable with values:
  - ON in CMakePresets.json
  - OFF in MakeCMakeUserPresets.json and CMakeUserPresets.json if file was made

  This variable can be used in conjunction with `--preset` cmake command option
  to skip using function in CMakeLists.txt file. However, for CMakePresets.json
  the value must be manually set to OFF after creating CMakeUserPresets.json
  file (warnings can become annoying for default presets).

  The variable is not used or tested in module code.

#]=============================================================================]

cmake_minimum_required(VERSION 3.27)

include("cmake/SeekProgram.cmake")

#[=====================================[ ]=====================================]
function(make_cmake_user_presets)
  #[========================[ function specific logic ]========================]
  set(msg_txt "Making user presets")
  print_message(STATUS ${msg_txt})

  set(prj_pat ${CMAKE_SOURCE_DIR})

  if(NOT (EXISTS ${prj_pat}/CMakePresets.json))
    make_cmake_user_presets_hdl_err_msg(0 NO_TUNE)
  elseif(NOT (EXISTS ${prj_pat}/cmake/MakeCMakeUserPresets.json))
    make_cmake_user_presets_hdl_err_msg(1 NO_TUNE)
  elseif(EXISTS ${prj_pat}/CMakeUserPresets.json)
    make_cmake_user_presets_hdl_err_msg(2 NO_TUNE)
  else()
    seek_program(EXACT NAME ninja clang clang++)

    if((NOT SEEK_NINJA_FOUND)
       AND (NOT SEEK_CLANG_FOUND)
       AND (NOT SEEK_CLANG++_FOUND))
      make_cmake_user_presets_hdl_err_msg(3 NO_TUNE)
    else()
      set(msg_txt "${msg_txt} - done" "user presets configuration:")

      if(SEEK_NINJA_FOUND)
        set(USER_GENERATOR "Ninja")
        list(
          APPEND
          msg_txt
          "- generator: ${SEEK_NINJA_EXECUTABLE} ${SEEK_NINJA_VERSION} (${SEEK_NINJA_PATH})"
        )
      else()
        set(USER_GENERATOR)
        list(APPEND msg_txt "- generator: ninja not found, keep system default")
      endif()

      if(SEEK_CLANG_FOUND)
        set(USER_C_COMPILER "clang")
        list(
          APPEND
          msg_txt
          "- C compiler: ${SEEK_CLANG_EXECUTABLE} ${SEEK_CLANG_VERSION} (${SEEK_CLANG_PATH})"
        )
      else()
        set(USER_C_COMPILER)
        list(APPEND msg_txt
             "- C compiler: clang not found, keep system default")
      endif()

      if(SEEK_CLANG++_FOUND)
        set(USER_CXX_COMPILER "clang++")
        list(
          APPEND
          msg_txt
          "- C++ compiler: ${SEEK_CLANG++_EXECUTABLE} ${SEEK_CLANG++_VERSION} (${SEEK_CLANG++_PATH})"
        )
      else()
        set(USER_CXX_COMPILER)
        list(APPEND msg_txt
             "- C++ compiler: clang++ not found, keep system default")
      endif()

      configure_file(${CMAKE_SOURCE_DIR}/cmake/MakeCMakeUserPresets.json
                     ${CMAKE_SOURCE_DIR}/CMakeUserPresets.json @ONLY)

      list(
        APPEND msg_txt
        "use user presets: user-debug, user-release, user-relinfo, user-relsize"
      )
      print_message(STATUS_DONE ${msg_txt})
    endif()
  endif()
endfunction()

#[=====================================[ ]=====================================]
macro(make_cmake_user_presets_hdl_err_msg error_message_code error_message_tune)
  set(err_msg_tun_lst ${error_message_tune} ${ARGN})
  set(err_msg_tun)
  if(err_msg_tun_lst)
    foreach(tun IN LISTS err_msg_tun_lst)
      string(JOIN ", " err_msg_tun ${err_msg_tun} ${tun})
    endforeach()
  endif()

  set(err_msg_cod ${error_message_code})
  if(err_msg_cod STREQUAL 0)
    set(err_msg
        "${msg_txt} - fail" "file CMakePresets.json not found"
        "project path: ${prj_pat}" "check if file exists in project path")
  elseif(err_msg_cod STREQUAL 1)
    set(err_msg
        "${msg_txt} - fail" "file MakeCMakeUserPresets.json not found"
        "modules path: ${prj_pat}/cmake" "check if file exists in modules path")
  elseif(err_msg_cod STREQUAL 2)
    set(err_msg
        "${msg_txt} - fail" "found CMakeUserPresets.json file"
        "project path: ${prj_pat}" "file already exists in project path")
  elseif(err_msg_cod STREQUAL 3)
    set(err_msg
        "${msg_txt} - fail"
        "none of programs ninja, clang, or clang++ were found"
        "making user presets is unnecessary"
        "use default presets: debug, release, relinfo, relsize")
  else()
    cmake_path(GET CMAKE_CURRENT_FUNCTION_LIST_FILE STEM mod_nam)
    set(err_msg
        "Not a valid error message code"
        "found code: ${err_msg_cod}"
        "code must be defined before it can be used"
        "each code represents a specific error message"
        "check if module ${mod_nam} has code/logic errors")
    print_message(FATAL_ERROR ${err_msg})
  endif()

  print_message(STATUS_TRACK ${err_msg})
endmacro()
