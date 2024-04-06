## README

The repo provides a template that can be used when creating a CMake function.

Module used are, in logic order:

- TemplateFunction - the template definition
- CheckSyntaxError - checking for syntax errors
- HandleErrorMessage - error message handling
- PrintMessage - printing messages in terminal

Steps of use:

- copy the template to a new file
- modify definition as needed
- keep the check syntax error
- add any specific logic at the end

Each module (file) has a detailed description at the beginning.
All modules are tested on Linux Fedora 39 only.

### TemplateFunction module

A template that can be used when creating a function.
The template is not for direct use, but can be tested using it as any function.

Template has a general purpose:

- many keywords and groups
- some keywords are optional, some are required
- no-argument, single-argument, or multiple-arguments keywords

### CheckSyntaxError module

Checks for syntax errors a function which uses the template.

The syntax errors checked are:

- undefined, unset, empty or space-only arguments
- not unique keywords
- missing required keywords
- not in syntax order keywords
- missing keyword arguments
- unparsed arguments

### HandleErrorMessage module

Handles syntax checking error messages with an error code.
Each code indicates a specific message and must be defined before use.

### PrintMessage module

Print a formatted message text in terminal.
Module uses message() function and keeps his options for convenience.

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

### SeekProgram module

Checks if a program is installed on operating system and works from terminal.

The module does not search for or use existing solutions from CMake, such as
FindGit, FindGLEW, and so on. If there are, use those modules, they are much
more specialized and safer than this one.

Module only checks if a program `<name>` is installed and commands `<name> -v`
or `<name> --version` works in terminal. The search locations are those defined
by default in find_program() function, and searching with specific paths is not
possible.

### MakeCMakeUserPresets module

Create a CMakeUserPresets.json file in project root directory.

Some conditions must be met to create the file:

- CMakePresets.json file exist in project root directory
- MakeCMakeUserPresets.json file exist in modules directory (cmake)
- CMakeUserPresets.json file does not exist in project root directory
- Ninja and/or Clang programs are installed on system and works from terminal

If any of these conditions are not met, the CMakeUserPresets.json file will no
longer be created.

### Final Note

The PrintMessage, SeekProgram, and MakeCMakeUserPresets modules are not
requirements for the template, rather they are use cases.

However, all error messages for the template are intended for print_message()
function. If you want to use the message() function, these will need to be
modified accordingly.

That's all about this repo.

All the best!
