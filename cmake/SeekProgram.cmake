#[=============================================================================[

Module SeekProgram
==================
Provides a function to checks if a program is installed on operating system and
works from terminal.
Tested only on Linux Fedora 39.

The module does not search for or use existing solutions from CMake, such as
FindGit, FindGLEW, and so on. If there are, use those modules, they are much
more specialized and safer than this one.

Module only checks if a program `<name>` is installed and commands `<name> -v`
or `<name> --version` works successfully in terminal. Locations where program
is searched are those defined by default in CMake find_program() function and
searching with dedicated paths is not possible.

For more information, see modules:
  - TemplateFunction
  - CheckSyntaxError
  - HandleErrorMessage
  - PrintMessage

Function seek_program()
-----------------------
Function uses the template_function() defined in TemplateFunction module.

NOTE
  In module, some parts of the code can be simplified, but for consistency with
  other modules, the original is kept with small exceptions.

Syntax:
  seek_program([REQUIRED] [EXACT] NAME <arg1> [arg2 ...])

  where:
    [REQUIRED]
      - optional keyword, if the program is required or not
      - if not a working program is found and keyword is:
        - present, errors occur (error messages)
        - absent, warnings occur (warning messages)
    [EXACT]
      - optional keyword, if the program name is searched exactly as it's or not
      - if keyword is:
        - present, is searched as written
        - absent, is searched as written and lowercase, Titlecase, UPPERCASE
    NAME <arg1> [arg2 ...]
      - required keyword with one or more required arguments, the program name
      - each argument represents a program name
      - leading and trailing spaces in arguments are removed

Example, assuming all programs are installed and working:
  cmake_minimum_required(VERSION 3.27)
  include("cmake/SeekProgram.cmake")
  project(tester)

  set(prg_nam git CMake cLANG Make)
  seek_program(NAME ${prg_nam})

  set(msg_txt)
  foreach(nam IN LISTS prg_nam)
    string(TOUPPER ${nam} nam)

    if(SEEK_${nam}_FOUND)
      list(
        APPEND msg_txt
        "${SEEK_${nam}_EXECUTABLE} ${SEEK_${nam}_VERSION} (${SEEK_${nam}_PATH})")
    endif()
  endforeach()

  print_message(VERBATIM INFO "Found programs:" ${msg_txt})

  Output:
    -- Looking for program names: git, Git, GIT
    -- Looking for program names: git, Git, GIT - done
          found program: git 2.44.0 (/usr/bin/git)
    -- Looking for program names: cmake, Cmake, CMAKE, CMake
    -- Looking for program names: cmake, Cmake, CMAKE, CMake - done
          found program: cmake 3.27.7 (/usr/bin/cmake)
    -- Looking for program names: clang, Clang, CLANG, cLANG
    -- Looking for program names: clang, Clang, CLANG, cLANG - done
          found program: clang 17.0.6 (/usr/lib64/ccache/clang)
    -- Looking for program names: make, Make, MAKE
    -- Looking for program names: make, Make, MAKE - done
          found program: make 4.4.1 (/usr/bin/make)
    Found programs:
      git 2.44.0 (/usr/bin/git)
      cmake 3.27.7 (/usr/bin/cmake)
      clang 17.0.6 (/usr/lib64/ccache/clang)
      make 4.4.1 (/usr/bin/make)

Usage for a general case:
  - we don't know anything about the programs (if not, go to next case)
      seek_program(NAME git CMake cLANG Make)
  - we know the correct form of names (recommended)
      seek_program(EXACT NAME git cmake clang make)
  - or if are required programs
      seek_program(REQUIRED EXACT NAME git cmake clang make)

Using function with EXACT option is a bit faster than without, especially if we
are searching for many programs. Without EXACT, function converts the given
names and searches in order for lowername, Titlename, UPPERNAME, and UsErsNAME
if it matters. However, if a name is found, it stops searching for that program
(clang is found, stop searching for Clang, CLANG or cLANG).

