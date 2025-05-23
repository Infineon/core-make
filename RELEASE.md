# Core GNU make Build System Release Notes
This repo provides the core make build files and scripts for building and programming ModusToolbox applications. Builds can be run either through a command-line interface (CLI) or through a supported IDE such as Eclipse or VS Code.

### What's Included?
This release of the core GNU make Build System includes a framework to support building, programming, and debugging application projects. It must be used in conjunction with a recipe specific make package (eg: recipe-make-cat1a). It is expected that a code example contains a top level make file for itself and references a Board Support Package (BSP) that defines specific items, like the PSOC™ part, for the target board. Supported functionality includes the following:

* Supported operations:
    * Build
    * Program
    * Debug
    * IDE Integration (Eclipse, VS Code, IAR, uVision)
* Supported toolchains:
    * GCC
    * IAR
    * ARM Compiler 6
    * LLVM Embedded Toolchain for Arm (Experimental)

### What Changed?
#### v3.6.1
* Fixed a bug introduced in core-make-3.6.0 that broke BWC with IDE export using ModusToolbox 3.4.
* Fixed a bug causing TrustZone veneer object file to not be linked into the non-secure project.

#### v3.6.0
* Added support for GNU assembly syntax when using ARM toolchain.
* Fixed the issue with space handling for ninja builds.

#### v3.5.1
* Remove make build command line option "--output-sync" from eclipse and vscode export. This allows ninja builds in IDE to display incremental progress.
* Added support for generating additional tasks when exporting to VSCode.

#### v3.5.0
* Core-make 3.5 is incompatible with previous versions of recipe-make.
* Added Ninja support. Ninja build will be enabled by default with ModusToolbox 3.4, and latest recipe-make. To disable Ninja build set NINJA to empty-String. (For example: "make build NINJA=").

#### v3.4.1
* Fixed an issue with programming using Eclipse for a hex file built with experimental Ninja support.

#### v3.4.0
* Added experimental LLVM Embedded Toolchain for Arm support.
* Added support for Infineon EdgeProtectTool.
* Added task in VS Code export's tasks.json in multicore application to only build the current project.
* Added option for Eclipse export to only build the current project in multicore application.
* Added launch configurations for Eclipse and VS Code to only program/debug a single project in multi-core application.
* Added experimental ninja support.
* Multiple bug fixes and build performance improvements.

#### v3.3.1
* Fixed an issue causing some python calls to not be quoted properly.

#### v3.3.0
* Fixed an issue causing the compile_commands.json file to not be generated properly for files outside of project directory.
* Fixed an issue where the compile_commands.json file generation did not properly handle some escape characters correctly.
* Dropped support for Python as part of the ModusToolbox tools package in favor of pre-installed Python 3 in the user's PATH.
* Updated Eclipse export to support parallel build jobs in Eclipse IDE for ModusToolbox 3.2 and later.
* Multiple bug fixes and performance improvements.

#### v3.2.2
* Fixed an issue where files from SOURCES are not compiled if they start with "./"

#### v3.2.1
* Added SKIP_CODE_GEN make variable, when set to non-empty value, code generation step will be skipped.
* Added MTB_JLINK_DIR make variable to override the default path to JLink base diretory.
* Added support for BSP_PROGRAM_INTERFACE make variable to specify programming interface. Valid values depends on recipe-make. Some valid values include "KitProg3", "JLink", "FTDI". Not all recipes support all interfaces.
* Eclipse and VS Code export will now only generate the launch configurations for the selected programming interface.

#### v3.1.0
* This version of the core-make library is a Beta release to support CYW55513 devices only. Do not use it for production development or in applications targeting other devices.

#### v3.0.2
* Workaround an issue where CONFIG_ directory was not being properly filtered by auto-discovery.
* update make vscode generated c_cpp_properties.json to only use compile_commands.json

#### v3.0.1
* Fixed UVision, and Embbeded Workbench export not handling escape characters correctly in defines

#### v3.0.0
* Dropped compatibility with recipe-make version 1.X and ModusToolbox tools version 2.X

#### v1.9.1
* Added support for uvision5 export devices with Cortex-M33 core

#### v1.9.0
* Update various make help documentation
* Updated uvsion5 export to support XMC devices
* Changed Infineon online simulator tgz file generation to be off by default, so it will not add to build time. Archive file generation can be enabled during build by setting to CY\_SIMULATOR\_GEN\_AUTO=1 in the Makefile.
* Changed IDE export to run prebuild code-generation so that project can work out-of-the-box with 3rd party IDEs

#### v1.8.0
* Added support for generating tgz file for Infineon online simulator (recipe-make-cat3-1.1.0 or newer)
* Added support for opening Infineon online simulator through quick panel (recipe-make-cat3-1.1.0 or newer)

#### v1.7.2
* Fix make config\_ezpd and config\_lin not working when there are no existing design file

#### v1.7.1
* Added error detection for when the selected device in makefile does not match selected device in design.modus file
* make bsp will now generated .mtbx files even if device-configurator fails.

#### v1.7.0
* Added make update\_bsp commmand to change the target device a custom bsp
* Added support for the secure-tools configurator, ml-configurator, ez-pd configurator and lin configurator

#### v1.6.0
* Moved more code from recipe files into core
* Improved compatibility with different tool releases

#### v1.5.0
* Initial release supporting build/program/debug on gcc/iar/armv6 toolchains.
NOTE: This was formerly part of psoc6make but is now split out for improved reuse

### Product/Asset Specific Instructions
Builds require that the ModusToolbox tools be installed on your machine. This comes with the ModusToolbox install. On Windows machines, it is recommended that CLI builds be executed using the Cygwin.bat located in ModusToolBox/tools\_x.y/modus-shell install directory. This guarantees a consistent shell environment for your builds.

To list the build options, run the "help" target by typing "make help" in CLI. For a verbose documentation on a specific subject type "make help CY\_HELP={variable/target}", where "variable" or "target" is one of the listed make variables or targets.

### Supported Software and Tools
This version of the core make build system was validated for compatibility with the following Software and Tools:

| Software and Tools                        | Version |
| :---                                      | :----:  |
| ModusToolbox Software Environment         | 3.5     |
| GCC Compiler                              | 11.3    |
| IAR Compiler                              | 9.3     |
| ARM Compiler                              | 6.16    |

Minimum required ModusToolbox Software Environment: v3.4

### More information
* [Infineon GitHub](https://github.com/Infineon)
* [ModusToolbox](https://www.infineon.com/cms/en/design-support/tools/sdk/modustoolbox-software)

---
(c) 2019-2025, Cypress Semiconductor Corporation (an Infineon company) or an affiliate of Cypress Semiconductor Corporation. All rights reserved.
