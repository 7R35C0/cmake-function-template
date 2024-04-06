#[=============================================================================[

Module HandleErrorMessage
=========================
Provides a function that handles the error messages for check_syntax_error()
defined in CheckSyntaxError module.
Tested only on Linux Fedora 39.

For more information, see modules:
  - TemplateFunction
  - CheckSyntaxError
  - PrintMessage
  - SeekProgram (as an example of use)

Function handle_error_message()
--------------------------------
Makes and sends the error messages for check_syntax_error() as needed.

Syntax:
  handle_error_message(<error_message_code> <error_message_tune>)

  where:
    <error_message_code>
      - required argument, the error message code
      - is a value that indicates a particular error message
      - the value must already be defined before it can be used
    <error_message_tune>
      - required argument, the error message tuning
      - is an attachment used to personalize a particular error message
      - the value represents a specific list, usually keywords or arguments
      - is not intended to make the error message itself, see the examples below
      - if an error message has no attachments, use any undefined variable

NOTE
  All examples illustrates just the concept of function, are not full examples.

Example:
  set(kwd_id0 A0 B0 C0)
  set(kwd_id1 A1 B1 C1)

  handle_error_message(0 NO_TUNE)
  handle_error_message(2 ${kwd_id0})
  handle_error_message(2 ${kwd_id1})

  Output:
    Undefined, unset, empty or space-only arguments
      arguments used cannot be:
      - a variable that is not defined (unset variable)
      - an empty variable or string ("")
      - a space-only variable or string ("   ")
    Missing required keywords
      some keywords are mandatory
      use only one of the keywords: A0, B0, C0
    Missing required keywords
      some keywords are mandatory
      use only one of the keywords: A1, B1, C1

#]=============================================================================]

cmake_minimum_required(VERSION 3.27)

include("cmake/PrintMessage.cmake")

#[=====================================[ ]=====================================]
function(handle_error_message error_message_code error_message_tune)
  #[========================[ function specific logic ]========================]
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
    set(err_msg
        "Not unique keywords" "keywords used cannot:" "- appears several times"
        "- belongs to the same group (are mutually exclusive)"
        "use only one of the keywords: ${err_msg_tun}")
  elseif(err_msg_cod STREQUAL 2)
    set(err_msg "Missing required keywords" "some keywords are mandatory"
                "use only one of the keywords: ${err_msg_tun}")
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
endfunction()