Function sets the following variables to the caller (PARENT_SCOPE) if and only
if all variables can exist, i.e. there is a valid program <name> executable,
version, and path:
  - SEEK_<NAME>_FOUND       (SEEK_CLANG_FOUND       TRUE)
  - SEEK_<NAME>_EXECUTABLE  (SEEK_CLANG_EXECUTABLE  clang)
  - SEEK_<NAME>_VERSION     (SEEK_CLANG_VERSION     17.0.6)
  - SEEK_<NAME>_PATH        (SEEK_CLANG_PATH        /usr/lib64/ccache/clang)

#]=============================================================================]

cmake_minimum_required(VERSION 3.27)

include("cmake/include/CheckSyntaxError.cmake")

#[=====================================[ ]=====================================]
function(seek_program)
  #[==========================[ function definition ]==========================]
  set(kwd_pfx SEEK_PROGRAM)

  set(kwd_id0 REQUIRED)
  set(kwd_id1 EXACT)
  set(kwd_id2 NAME)
  set(kwd_idx 2)
  set(kwd_req 2)

  set(kwd_non_arg ${kwd_id0} ${kwd_id1})
  set(kwd_sng_arg)
  set(kwd_mlt_arg ${kwd_id2})

  cmake_parse_arguments(${kwd_pfx} "${kwd_non_arg}" "${kwd_sng_arg}"
                        "${kwd_mlt_arg}" ${ARGN})

  # all arguments parsed by function, the value itself is "${ARGN}" because if
  # ${ARGN} is used, empty arguments ("") are stripped and some checks may fail
  set(all_arg "${ARGN}")

  #[======================[ function check syntax error ]======================]
  check_syntax_error()

  #[========================[ function specific logic ]========================]
  foreach(nam IN LISTS ${kwd_pfx}_NAME)
    string(STRIP ${nam} nam)
    set(prg_nam_lst ${nam})
    set(prg_nam ${nam})

    if(NOT ${kwd_pfx}_EXACT)
      set(prg_nam_lst)
      # lowercase name (clang, ...)
      string(TOLOWER ${nam} nam)
      list(APPEND prg_nam_lst ${nam})
      # Titlecase name (Clang, ...)
      string(SUBSTRING ${nam} 0 1 nam_hed)
      string(SUBSTRING ${nam} 1 -1 nam_til)
      string(TOUPPER ${nam_hed} nam_hed)
      string(CONCAT nam ${nam_hed} ${nam_til})
      list(APPEND prg_nam_lst ${nam})
      # UPPERCASE name (CLANG, ...)
      string(TOUPPER ${nam} nam)
      list(APPEND prg_nam_lst ${nam})
      # UsErsCASE name, if not exist yet (CLaNg, ...)
      if(NOT (prg_nam IN_LIST prg_nam_lst))
        list(APPEND prg_nam_lst ${prg_nam})
      endif()

      set(prg_nam)
      foreach(nam IN LISTS prg_nam_lst)
        string(JOIN ", " prg_nam ${prg_nam} ${nam})
      endforeach()
    endif()

    set(msg_txt "Looking for program names: ${prg_nam}")
    print_message(STATUS ${msg_txt})

    set(prg_pat)
    find_program(prg_pat NAMES ${prg_nam_lst} NO_CACHE)

    if(prg_pat STREQUAL prg_pat-NOTFOUND)
      # program not found error
      seek_program_hdl_err_msg(2 NO_TUNE)
    else()
      set(prg_exe)
      cmake_path(HAS_FILENAME prg_pat prg_exe)
      # set(prg_exe) # test for not a valid filename error

      if(prg_exe)
        cmake_path(GET prg_pat FILENAME prg_exe)

        set(prg_out)
        set(prg_err)
        execute_process(
          COMMAND ${prg_exe} -v
          OUTPUT_VARIABLE prg_out
          ERROR_VARIABLE prg_err
          OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_STRIP_TRAILING_WHITESPACE)

        if(NOT prg_out)
          execute_process(
            COMMAND ${prg_exe} -v
            COMMAND ${prg_exe} --version
            OUTPUT_VARIABLE prg_out
            ERROR_VARIABLE prg_err
            OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_STRIP_TRAILING_WHITESPACE)
        endif()

        if(prg_out)
          set(prg_ver)
          string(REGEX MATCH "[0-9][0-9.]*" prg_ver ${prg_out})
          # set(prg_ver) # test for not a valid program version error

          if(prg_ver)
            string(TOUPPER ${prg_exe} prg_nam)

            set(SEEK_${prg_nam}_FOUND
                TRUE
                PARENT_SCOPE)
            set(SEEK_${prg_nam}_EXECUTABLE
                ${prg_exe}
                PARENT_SCOPE)
            set(SEEK_${prg_nam}_VERSION
                ${prg_ver}
                PARENT_SCOPE)
            set(SEEK_${prg_nam}_PATH
                ${prg_pat}
                PARENT_SCOPE)

            print_message(VERBATIM STATUS_DONE "${msg_txt} - done"
                          "found program: ${prg_exe} ${prg_ver} (${prg_pat})")
          else()
            # not a valid program version error
            seek_program_hdl_err_msg(1 NO_TUNE)
          endif()
        elseif(prg_err)
          # program is not working error (program finished with message)
          seek_program_hdl_err_msg(3 NO_TUNE)
        else()
          # program is not working error
          seek_program_hdl_err_msg(4 NO_TUNE)
        endif()
      else()
        # not a valid filename error
        seek_program_hdl_err_msg(0 NO_TUNE)
      endif()
    endif()
  endforeach()
