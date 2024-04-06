#[=============================================================================[

Module PrintMessage
===================
Provides a function to print a formatted message text in terminal.
Tested only on Linux Fedora 39.

Module uses CMake message() function and keeps his options for convenience.

The keyword-color_code pairs used in both functions:

  |    keyword     | color_code | print_message() | message() |
  | :------------: | :--------: | :-------------: | :-------: |
  |  FATAL_ERROR   |     31     |       Red       |    Red    |
  |   SEND_ERROR   |     31     |       Red       |    Red    |
  |    WARNING     |     33     |     Yellow      |  Yellow   |
  | AUTHOR_WARNING |     33     |     Yellow      |  Yellow   |
  |  DEPRECATION   |     37     |      White      |   White   |
  |     NOTICE     |     37     |      White      |   White   |
  |     STATUS     |     37     |      White      |   White   |
  |    VERBOSE     |     34     |      Blue       |   White   |
  |     DEBUG      |     35     |     Magenta     |   White   |
  |     TRACE      |     37     |      White      |   White   |
  |      INFO      |     36     |      Cyan       |   None    |
  |  STATUS_INFO   |     36     |      Cyan       |   None    |
  |      DONE      |     32     |      Green      |   None    |
  |  STATUS_DONE   |     32     |      Green      |   None    |
  |     TRACK      |     33     |     Yellow      |   None    |
  |  STATUS_TRACK  |     33     |     Yellow      |   None    |
  |      FAIL      |     31     |       Red       |   None    |
  |  STATUS_FAIL   |     31     |       Red       |   None    |

For more about colors and styles, see:
  - https://en.wikipedia.org/wiki/ANSI_escape_code
  - https://stackoverflow.com/questions/18968979/how-to-make-colorized-message-with-cmake

For more information, see modules:
  - TemplateFunction
  - CheckSyntaxError
  - HandleErrorMessage

Function print_message()
------------------------
The code behind this function is the same as when using template_function()
defined in TemplateFunction module:
  - definition
  - check syntax error
    - handle error message
      - print message
  - specific logic

NOTE
  Unfortunately, the function cannot use that template because it would end up
  in an infinite check-handle-print loop. For this reason all function code
  is in this module, no includes, no loops.
  In module, some parts of the code can be simplified, but for consistency with
  other modules, the original is kept with small exceptions.

Syntax:
  print_message([VERBATIM] <TYPE> <arg1> [arg2 ...])

  where:
    [VERBATIM]
      - optional keyword, the message brevity
      - depending on how `--log-level` option is used, a message text can be:
        - short if option is not VERBOSE or used, first line of text only
        - long if option is VERBOSE, all lines of text
      - if keyword is:
        - absent, previous rules are respected
        - present, message will always be long, previous rules are ignored
    <TYPE>
      - required keyword, the message type
      - can be only one of the keywords:
          FATAL_ERROR, SEND_ERROR, WARNING, AUTHOR_WARNING, DEPRECATION, NOTICE,
          STATUS, VERBOSE, DEBUG, TRACE, INFO, STATUS_INFO, DONE, STATUS_DONE,
          TRACK, STATUS_TRACK, FAIL, STATUS_FAIL
      - all keywords are mutually exclusive, only one can be active at a time
      - a STATUS_<NAME> keyword is like a <NAME> keyword, but has `--` in front
        of the first line of text, like STATUS option in message() function
      - the TRACK keyword defines a state of "something" between DONE and FAIL,
        is not done and this fact is not a failure, track this "something"
      - all new keywords define informational messages, just print the message
      - for an active message use old keywords, they can do more than just
        print a message (FATAL_ERROR stop processing and generation, and so on)
    <arg1> [arg2 ...]
      - one or more required arguments, the message text
      - each argument represents a message text line in terminal
      - leading and trailing spaces in arguments are removed

Example:
  cmake_minimum_required(VERSION 3.27)
  include("cmake/PrintMessage.cmake")
  project(tester)

  set(msg_txt "First text line" "          Second text line          "
              "          Another text line" "Last text line          ")

  print_message(WARNING ${msg_txt})

  Output for `cmake -S . -B build` command (short message):
    CMake Warning at cmake/PrintMessage.cmake:323 (message):
      First text line
    Call Stack (most recent call first):
      CMakeLists.txt:8 (print_message)

  Output for `cmake -S . -B build --log-level VERBOSE` command (long message):
    CMake Warning at cmake/PrintMessage.cmake:323 (message):
      First text line

        Second text line
        Another text line
        Last text line
    Call Stack (most recent call first):
      CMakeLists.txt:8 (print_message)

Example:
  print_message(VERBATIM STATUS_INFO ${msg_txt})

  Output (message will always be long):
    -- First text line
         Second text line
         Another text line
         Last text line

Function does not impose a maximum number of characters for a line of text,
however a maximum of 75 characters leads to a good result.

