#[=============================================================================[

Module TemplateFunction
=======================
Provides a template that can be used when creating a function.
Tested only on Linux Fedora 39.

The template is not for direct use, but can be tested using it as any function.

Steps of use:
  - copy the template to a new file
  - modify definition as needed
  - keep the check syntax error
  - add any specific logic at the end

For more information, see modules:
  - CheckSyntaxError
  - HandleErrorMessage
  - PrintMessage
  - SeekProgram (as an example of use)

Function template_function()
----------------------------
The template_function() is for a general purpose:
  - many keywords and groups
  - some keywords are optional, some are required
  - no-argument, single-argument, or multiple-arguments keywords

Syntax:
  template_function([(A0 B0 C0)] [(A1 B1 C1)] [(A2 B2 C2)] (A3 B3 C3)
                    [(A4 B4 C4) <arg>] [(A5 B5 C5) <arg>] (A6 B6 C6) <arg>
                    [(A7 B7 C7) <arg1> [<arg2> ...]]
                    [(A8 B8 C8) <arg1> [<arg2> ...]]
                    (A9 B9 C9) <arg1> [<arg2> ...])

  where:
    - keyword groups: (A0 B0 C0)...(A9 B9 C9)
      - keywords from same group are mutually exclusive, only one can be active
        (A0 or B0 or C0)...(A9 or B9 or C9)

    - keywords without arguments:
      - optional: [(A0 B0 C0)], [(A1 B1 C1)], [(A2 B2 C2)]
      - required: (A3 B3 C3)

    - keywords with a single argument:
      - optional: [(A4 B4 C4) <arg>], [(A5 B5 C5) <arg>]
      - required: (A6 B6 C6) <arg>

    - keywords with multiple arguments:
      - optional: [(A7 B7 C7) <arg1> [<arg2> ...]],
                  [(A8 B8 C8) <arg1> [<arg2> ...]]
      - required: (A9 B9 C9) <arg1> [<arg2> ...]

Example:
  cmake_minimum_required(VERSION 3.27)
  include("cmake/include/TemplateFunction.cmake")
  project(tester)

  template_function(C3 B6 arg A9 arg1 arg2 arg3)

  Output:
    TemplateFunction works, no syntax errors!

#]=============================================================================]

cmake_minimum_required(VERSION 3.27)

include("cmake/include/CheckSyntaxError.cmake")

#[=====================================[ ]=====================================]
function(template_function)
  #[==========================[ function definition ]==========================]
  set(kwd_pfx TEMPLATE_FUNCTION)

  set(kwd_id0 A0 B0 C0)
  set(kwd_id1 A1 B1 C1)
  set(kwd_id2 A2 B2 C2)
  set(kwd_id3 A3 B3 C3)
  set(kwd_id4 A4 B4 C4)
  set(kwd_id5 A5 B5 C5)
  set(kwd_id6 A6 B6 C6)
  set(kwd_id7 A7 B7 C7)
  set(kwd_id8 A8 B8 C8)
  set(kwd_id9 A9 B9 C9)
  set(kwd_idx 9)
  set(kwd_req 3 6 9)

  set(kwd_non_arg ${kwd_id0} ${kwd_id1} ${kwd_id2} ${kwd_id3})
  set(kwd_sng_arg ${kwd_id4} ${kwd_id5} ${kwd_id6})
  set(kwd_mlt_arg ${kwd_id7} ${kwd_id8} ${kwd_id9})

  cmake_parse_arguments(${kwd_pfx} "${kwd_non_arg}" "${kwd_sng_arg}"
                        "${kwd_mlt_arg}" ${ARGN})

  # all arguments parsed by function, the value itself is "${ARGN}" because if
  # ${ARGN} is used, empty arguments ("") are stripped and some checks may fail
  set(all_arg "${ARGN}")

  #[======================[ function check syntax error ]======================]
  check_syntax_error()

  #[========================[ function specific logic ]========================]
  print_message(DONE "TemplateFunction works, no syntax errors!")
endfunction()
