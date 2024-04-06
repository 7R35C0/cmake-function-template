#[=============================================================================[

Module CheckSyntaxError
=======================
Provides a function that checks for syntax errors a function which uses the
template_function() defined in TemplateFunction module.
Tested only on Linux Fedora 39.

For more information, see modules:
  - TemplateFunction
  - HandleErrorMessage
  - PrintMessage
  - SeekProgram (as an example of use)

Function check_syntax_error()
-----------------------------
The syntax errors checked are:
  - undefined, unset, empty or space-only arguments (see WARNING below)
  - not unique keywords
  - missing required keywords
  - not in syntax order keywords
  - missing keyword arguments
  - unparsed arguments

Syntax:
  check_syntax_error()

NOTE
  The function has no arguments, however function variables must already be
  defined before use.

WARNING
  For a function that uses template_function(), if the arguments are undefined,
  unset, or empty ("") variables, checks may fail to detect errors:
    cmake_minimum_required(VERSION 3.27)
    include("cmake/include/TemplateFunction.cmake")
    project(tester)

    #[[
    for these cases arg2 should not pass
    set(arg2 " ")   # OK
    set(arg2 "")    # NOT OK
    set(arg2)       # NOT OK
    undefined       # NOT OK
    #]]
    template_function(C3 B6 arg A9 arg1 ${arg2})

  To avoid such situations, enclose variables in double quotes, especially when
  you know nothing about them:
    cmake_minimum_required(VERSION 3.27)
    include("cmake/include/TemplateFunction.cmake")
    project(tester)

    #[[
    for these cases arg2 should not pass
    set(arg2 " ")   # OK
    set(arg2 "")    # OK
    set(arg2)       # OK
    undefined       # OK
    #]]
    template_function(C3 B6 arg A9 arg1 "${arg2}")

IMPORTANT
  For any function that uses template_function(), this function is required
  immediately after the definition so that syntax error check can be done
  before the specific logic.

#]=============================================================================]

cmake_minimum_required(VERSION 3.27)

include("cmake/include/HandleErrorMessage.cmake")

#[=====================================[ ]=====================================]
function(check_syntax_error)
  #[========================[ function specific logic ]========================]
  set(all_kwd)
  foreach(idx RANGE ${kwd_idx})
    list(APPEND all_kwd ${kwd_id${idx}})
  endforeach()

  # keywords in function parse order
  set(kwd_par)
  foreach(arg IN LISTS all_arg)
    if(arg IN_LIST all_kwd)
      list(APPEND kwd_par ${arg})
    else()
      if(arg)
        # for empty ("") or space-only ("   ") values the result is undefined
        string(STRIP ${arg} arg)
      endif()
      if(NOT arg)
        # undefined, unset, empty or space-only arguments error
        handle_error_message(0 NO_TUNE)
      endif()
    endif()
  endforeach()

  # keywords in function syntax order
  set(kwd_stx)
  foreach(idx RANGE ${kwd_idx})
    set(kwd_par_id${idx})
    foreach(kwd IN LISTS kwd_par)
      if(kwd IN_LIST kwd_id${idx})
        if(kwd_par_id${idx})
          # not unique keywords error
          handle_error_message(1 ${kwd_id${idx}})
        else()
          set(kwd_par_id${idx} ${kwd})
        endif()
      endif()
    endforeach()

    if((NOT kwd_par_id${idx}) AND (idx IN_LIST kwd_req))
      # missing required keywords error
      handle_error_message(2 ${kwd_id${idx}})
    endif()

    list(APPEND kwd_stx ${kwd_par_id${idx}})
  endforeach()

  foreach(par stx IN ZIP_LISTS kwd_par kwd_stx)
    if(NOT (par STREQUAL stx))
      # not in syntax order keywords error
      handle_error_message(3 ${stx})
    endif()
  endforeach()

  if(${kwd_pfx}_KEYWORDS_MISSING_VALUES)
    # missing keyword arguments error
    handle_error_message(4 ${${kwd_pfx}_KEYWORDS_MISSING_VALUES})
  endif()

  if(${kwd_pfx}_UNPARSED_ARGUMENTS)
    # unparsed arguments error
    handle_error_message(5 ${${kwd_pfx}_UNPARSED_ARGUMENTS})
  endif()
endfunction()