More specific use cases:
  - a list of items:
      set(msg_txt
          "First text line"
          "Second text line:"
          "- first"
          "- second"
          "- last"
          "Another text line"
          "Last text line")

      print_message(VERBATIM STATUS_DONE ${msg_txt})

      Output:
        -- First text line
             Second text line:
             - first
             - second
             - last
             Another text line
             Last text line

  - nested lists/items and a variable:
    - this example use `|` character to keep the indentation
    - text is printed with the evaluated variable (${second_line})
        set(second_line "Second text line:")
        set(msg_txt
            "First text line"
            ${second_line}
            "|  - first:"
            "|    - second:"
            "|      - last"
            "Another text line"
            "Last text line")

        print_message(VERBATIM STATUS_TRACK ${msg_txt})

        Output:
          -- First text line
               Second text line:
               |  - first:
               |    - second:
               |      - last
               Another text line
               Last text line

    NOTE
      It doesn't look too bad (imo ofc) and is much simpler than the code for
      all message options.

  - nested lists/items and a variable:
    - this example requires more care in manually formatting the message text
    - text is printed as is and any variable in text cannot be evaluated
        set(second_line "Second text line:")
        set(msg_txt
            [=[
          First text line
            ${second_line}
              1 ...
              2 ...
                2.1 ...
                  2.1.1 ...
                  2.1.2 ...
                  2.1.3 ...
            Another text line
          Last text line
            ]=])

        print_message(VERBATIM STATUS_FAIL ${msg_txt})

        Output:
          -- First text line
               ${second_line}
                 1 ...
                 2 ...
                   2.1 ...
                     2.1.1 ...
                     2.1.2 ...
                     2.1.3 ...
               Another text line
             Last text line

    NOTE
      The evaluation of variable (${second_line}) is just a text like any other.

    WARNING
      Automatic code formatting, from the code editor, may break all the manual
      formatting and must be redone. It happens very rarely and it's hard to
      see why the message doesn't looks like we want.

IMPORTANT
  Function handles its error messages with itself, is a recursive function.
  Changing its code can lead to infinite loops (CMake stops after 1000 loops).

#]=============================================================================]

cmake_minimum_required(VERSION 3.27)