endfunction()

#[=====================================[ ]=====================================]
macro(seek_program_hdl_err_msg error_message_code error_message_tune)
  set(err_req)
  if(${kwd_pfx}_REQUIRED)
    set(err_req "this program is required")
  endif()

  set(err_exa)
  if(${kwd_pfx}_EXACT)
    set(err_exa
        "remove EXACT option to search for program names in lowercase, Titlecase, and UPPERCASE"
    )
  endif()

  set(err_msg_tun_lst ${error_message_tune} ${ARGN})
  set(err_msg_tun)
  if(err_msg_tun_lst)
    foreach(tun IN LISTS err_msg_tun_lst)
      string(JOIN ", " err_msg_tun ${err_msg_tun} ${tun})
    endforeach()
  endif()

  set(err_msg_cod ${error_message_code})
  if(err_msg_cod STREQUAL 0)
    cmake_path(GET CMAKE_CURRENT_FUNCTION_LIST_FILE STEM mod_nam)
    set(err_msg
        "${msg_txt} - fail" "not a valid filename" "found path: ${prg_pat}"
        "this error should not occur, check if:"
        "- module ${mod_nam} has code/logic errors")
    print_message(FATAL_ERROR ${err_msg})
  elseif(err_msg_cod STREQUAL 1)
    cmake_path(GET CMAKE_CURRENT_FUNCTION_LIST_FILE STEM mod_nam)
    set(err_msg
        "${msg_txt} - fail"
        "not a valid program version"
        "found program: ${prg_exe} (${prg_pat})"
        "this error should not occur, check if:"
        "- commands `${prg_exe} --version` or `${prg_exe} -v` exist"
        "- output from above commands has a version like xx.yy.zz"
        "- module ${mod_nam} has code/logic errors")
    print_message(FATAL_ERROR ${err_msg})
  elseif(err_msg_cod STREQUAL 2)
    set(err_msg
        "${msg_txt} - fail" "program not found, check if:"
        "- it's installed in default system locations"
        "- his path is in PATH system variable" ${err_exa} ${err_req})
  elseif(err_msg_cod STREQUAL 3)
    set(err_msg
        "${msg_txt} - fail" "found program: ${prg_exe} (${prg_pat})"
        "program is not working" ${err_req} "program finished with message:"
        ${prg_err})
  elseif(err_msg_cod STREQUAL 4)
    set(err_msg
        "${msg_txt} - fail"
        "found program: ${prg_exe} (${prg_pat})"
        "program is not working, check if:"
        "- has execute permissions for current user"
        "- its path is in PATH system variable"
        "- commands `${prg_exe} --version` or `${prg_exe} -v` exist"
        ${err_req})
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

  if(${kwd_pfx}_REQUIRED)
    print_message(FATAL_ERROR ${err_msg})
  else()
    print_message(STATUS_TRACK ${err_msg})
  endif()
endmacro()
