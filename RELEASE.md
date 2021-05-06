# Core GNU make Build System Release Notes
This repo provides the core make build files and scripts for building and programming ModusToolbox applications. Builds can be run either through a command-line interface (CLI) or through the ModusToolbox Integrated Development Environment (IDE).

### What's Included?
The this release of the core GNU make Build System includes a framework to support building, programming, and debugging application projects. It must be used in conjunction with a recipe specific make package (eg: mxs40recipe-make). It is expected that a code example contains a top level make file for itself and references a Board Support Package (BSP) that defines specifics items, like the PSoC part, for the target board. Supported functionality includes the following:
* Supported operations:
    * Build
    * Program
    * Debug
    * IDE Integration (Eclipse, VS Code, IAR, uVision)
    * BSP Generation
* Supported toolchains:
    * GCC
    * IAR
    * ARMv6

This also includes the getlibs.bash script that can be used directly, or via the make target to download additional git repo based libraries for the application.

### What Changed?
#### v1.8.0
* Added support for generating tgz file for Infineon online simulator (recipe-make-cat3-1.1.0 or newer)
* Added support for opening Infineon online simulator through quick panel (recipe-make-cat3-1.1.0 or newer)
#### v1.7.2
* Fix make config_ezpd and config_lin not working when there are no existing design file
#### v1.7.1
* Added error detection for when the selected device in makefile does not match selected device in design.modus file
* make bsp will now generated .mtbx files even if device-configurator fails.
#### v1.7.0
* Added make update_bsp commmand to change the target device a custom bsp
* Added support for the secure-tools configurator, ml-configurator, ez-pd configurator and lin configurator
#### v1.6.0
* Moved more code from recipe files into core
* Improved compatibility with different tool releases
#### v1.5.0
* Initial release supporting build/program/debug on gcc/iar/armv6 toolchains.
NOTE: This was formerly part of psoc6make but is now split out for improved reuse

### Product/Asset Specific Instructions
Builds require that the ModusToolbox tools be installed on your machine. This comes with the ModusToolbox install. On Windows machines, it is recommended that CLI builds be executed using the Cygwin.bat located in ModusToolBox/tools_x.y/modus-shell install directory. This guarantees a consistent shell environment for your builds.

To list the build options, run the "help" target by typing "make help" in CLI. For a verbose documentation on a specific subject type "make help CY_HELP={variable/target}", where "variable" or "target" is one of the listed make variables or targets.

### Supported Software and Tools
This version of the core make build system was validated for compatibility with the following Software and Tools:

| Software and Tools                        | Version |
| :---                                      | :----:  |
| ModusToolbox Software Environment         | 2.3     |
| GCC Compiler                              | 9.2     |
| IAR Compiler                              | 8.4     |
| ARM Compiler                              | 6.11    |

Minimum required ModusToolbox Software Environment: v2.0

### More information
Use the following links for more information, as needed:
* [Cypress Semiconductor, an Infineon Technologies Company](http://www.cypress.com)
* [Cypress Semiconductor GitHub](https://github.com/cypresssemiconductorco)
* [ModusToolbox](https://www.cypress.com/products/modustoolbox-software-environment)

---
© Cypress Semiconductor Corporation, 2019-2020.