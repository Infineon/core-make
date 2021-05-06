# Core GNU make Build System

## Overview

This repo provides the core make build files and scripts for building and programming ModusToolbox applications. Builds can be run either through a command-line interface (CLI) or through the ModusToolbox Integrated Development Environment (IDE).

## Prerequisite

Builds require that the ModusToolbox tools be installed on your machine. This comes with the ModusToolbox install. On Windows machines, it is recommended that CLI builds be executed using the Cygwin.bat located in ModusToolBox/tools_x.y/modus-shell install directory. This guarantees a consistent shell environment for your builds. Additionally, a recipe specific make package (eg: mxs40recipe-make) must also be used to define the specifics for the target device.

## Options

To list the build options, run the "help" target by typing "make help" in CLI. For a verbose documentation on a specific subject type "make help CY_HELP={variable/target}", where "variable" or "target" is one of the listed make variables or targets.

## More information
* [Core-make Release Notes](./RELEASE.md)
* [Cypress Semiconductor, an Infineon Technologies Company](http://www.cypress.com)
* [Cypress Semiconductor GitHub](https://github.com/cypresssemiconductorco)
* [ModusToolbox](https://www.cypress.com/products/modustoolbox-software-environment)

---
© Cypress Semiconductor Corporation, 2019-2020.