#[=====================================[ ]=====================================]
function(print_message)
  #[==========================[ function definition ]==========================]
  set(kwd_pfx PRINT_MESSAGE)

  set(kwd_old
      FATAL_ERROR
      SEND_ERROR
      WARNING
      AUTHOR_WARNING
      DEPRECATION
      NOTICE
      STATUS
      VERBOSE
      DEBUG
      TRACE)
  set(kwd_new
      INFO
      STATUS_INFO
      DONE
      STATUS_DONE
      TRACK
      STATUS_TRACK
      FAIL
      STATUS_FAIL)

  set(kwd_id0 VERBATIM)
  set(kwd_id1 ${kwd_old} ${kwd_new})
  set(kwd_idx 1)
  set(kwd_req 1)

  set(kwd_non_arg ${kwd_id0})
  set(kwd_sng_arg)
  set(kwd_mlt_arg ${kwd_id1})

  cmake_parse_arguments(${kwd_pfx} "${kwd_non_arg}" "${kwd_sng_arg}"
                        "${kwd_mlt_arg}" ${ARGN})

  # all arguments parsed by function, the value itself is "${ARGN}" because if
  # ${ARGN} is used, empty arguments ("") are stripped and some checks may fail
  set(all_arg "${ARGN}")

  #[======================[ function check syntax error ]======================]
  print_message_chk_syn_err()

  #[========================[ function specific logic ]========================]
  foreach(kwd IN LISTS kwd_id1)
    if(${kwd_pfx}_${kwd})
      set(msg_typ ${kwd})
      break()
    endif()
  endforeach()

  # keywords with special formatting
  set(kwd_old_fmt STATUS VERBOSE DEBUG TRACE)
  set(kwd_new_fmt STATUS_INFO STATUS_DONE STATUS_TRACK STATUS_FAIL)
  if((msg_typ IN_LIST kwd_old_fmt) OR (msg_typ IN_LIST kwd_new_fmt))
    set(msg_fmt "\n     ")
  else()
    set(msg_fmt "\n  ")
  endif()

  set(msg_txt)
  cmake_language(GET_MESSAGE_LOG_LEVEL CMAKE_MESSAGE_LOG_LEVEL)
  if(NOT ((CMAKE_MESSAGE_LOG_LEVEL STREQUAL VERBOSE) OR ${kwd_pfx}_VERBATIM))
    # short message, only first line of message text
    list(GET ${kwd_pfx}_${msg_typ} 0 msg_txt)
    string(STRIP ${msg_txt} msg_txt)
  else()
    # long message, all lines of message text
    foreach(txt IN LISTS ${kwd_pfx}_${msg_typ})
      string(STRIP ${txt} txt)
      string(JOIN ${msg_fmt} msg_txt ${msg_txt} ${txt})
    endforeach()
  endif()
  if(msg_typ IN_LIST kwd_new_fmt)
    string(PREPEND msg_txt "-- ")
  endif()

  # may be colors works in Windows (untested)
  if(NOT WIN32)
    string(ASCII 27 esc)
    if(${kwd_pfx}_VERBOSE)
      string(CONCAT msg_txt ${esc}[0;34m ${msg_txt} ${esc}[0m) # blue
    elseif(${kwd_pfx}_DEBUG)
      string(CONCAT msg_txt ${esc}[0;35m ${msg_txt} ${esc}[0m) # magenta
    elseif(${kwd_pfx}_INFO OR ${kwd_pfx}_STATUS_INFO)
      string(CONCAT msg_txt ${esc}[0;36m ${msg_txt} ${esc}[0m) # cyan
    elseif(${kwd_pfx}_DONE OR ${kwd_pfx}_STATUS_DONE)
      string(CONCAT msg_txt ${esc}[0;32m ${msg_txt} ${esc}[0m) # green
    elseif(${kwd_pfx}_TRACK OR ${kwd_pfx}_STATUS_TRACK)
      string(CONCAT msg_txt ${esc}[0;33m ${msg_txt} ${esc}[0m) # yellow
    elseif(${kwd_pfx}_FAIL OR ${kwd_pfx}_STATUS_FAIL)
      string(CONCAT msg_txt ${esc}[0;31m ${msg_txt} ${esc}[0m) # red
    endif()
  endif()

  if(msg_typ IN_LIST kwd_new)
    message(NOTICE ${msg_txt})
  else()
    message(${msg_typ} ${msg_txt})
  endif()
endfunction()

#[=====================================[ ]=====================================]
macro(print_message_chk_syn_err)
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
        print_message_hdl_err_msg(0 NO_TUNE)
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
          print_message_hdl_err_msg(1 NO_TUNE)
        else()
          set(kwd_par_id${idx} ${kwd})
        endif()
      endif()
    endforeach()

    if((NOT kwd_par_id${idx}) AND (idx IN_LIST kwd_req))
      # missing required keywords error
      print_message_hdl_err_msg(2 NO_TUNE)
    endif()

    list(APPEND kwd_stx ${kwd_par_id${idx}})
  endforeach()

  foreach(par stx IN ZIP_LISTS kwd_par kwd_stx)
    if(NOT (par STREQUAL stx))
      # not in syntax order keywords error
      print_message_hdl_err_msg(3 ${stx})
    endif()
  endforeach()

  if(${kwd_pfx}_KEYWORDS_MISSING_VALUES)
    # missing keyword arguments error
    print_message_hdl_err_msg(4 ${${kwd_pfx}_KEYWORDS_MISSING_VALUES})
  endif()

  if(${kwd_pfx}_UNPARSED_ARGUMENTS)
    # unparsed arguments error
    print_message_hdl_err_msg(5 ${${kwd_pfx}_UNPARSED_ARGUMENTS})
  endif()
endmacro()

#[=====================================[ ]=====================================]
macro(print_message_hdl_err_msg error_message_code error_message_tune)
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
        "Undefined, unset, empty or space-only arguments"
        "arguments used cannot be:"
        "- a variable that is not defined (unset variable)"
        "- an empty variable or string (\"\")"
        "- a space-only variable or string (\"   \")")
  elseif(err_msg_cod STREQUAL 1)
    # there are too many keywords and the result is a long line of text, so
    # we'll use NO_TUNE and a dedicated text formatting
    set(err_msg
        "Not unique keywords"
        "keywords used cannot:"
        "- appears several times"
        "- belongs to the same group (are mutually exclusive)"
        "use only one of the keywords:"
        "FATAL_ERROR, SEND_ERROR, WARNING, AUTHOR_WARNING, DEPRECATION,"
        "NOTICE, STATUS, VERBOSE, DEBUG, TRACE, INFO, STATUS_INFO, DONE,"
        "STATUS_DONE, TRACK, STATUS_TRACK, FAIL, STATUS_FAIL")
  elseif(err_msg_cod STREQUAL 2)
    # same as above case
    set(err_msg
        "Missing required keywords"
        "some keywords are mandatory"
        "use only one of the keywords:"
        "FATAL_ERROR, SEND_ERROR, WARNING, AUTHOR_WARNING, DEPRECATION,"
        "NOTICE, STATUS, VERBOSE, DEBUG, TRACE, INFO, STATUS_INFO, DONE,"
        "STATUS_DONE, TRACK, STATUS_TRACK, FAIL, STATUS_FAIL")
  elseif(err_msg_cod STREQUAL 3)
    set(err_msg
        "Not in syntax order keywords"
        "order of keywords used must be the order from syntax"
        "check these keywords: ${err_msg_tun}")
  elseif(err_msg_cod STREQUAL 4)
    set(err_msg "Missing keyword arguments" "some keywords require arguments"
                "check these keywords: ${err_msg_tun}")
  elseif(err_msg_cod STREQUAL 5)
    set(err_msg "Unparsed arguments" "some arguments are in a wrong position"
                "check these arguments: ${err_msg_tun}")
  else()
    cmake_path(GET CMAKE_CURRENT_FUNCTION_LIST_FILE STEM mod_nam)
    set(err_msg
        "Not a valid error message code"
        "found code: ${err_msg_cod}"
        "code must be defined before it can be used"
        "each code represents a specific error message"
        "check if module ${mod_nam} has code/logic errors")
  endif()

  print_message(FATAL_ERROR ${err_msg})
endmacro()
