################################################################################
# \file help.mk
#
# \brief
# Default help documentation
#
################################################################################
# \copyright
# Copyright 2018-2020 Cypress Semiconductor Corporation
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

ifeq ($(WHICHFILE),true)
$(info Processing $(lastword $(MAKEFILE_LIST)))
endif

#
# General targets
#
CY_HELP_all=Same as build.
CY_HELP_all_VERBOSE=This target is equivalent to the "build" target.
CY_HELP_getlibs=Clones the repositories and checks out the identified commit.
CY_HELP_getlibs_VERBOSE=When using .mtb files, the repos are cloned to the shared location (CY_GETLIBS_SHARED_PATH)\
					if the file is declared shared. Otherwise it is placed in the application's libs directory.\
					When using .lib files, the repos are cloned to the libs directory. By default, this directory is\
					created in the application directory. It may be directed to other locations using\
					the CY_GETLIBS_PATH variable.
CY_HELP_build=Builds the application.
CY_HELP_build_VERBOSE=The build process involves source auto-discovery, code generation, prebuilds, and postbuilds.\
					For faster incremental builds, use the "qbuild" target to skip the auto-generation step.
CY_HELP_qbuild=Builds the application using the previous build's source list.
CY_HELP_qbuild_VERBOSE=When no other sources need to be auto-discovered, this target can be used to skip\
					the auto-discovery step for a faster incremental build.
CY_HELP_program=Builds the application and programs it to the target device.
CY_HELP_program_VERBOSE=The build process performs the same operations as the "build" target. Upon completion,\
					the artifact is programmed to the board.
CY_HELP_qprogram=Programs a built application to the target device without rebuilding.
CY_HELP_qprogram_VERBOSE=This target allows programming an existing artifact to the board without a build step.
CY_HELP_debug=Builds and programs. Then launches a GDB server.
CY_HELP_debug_VERBOSE=Once the GDB server is launched, another shell should be opened to launch a GDB client.
CY_HELP_qdebug=Skips the build and program step. Launches a GDB server.
CY_HELP_qdebug_VERBOSE=Once the GDB server is launched, another shell should be opened to launch a GDB client.
CY_HELP_attach=Used to attach to a target for debugging.
CY_HELP_attach_VERBOSE=Run in a separate shell before starting the debug target.
CY_HELP_clean=Cleans the /build/<TARGET> directory.
CY_HELP_clean_VERBOSE=The directory and all its contents are deleted from disk.
CY_HELP_help=Prints the help documentation.
CY_HELP_help_VERBOSE=Use the CY_HELP=<NAME of target of variable> to see the verbose documentation for a\
					particular target or a variable.

#
# IDE targets
#
CY_HELP_eclipse=Generates eclipse IDE launch configs and project files.
CY_HELP_eclipse_VERBOSE=This target generates a .cproject and a .project if they do not exist in the application root directory.\
					If CY_IDE_PRJNAME variable is set, it will be used as the names for project's launch configs.\
					If CY_IDE_PRJNAME is not set, APPNAME will be used instead.\
					$(CY_NEWLINE)Note: Project generation requires python3 to be installed and present in the PATH variable.\
					$(CY_NEWLINE)Note: To skip project creation and only create the launch configs, set CY_MAKE_IDE=eclipse.
CY_HELP_vscode=Generates VSCode IDE json files.
CY_HELP_vscode_VERBOSE=This target generates VSCode json files for debug/program launches, intellisense, and custom tasks.\
					These overwrite the existing files in the application directory except for settings.json.
CY_HELP_ewarm8=Generates IAR-EW v8 IDE .ipcf file.
CY_HELP_ewarm8_VERBOSE=This target generates an IAR Embedded Workbench v8.x compatible .ipcf file that can be imported\
					into IAR-EW. The .ipcf file is overwritten every time this target is run.\
					$(CY_NEWLINE)Note: Project generation requires python3 to be installed and present in the PATH variable.
CY_HELP_uvision5=Generates Keil uVision5 IDE .cpdsc, .gpdsc, and .cprj files.
CY_HELP_uvision5_VERBOSE=This target generates a CMSIS compatible .cpdsc and .gpdsc files that can be imported\
					into Keil uVision 5. Both files are overwritten every time this target is run.\ CY_IDE_PRJNAME can\
					be used exclude files from exsiting cmsis build. Files in following cmsis output directory will\
					be automtically excluded when calling make uvision5: <CY_IDE_PRJNAME>_build, <CY_IDE_PRJNAME>_Listings, and\
					<CY_IDE_PRJNAME>_Objects.\
					$(CY_NEWLINE)Note: Project generation requires python3 to be installed and present in the PATH variable.

#
# Tool targets
#
CY_HELP_modlibs=Launches the library-manager for updating libraries.
CY_HELP_modlibs_VERBOSE=The library manager can be used to add/remove libraries and to upgrade/downgrade existing libraries.
CY_HELP_open=Opens/launches a specified tool.
CY_HELP_open_VERBOSE=This target accepts two variables – CY_OPEN_TYPE and CY_OPEN_FILE. At least one of\
					these must be provided. The tool can be specified by setting the CY_OPEN_TYPE variable.\
					A specific file can also be passed using the CY_OPEN_FILE variable. If only CY_OPEN_FILE is given,\
					the build system will launch the default tool associated with the file’s extension.\
					$(CY_NEWLINE)Supported types are: $(sort $(CY_OPEN_TYPE_LIST)).\
					$(CY_NEWLINE)Note: This command is intended for the Eclipse IDE to open/launch a specific tool.\
					For configurators, the preferred method is to use config, config_bt and config_usbdev targets.
CY_HELP_config=Runs the device-configurator on the target .modus file.
CY_HELP_config_VERBOSE=If no existing device-configuration files are found, the configurator is launched to create one.
CY_HELP_config_bt=Runs the bt-configurator on the target .cybt file.
CY_HELP_config_bt_VERBOSE=If no existing bt-configuration files are found, the configurator is launched to create one.
CY_HELP_config_usbdev=Runs the usbdev-configurator on the target .cyusbdev file.
CY_HELP_config_usbdev_VERBOSE=If no existing usbdev-configuration files are found, the configurator is launched to create one.
CY_HELP_config_secure=Runs the secure-policy-configurator.
CY_HELP_config_secure_VERBOSE=The secure-policy-configurator is intended only for devices that support secure provisioning.
CY_HELP_config_ezpd=Runs the ez-pd-configurator.
CY_HELP_config_ezpd_VERBOSE=If no existing ez-pd-configuration files are found, the configurator is launched to create one.
CY_HELP_config_lin=Runs the lin-configurator.
CY_HELP_config_lin_VERBOSE=If no existing lin-configuration files are found, the configurator is launched to create one.

#
# Utility targets
#
CY_HELP_bsp=Generates a TARGET_GEN board/kit from TARGET.
CY_HELP_bsp_VERBOSE=This target generates a new Board Support Package with the name provided in TARGET_GEN based on the current\
					TARGET. The TARGET_GEN variable must be populated with the name of the new TARGET. Optionally, you may\
					define the target device (DEVICE_GEN). For example,\
					$(CY_NEWLINE)$(CY_NEWLINE)make bsp TARGET_GEN=NewBoard DEVICE_GEN=CY8C624ABZI-S2D44
CY_HELP_update_bsp=Change the device in a custom bsp generated by make bsp command
CY_HELP_update_bsp_VERBOSE=This target changes the device set in a custom Board Support Package generated by the make bsp command.\
					The TARGET_GEN variable will specify the Board Support Package to modify. The DEVICE_GEN variable will specify\
					the new target device of the BSP. For example,\
					$(CY_NEWLINE)$(CY_NEWLINE) make update_bsp TARGET_GEN=NewBoard DEVICE_GEN=CY8C624ABZI-S2D44
CY_HELP_lib2mtbx=Convert .lib files to .mtbx files
CY_HELP_lib2mtbx_VERBOSE=This will recursively look for .lib files in CONVERSION_PATH and create equivalent .mtbx files \
					adjacent to them. The type of .mtbx file is determined by the CONVERSION_TYPE variable. This can be either\
					[local] or [shared]. The default is [local].
CY_HELP_import_deps=Import dependent .mtbx files of a given path into the application.
CY_HELP_import_deps_VERBOSE=This will recursively look for .mtbx files in IMPORT_PATH, copy them to the application's deps \
					directory and rename them to .mtb files. Note that the import process is not applicable\
					for applications using .lib files. These libraries must instead be situated in the application directory.
CY_HELP_progtool=Performs specified operations on the programmer/firmware-loader
CY_HELP_progtool_VERBOSE=This target expects user-interaction on the shell while running it. When prompted, the user must specify the\
					command(s) to run for the tool.
CY_HELP_check=Checks for the necessary tools.
CY_HELP_check_VERBOSE=Not all tools are necessary for every build recipe. This target allows the user\
					to get an idea of which tools are missing if a build fails in an unexpected way.
CY_HELP_get_app_info=Prints the application info for the Eclipse IDE for ModusToolbox.
CY_HELP_get_app_info_VERBOSE=The file types can be specified by setting the\
					CY_CONFIG_FILE_EXT variable. For example,\
					$(CY_NEWLINE)$(CY_NEWLINE)make get_app_info CY_CONFIG_FILE_EXT="modus cybt cyusbdev".
CY_HELP_get_env_info=Prints the make, git, and application repo info.
CY_HELP_get_env_info_VERBOSE=This allows a quick printout of the current application repo and the "make" and "git"\
					tool locations and versions.
CY_HELP_printlibs=Prints the status of the library repos.
CY_HELP_printlibs_VERBOSE=This target parses through the library repos and prints the SHA1 commit id for each library.\
					It also shows whether the repo is clean (no changes) or dirty (modified or new files).

#
# Basic configuration
#
CY_HELP_TARGET=Specifies the target board/kit. (e.g. CY8CPROTO-062-4343W)
CY_HELP_TARGET_VERBOSE=Current target in this application is, [ $(CY_TARGET_MAKEFILE) ].\
						$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make build TARGET=CY8CPROTO-062-4343W
CY_HELP_APPNAME=Specifies the name of the app. (e.g. "AppV1" -> AppV1.elf)
CY_HELP_APPNAME_VERBOSE=This variable is used to set the name of the application artifact (programmable image).\
				It also signifies that the application will build for a programmable image artifact that is\
				intended for a target board. For applications that need to build to an archive (library),\
				use the LIBNAME variable.\
				$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make build APPNAME="AppV1"\
				$(CY_NEWLINE)$(CY_NEWLINE)Note: This variable may also be used when generating launch configs when invoking the "eclipse" target.\
				$(CY_NEWLINE)Example Usage: make eclipse APPNAME="AppV1"
CY_HELP_LIBNAME=Specifies the name of the library app. (e.g. "LibV1" -> LibV1.a)
CY_HELP_LIBNAME_VERBOSE=This variable is used to set the name of the application artifact (prebuilt library).\
				It also signifies that the application will build an archive (library) that is intended to be linked\
				to another application. These library applications can be added as a dependency to an artifact producing application\
				using the DEPENDENT_LIB_PATHS variable.\
				$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make build LIBNAME="LibV1"
CY_HELP_TOOLCHAIN=Specifies the toolchain for building the application. (e.g. GCC_ARM)
CY_HELP_TOOLCHAIN_VERBOSE=Supported toolchains for this target are, [ $(CY_SUPPORTED_TOOLCHAINS) ].\
							$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make build TOOLCHAIN=IAR \
							CY_COMPILER_PATH="<path>/IAR Systems/Embedded Workbench 8.4/arm/bin"
CY_HELP_CONFIG=Specifies the configuration option for the build [Debug Release].
CY_HELP_CONFIG_VERBOSE=The CONFIG variable is not limited to Debug/Release. It can be\
						other values. However in those instances, the build system will not configure the optimization flags.\
						Debug=lowest optimization, Release=highest optimization. The optimization flags are toolchain-specific.\
						If you go with your custom config then you can manually set the optimization flag in the CFLAGS.\
						$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make build CONFIG=Release
CY_HELP_VERBOSE=Specifies whether the build is silent [false] or verbose [true].
CY_HELP_VERBOSE_VERBOSE=Setting VERBOSE to true may help in debugging build errors/warnings. By default it is set to false.\
						$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make build VERBOSE=true

#
# Advanced configuration
#
CY_HELP_SOURCES=Specifies C/C++ and assembly files outside of the application directory.
CY_HELP_SOURCES_VERBOSE=This can be used to include files external to the application directory.\
						The path can be both absolute or relative to the application directory.\
						$(CY_NEWLINE)$(CY_NEWLINE)Example Usage (within makefile): SOURCES+=path/to/file/Source1.c
CY_HELP_INCLUDES=Specifies include paths outside of the application directory.
CY_HELP_INCLUDES_VERBOSE=Note: These MUST NOT have -I prepended.\
						The path can be either absolute or relative to the application directory.\
						$(CY_NEWLINE)$(CY_NEWLINE)Example Usage (within makefile): INCLUDES+=path/to/headers
CY_HELP_DEFINES=Specifies additional defines passed to the compiler.
CY_HELP_DEFINES_VERBOSE=Note: These MUST NOT have -D prepended.\
						$(CY_NEWLINE)$(CY_NEWLINE)Example Usage (within makefile): DEFINES+=EXAMPLE_DEFINE=0x01
CY_HELP_VFP_SELECT=Selects hard/soft ABI or full software for floating-point operations [softfp hardfp softfloat].
CY_HELP_VFP_SELECT_VERBOSE=If not defined, this value defaults to softfp.\
							$(CY_NEWLINE)$(CY_NEWLINE)Example Usage (within makefile): VFP_SELECT=hardfp
CY_HELP_CFLAGS=Prepends additional C compiler flags.
CY_HELP_CFLAGS_VERBOSE=Note: If the entire C compiler flags list needs to be replaced, define the\
						CY_RECIPE_CFLAGS make variable with the desired C flags. The values\
						should be space separated.\
						$(CY_NEWLINE)$(CY_NEWLINE)Example Usage (within makefile): CFLAGS+= -Werror -Wall -O2
CY_HELP_CXXFLAGS=Prepends additional C++ compiler flags.
CY_HELP_CXXFLAGS_VERBOSE=Note: If the entire C++ compiler flags list needs to be replaced, define the\
						CY_RECIPE_CXXFLAGS make variable with the desired C++ flags. Usage is similar to CFLAGS.\
						$(CY_NEWLINE)$(CY_NEWLINE)Example Usage (within makefile): CXXFLAGS+= -finline-functions
CY_HELP_ASFLAGS=Prepends additional assembler flags.
CY_HELP_ASFLAGS_VERBOSE=Note: If the entire assembler flags list needs to be replaced, define the\
						CY_RECIPE_ASFLAGS make variable with the desired assembly flags. Usage is similar to CFLAGS.
CY_HELP_LDFLAGS=Prepends additional linker flags.
CY_HELP_LDFLAGS_VERBOSE=Note: If the entire linker flags list needs to be replaced, define the\
						CY_RECIPE_LDFLAGS make variable with the desired linker flags. Usage is similar to CFLAGS.\
						$(CY_NEWLINE)$(CY_NEWLINE)Example Usage (within makefile): LDFLAGS+= -nodefaultlibs
CY_HELP_LDLIBS=Includes application-specific prebuilt libraries.
CY_HELP_LDLIBS_VERBOSE=Note: If additional libraries need to be added using -l or -L, add to the\
						CY_RECIPE_EXTRA_LIBS make variable. Usage is similar to CFLAGS.\
						$(CY_NEWLINE)$(CY_NEWLINE) Example Usage (within makefile): LDLIBS+=../MyBinaryFolder/binary.o
CY_HELP_LINKER_SCRIPT=Specifies a custom linker script location.
CY_HELP_LINKER_SCRIPT_VERBOSE=This linker script overrides the default. Note: Additional\
					linker scripts can be added for GCC via the LDFLAGS variable as a -L option.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage (within makefile): LINKER_SCRIPT=path/to/file/Custom_Linker1.ld
CY_HELP_PREBUILD=Specifies the location of a custom prebuild step and its arguments.
CY_HELP_PREBUILD_VERBOSE=This operation runs before the build recipe's prebuild step.\
					$(CY_NEWLINE)Note: BSPs can also define a prebuild step. This runs before the\
					application prebuild step.\
					$(CY_NEWLINE)Note: If the default prebuild step needs to be replaced, define the\
					CY_RECIPE_PREBUILD make variable with the desired prebuild step.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage (within makefile): PREBUILD=python example_script.py
CY_HELP_POSTBUILD=Specifies the location of a custom postbuild step and its arguments.
CY_HELP_POSTBUILD_VERBOSE=This operation runs after the build recipe's postbuild step.\
					$(CY_NEWLINE)Note: BSPs can also define a postbuild step. This runs before the\
					application postbuild step.\
					$(CY_NEWLINE)Note: If the default postbuild step needs to be replaced, define the\
					CY_RECIPE_POSTBUILD make variable with the desired postbuild step.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage (within makefile): POSTBUILD=python example_script.py
CY_HELP_COMPONENTS=Adds component-specific files to the build.
CY_HELP_COMPONENTS_VERBOSE=Create a directory named COMPONENT_<VALUE> and place your files.\
					Then include the <VALUE> to this make variable to have that feature library\
					be included in the build. For example, Create a directory named COMPONENT_ACCELEROMETER.\
					Then include it in the make variable. COMPONENT=ACCELEROMETER. If the make variable\
					does not include the <VALUE>, then that library will not be included in the build.\
					$(CY_NEWLINE)Note: If the default COMPONENT list must be overridden, define the CY_COMPONENT_LIST\
					make variable with the list of component values.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage (within makefile): COMPONENTS+=CUSTOM_CONFIGURATION
CY_HELP_DISABLE_COMPONENTS=Removes component-specific files from the build.
CY_HELP_DISABLE_COMPONENTS_VERBOSE=Include a <VALUE> to this make variable to have that feature library\
					be excluded in the build. For example, To exclude the contents of COMPONENT_BSP_DESIGN_MODUS\
					directory, set DISABLE_COMPONENTS=BSP_DESIGN_MODUS as shown.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage (within makefile): DISABLE_COMPONENTS=BSP_DESIGN_MODUS
CY_HELP_SEARCH_LIBS_AND_INCLUDES=List of dependent library application paths. (e.g. ../bspLib). Note: This variable is replaced by DEPENDENT_LIB_PATHS.
CY_HELP_SEARCH_LIBS_AND_INCLUDES_VERBOSE=An artifact producing application (defined by setting APPNAME),\
					can have a dependency on library applications (defined by setting LIBNAME). This variable\
					defines those dependencies for the artifact producing application. The actual build invocation\
					of those libraries is handled at the application level by defining the "shared_libs" target. For example,\
					$(CY_NEWLINE)$(CY_NEWLINE)shared_libs: $(CY_NEWLINE)$(CY_INDENT)make -C ../bspLib build -j
CY_HELP_DEPENDENT_LIB_PATHS=List of dependent library application paths. (e.g. ../bspLib)
CY_HELP_DEPENDENT_LIB_PATHS_VERBOSE=Note: This variable replaces the SEARCH_LIBS_AND_INCLUDES variable.\
					$(CY_NEWLINE)An artifact producing application (defined by setting APPNAME),\
					can have a dependency on library applications (defined by setting LIBNAME). This variable\
					defines those dependencies for the artifact producing application. The actual build invocation\
					of those libraries is handled at the application level by defining the "shared_libs" target. For example,\
					$(CY_NEWLINE)$(CY_NEWLINE)shared_libs: $(CY_NEWLINE)$(CY_INDENT)make -C ../bspLib build -j
CY_HELP_DEPENDENT_APP_PATHS=List of dependent application paths. (e.g. ../cy_m0p_image)
CY_HELP_DEPENDENT_APP_PATHS_VERBOSE=The main application can have a dependency on other artifact producing\
					applications (defined by setting APPNAME). This variable defines those dependencies for the main\
					application. The artifacts of these dependent applications are translated to c-arrays and are brought\
					into the main application as regular c-files and are compiled and linked. The main application also generates\
					a "standalone" variant of the main application that does not include the dependent apps.
CY_HELP_SEARCH=List of paths to include in auto-discovery. (e.g. ../mtb_shared/lib1)
CY_HELP_SEARCH_VERBOSE=When "getlibs" is run for applications that use .mtb files, a file is generated in ./libs/mtb.mk.\
					This file automatically populates the SEARCH variable with the locations of the libraries in\
					the shared repo location (set by the CY_GETLIBS_SEARCH_PATH and CY_GETLIBS_SHARED_NAME variables).\
					The SEARCH variable can also be used by the application to include other directories to auto-discovery.
CY_HELP_IMPORT_PATH=Path to .mtbx dependency files to import into the application
CY_HELP_IMPORT_PATH_VERBOSE=This variable must be defined when calling "import_deps". Any .mtbx dependency file found in this\
					directory will be imported into the application. Note that this is not applicable for applications\
					using .lib files.
CY_HELP_CONVERSION_PATH=Path to the .lib files to convert to .mtbx files
CY_HELP_CONVERSION_PATH_VERBOSE=This variable must be defined when calling "lib2mtbx". Any .lib file found in this directory\
					will be converted.
CY_HELP_CONVERSION_TYPE=(Optional) Defines the type of .mtbx file to create
CY_HELP_CONVERSION_TYPE_VERBOSE=This variable can be set to [local] or [shared]. The default type is [local]. If [local],\
					the library will be deposited in the application's CY_GETLIBS_PATH directory when performing "getlibs".\
					If [shared], the library will be deposited (when running getlibs) in the shared location as defined by\
					CY_GETLIBS_SHARED_PATH and CY_GETLIBS_SHARED_NAME. 
CY_HELP_FORCE=(Optional) Force overwrite existing files
CY_HELP_FORCE_VERBOSE=When this variable is set [true], "lib2mtbx" overwrites any existing .mtbx files.

#
# BSP variables
#
CY_HELP_DEVICE=Device ID for the primary MCU on the target board/kit. Set by <TARGET>.mk.
CY_HELP_DEVICE_VERBOSE=The device identifier is mandatory for all board/kits.
CY_HELP_ADDITIONAL_DEVICES=IDs for additional devices on the target board/kit. Set by <TARGET>.mk.
CY_HELP_ADDITIONAL_DEVICES_VERBOSE=These include devices such as radios on the board/kit. This variable is optional.
CY_HELP_TARGET_GEN=Name of the new target board/kit.
CY_HELP_TARGET_GEN_VERBOSE=This is a mandatory variable when calling the "bsp" make target. It is used to\
					name the board/kit files and directory.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make bsp TARGET_GEN=MyBSP
CY_HELP_DEVICE_GEN=(Optional) Device ID for the primary MCU on the new target board/kit.
CY_HELP_DEVICE_GEN_VERBOSE=This is an optional variable when calling the "bsp" make target to replace the primary\
					MCU on the board (overwrites DEVICE). If it is not defined, the new board/kit will use the existing\
					DEVICE from the board/kit that it is copying from.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make bsp TARGET_GEN=MyBSP DEVICE_GEN=CY8C624ABZI-S2D44

#
# Getlibs variables
#
CY_HELP_CY_GETLIBS_NO_CACHE=Disables the cache when running getlibs.
CY_HELP_CY_GETLIBS_NO_CACHE_VERBOSE=To improve the library creation time, the getlibs target uses a cache\
					located in the user's home directory ($$HOME for macOS/Linux and $$USERPROFILE for Windows). Disabling the\
					cache will result in slower application creation time but may be necessary for bringing in non-Cypress libraries.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make getlibs CY_GETLIBS_NO_CACHE=true
CY_HELP_CY_GETLIBS_OFFLINE=Use the offline location as the library source.
CY_HELP_CY_GETLIBS_OFFLINE_VERBOSE=Setting this variable signals to the build system to use the offline location (Default: <HOME>/.modustoolbox/offline)\
					when running the "getlibs" target. The location of the offline content can be changed by defining the CY_GETLIBS_OFFLINE_PATH variable.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make getlibs CY_GETLIBS_OFFLINE=true
CY_HELP_CY_GETLIBS_PATH=Absolute path to the intended location of libs directory.
CY_HELP_CY_GETLIBS_PATH_VERBOSE=The library repos are cloned into a directory named, /libs (Default: <CY_APP_PATH>/libs).\
					Setting this variable allows specifying the location of the libs directory to elsewhere on disk.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make getlibs CY_GETLIBS_PATH="path/to/directory"
CY_HELP_CY_GETLIBS_DEPS_PATH=Absolute path to where the library-manager stores .mtb and .lib files.
CY_HELP_CY_GETLIBS_DEPS_PATH_VERBOSE=Setting this path allows relocating the directory that the library-manager uses to store\
					the .mtb/.lib files in your application. The default location is in a directory named /deps (Default: <CY_APP_PATH>/deps).\
					Usage is similar to CY_GETLIBS_PATH.\
					$(CY_NEWLINE)Note: This variable requires ModusToolbox tools_2.1 or higher.
CY_HELP_CY_GETLIBS_CACHE_PATH=Absolute path to the cache directory.
CY_HELP_CY_GETLIBS_CACHE_PATH_VERBOSE=The build system caches all cloned repos in a directory named /cache \
					(Default: <HOME>/.modustoolbox/cache). Setting this variable allows the cache to be relocated to\
					elsewhere on disk. Usage is similar to CY_GETLIBS_PATH. To disable the cache entirely, \
					set the CY_GETLIBS_NO_CACHE variable to [true].\
					$(CY_NEWLINE)Note: This variable requires ModusToolbox tools_2.1 or higher.
CY_HELP_CY_GETLIBS_OFFLINE_PATH=Absolute path to the offline content directory.
CY_HELP_CY_GETLIBS_OFFLINE_PATH_VERBOSE=The offline content is used to create/update applications when not connected\
					to the internet (Default: <HOME>/.modustoolbox/offline). Setting this variable allows to relocate the\
					offline content to elsewhere on disk. Usage is similar to CY_GETLIBS_PATH.\
					$(CY_NEWLINE)Note: This variable requires ModusToolbox tools_2.1 or higher.
CY_HELP_CY_GETLIBS_SEARCH_PATH=Relative path to the top directory for "getlibs" operation.
CY_HELP_CY_GETLIBS_SEARCH_PATH_VERBOSE=The getlibs operation by default executes at the location of the CY_APP_PATH. This can\
					be overridden by specifying this variable to point to a specific location.\
					Usage is similar to CY_GETLIBS_PATH.
CY_HELP_CY_GETLIBS_SHARED_PATH=Relative path to the shared repo location.
CY_HELP_CY_GETLIBS_SHARED_PATH_VERBOSE=All .mtb files have the format, <URI><COMMIT><LOCATION>.\
					If the <LOCATION> field begins with $$$$ASSET_REPO$$$$, then the repo is deposited in the path\
					specified by the CY_GETLIBS_SHARED_PATH variable. The default location is one directory level above\
					the current application directory (Default: ../). This is used with CY_GETLIBS_SHARED_NAME variable,\
					which specifies the directory name.
CY_HELP_CY_GETLIBS_SHARED_NAME=Directory name of the shared repo location.
CY_HELP_CY_GETLIBS_SHARED_NAME_VERBOSE=All .mtb files have the format, <URI><COMMIT><LOCATION>.\
					If the <LOCATION> field begins with $$$$ASSET_REPO$$$$, then the repo is deposited in the directory\
					specified by the CY_GETLIBS_SHARED_NAME variable. The default directory name is "mtb_shared". \
					This is used with CY_GETLIBS_SHARED_PATH variable, which specifies the directory path.

#
# Path variables
#
CY_HELP_CY_APP_PATH=Relative path to the top-level of application. (e.g. ./)
CY_HELP_CY_APP_PATH_VERBOSE=Settings this path to other than ./ allows the auto-discovery mechanism\
					to search from a root directory location that is higher than the application directory.\
					For example, CY_APP_PATH=../../ allows auto-discovery of files from a location that is\
					two directories above the location of ./Makefile.
CY_HELP_CY_BASELIB_PATH=Relative path to the recipe base library. (e.g. ./libs/recipe-make-<name>)
CY_HELP_CY_BASELIB_PATH_VERBOSE=This directory must be relative to CY_APP_PATH. It defines the location\
					of the library containing the recipe make files, where the expected directory structure\
					is <CY_BASELIB_PATH>/make. All applications must set the location of the recipe base library.\
					For applications using .mtb files, the BSP's <TARGET>.mk file sets this variable and therefore \
					the application does not need to.
CY_HELP_CY_BASELIB_CORE_PATH=Relative path to the core base library. (e.g. ./libs/core-make)
CY_HELP_CY_BASELIB_CORE_PATH_VERBOSE=This directory must be relative to CY_APP_PATH. It defines the location\
					of the library containing the core make files, where the expected directory structure\
					is <CY_BASELIB_CORE_PATH>/make. All applications must set the location of the core base library.\
					For applications using .mtb files, the BSP's <TARGET>.mk file sets this variable and therefore \
					the application does not need to. This variable is not applicable for applications using the combined \
					base library (such as psoc6make).
CY_HELP_CY_DEVICESUPPORT_PATH=Relative path to the devicesupport.xml file.
CY_HELP_CY_DEVICESUPPORT_PATH_VERBOSE=This path specifies the location of the devicesupport.xml file for device-configurators.\
					It is used when the configurator needs to be run in a multi-application scenario.
CY_HELP_CY_SHARED_PATH=Relative path to the location of shared .lib files. This variable is deprecated.
CY_HELP_CY_SHARED_PATH_VERBOSE=This variable is used in shared library applications to point to the location of external .lib files.
CY_HELP_CY_COMPILER_PATH=Absolute path to the compiler (Default: GCC_ARM in CY_TOOLS_DIR).
CY_HELP_CY_COMPILER_PATH_VERBOSE=Setting this path allows custom toolchains to be used instead of the defaults.\
					This should be the location of the /bin directory containing the compiler, assembler and\
					linker. For example, CY_COMPILER_PATH="C:/Program Files (x86)/IAR Systems/Embedded Workbench 8.4/arm/bin".
CY_HELP_CY_TOOLS_DIR=Absolute path to the tools root directory.
CY_HELP_CY_TOOLS_DIR_VERBOSE=Applications must specify the directory of the tools install, which contains the\
					root makefile and the necessary tools and scripts to build an application. Application Makefiles\
					are configured to automatically search in the standard locations for various platforms.\
					If the tools are not located in the standard location, you may explicitly set this.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make build CY_TOOLS_DIR="path/to/ModusToolbox/tools_x.y"
CY_HELP_CY_BUILD_LOCATION=Absolute path to the build output directory (Default: pwd/build).
CY_HELP_CY_BUILD_LOCATION_VERBOSE=The build output directory is structured as /<TARGET>/<CONFIG>/. Setting this variable\
					allows the build artifacts to be located in the directory pointed to by this variable.
CY_HELP_CY_EXTAPP_PATH=Relative path to an external application directory. (e.g. ../external)
CY_HELP_CY_EXTAPP_PATH_VERBOSE=This directory must be relative to CY_APP_PATH. Setting this path\
					allows incorporating files external to CY_APP_PATH. For example, CY_EXTAPP_PATH=../external\
					lets the auto-discovery to pull in the contents of ../external directory into the build.\
					$(CY_NEWLINE)Note: This variable is only supported in CLI. Use the shared_libs mechanism and\
					DEPENDENT_LIB_PATHS for tools and IDE support.\
					$(CY_NEWLINE)Note: Same functionality exists in the SEARCH variable. Using the SEARCH variable\
					is preferred over CY_EXTAPP_PATH.
CY_HELP_TOOLCHAIN_MK_PATH=Specifies the location of a custom TOOLCHAIN makefile.
CY_HELP_TOOLCHAIN_MK_PATH_VERBOSE=Defining this path allows the build system to use a custom TOOLCHAIN.mk\
					pointed to by this variable.\
					$(CY_NEWLINE)Note: The make variables in this file should match the\
					variables used in existing TOOLCHAIN.mk files.
CY_HELP_CY_PYTHON_PATH=Specifies the path to the Python executable.
CY_HELP_CY_PYTHON_PATH_VERBOSE=For make targets that depend on Python, the build system looks for a Python 3 in the user's PATH\
					and uses that to invoke python. If however CY_PYTHON_PATH is defined, it will use that python executable.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: CY_PYTHON_PATH="path/to/python/executable/python.exe"

#
# Miscellaneous variables
#
CY_HELP_CY_IGNORE=Adds to the directory and file ignore list. (e.g. ./file1.c ./inc1)
CY_HELP_CY_IGNORE_VERBOSE=Directories and files listed in this variable are ignored in the auto-discovery.\
					This mechanism works in combination with any existing .cyignore files in the application.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make build CY_IGNORE="path/to/file/ignore_file"
CY_HELP_CY_IDE_PRJNAME=Name of the project when used for IDE export.
CY_HELP_CY_IDE_PRJNAME_VERBOSE=When used in make eclipse, this variable defines the file and target project name when\
					generating eclipse launch configurations in the "eclipse" target.\
					$(CY_NEWLINE)When used in in make ewarm8, this variable defines the files name for the generated ipcf file.\
					$(CY_NEWLINE)When used in make uvision5, this variable defines the the project generation file names.\
					It is also used to exclude existing CMSIS output file from the following directories from being included\
					as additional input files: <CY_IDE_PRJNAME>_Listings, <CY_IDE_PRJNAME>_Object, and <CY_IDE_PRJNAME>_build.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make eclipse CY_IDE_PRJNAME="AppV1"
CY_HELP_CY_CONFIG_FILE_EXT=Specifies the configurator file extension. (e.g. modus)
CY_HELP_CY_CONFIG_FILE_EXT_VERBOSE=This variable accepts a space-separated list of configurator file extensions\
					that should be searched for when running the "get_app_info" target.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make get_app_info CY_CONFIG_FILE_EXT="modus cybt cyusbdev"
CY_HELP_CY_SKIP_RECIPE=Skip including the recipe make files.
CY_HELP_CY_SKIP_RECIPE_VERBOSE=Setting this to [true/1] allows the application to not include any recipe makefiles and only\
					include the start.mk file from the tools install.
CY_HELP_CY_SKIP_CDB=Skip creating .cdb files.
CY_HELP_CY_SKIP_CDB_VERBOSE=Constant Database (CDB) files are generated during the build process.\
					Setting this to [true] allows the build process to skip the .cdb files creation.
CY_HELP_CY_SUPPORTED_TOOL_TYPES=Defines the supported tools for a BSP.
CY_HELP_CY_SUPPORTED_TOOL_TYPES_VERBOSE=BSPs can define the supported tools that can be launched using the\
					"open" target. The supported tool types are $(sort $(CY_OPEN_TYPE_LIST)). The BSP can make adjustments to the\
					default recipe if needed.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage (bsp.mk): CY_SUPPORTED_TOOL_TYPES+=seglcd-configurator
CY_HELP_CY_LIBS_SEARCH_DEPTH=Search depth for .lib files (Default: 5).
CY_HELP_CY_LIBS_SEARCH_DEPTH_VERBOSE=This variable controls how deep (directory) the search mechanism in getlibs looks for .lib files.\
					$(CY_NEWLINE)Note: Deeper searches take longer to process.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make getlibs CY_LIBS_SEARCH_DEPTH=7
CY_HELP_CY_UTILS_SEARCH_DEPTH=Search depth for .cyignore and <TARGET>.mk files (Default: 5).
CY_HELP_CY_UTILS_SEARCH_DEPTH_VERBOSE=This variable controls how deep (directory) the search mechanism looks for .cyignore\
					and <TARGET>.mk files. Min=1, Max=9.\
					$(CY_NEWLINE)Note: Deeper searches take longer to process.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make getlibs CY_UTILS_SEARCH_DEPTH=7
CY_HELP_CY_EXTRA_INCLUDES=Specifies additional makefiles to add to the build.
CY_HELP_CY_EXTRA_INCLUDES_VERBOSE=This variable provides a way of injecting additional make files into the core make files.\
					It can be used when including the make file before or after start.mk in the application makefile is not possible.\
					$(CY_NEWLINE)$(CY_NEWLINE)Example Usage: make build CY_EXTRA_INCLUDES="./custom1.mk"

# Pass these to CY_HELP to get the full verbose info
CY_HELP_TARGETS_ALL=all getlibs build qbuild program qprogram debug qdebug attach clean help eclipse vscode ewarm8 uvision5 open modlibs \
					config config_bt config_usbdev config_secure bsp progtool check get_app_info get_env_info printlibs import_deps lib2mtbx
CY_HELP_BASIC_CFG_ALL=TARGET APPNAME LIBNAME TOOLCHAIN CONFIG VERBOSE
CY_HELP_ADVANCED_CFG_ALL=SOURCES INCLUDES DEFINES VFP_SELECT CFLAGS CXXFLAGS ASFLAGS LDFLAGS LDLIBS LINKER_SCRIPT \
					PREBUILD POSTBUILD COMPONENTS DISABLE_COMPONENTS SEARCH_LIBS_AND_INCLUDES \
					DEPENDENT_LIB_PATHS DEPENDENT_APP_PATHS SEARCH
CY_HELP_BSP_ALL=DEVICE TARGET_GEN DEVICE_GEN
CY_HELP_GETLIBS_ALL=CY_GETLIBS_NO_CACHE CY_GETLIBS_OFFLINE CY_GETLIBS_PATH CY_GETLIBS_DEPS_PATH CY_GETLIBS_CACHE_PATH \
					CY_GETLIBS_OFFLINE_PATH CY_GETLIBS_SEARCH_PATH CY_GETLIBS_SHARED_PATH CY_GETLIBS_SHARED_NAME
CY_HELP_PATHS_ALL=CY_APP_PATH CY_BASELIB_PATH CY_BASELIB_CORE_PATH CY_EXTAPP_PATH CY_DEVICESUPPORT_PATH \
					CY_SHARED_PATH CY_COMPILER_PATH CY_TOOLS_DIR CY_BUILD_LOCATION TOOLCHAIN_MK_PATH CY_PYTHON_PATH
CY_HELP_MISC_ALL=CY_IGNORE CY_IDE_PRJNAME CY_CONFIG_FILE_EXT CY_SKIP_RECIPE CY_SUPPORTED_TOOL_TYPES CY_LIBS_SEARCH_DEPTH \
					CY_UTILS_SEARCH_DEPTH CY_EXTRA_INCLUDES
CY_HELP_PRINT_ALL=$(CY_HELP_TARGETS_ALL) $(CY_HELP_BASIC_CFG_ALL) $(CY_HELP_ADVANCED_CFG_ALL) $(CY_HELP_BSP_ALL) \
					$(CY_HELP_GETLIBS_ALL) $(CY_HELP_PATHS_ALL) $(CY_HELP_MISC_ALL)

help: help_default

help_default:
ifneq ($(CY_HELP),)
	@:
	$(foreach topic,$(CY_HELP),\
	$(info $(CY_NEWLINE)Topic-specific help for "$(topic)")\
	$(info $(CY_SPACE)$(CY_SPACE)Brief: $(CY_HELP_$(topic)))\
	$(info $(CY_NEWLINE)$(CY_HELP_$(topic)_VERBOSE)))
else
	@:
	$(info                                                                                    )
	$(info ==============================================================================     )
	$(info $(CY_SPACE)Cypress Build System                                                    )
	$(info ==============================================================================     )
	$(info $(CY_SPACE)Copyright 2018-2020 Cypress Semiconductor Corporation                   )
	$(info $(CY_SPACE)SPDX-License-Identifier: Apache-2.0                                     )
	$(info                                                                                    )
	$(info $(CY_SPACE)Licensed under the Apache License, Version 2.0 (the "License");         )
	$(info $(CY_SPACE)you may not use this file except in compliance with the License.        )
	$(info $(CY_SPACE)You may obtain a copy of the License at                                 )
	$(info                                                                                    )
	$(info $(CY_SPACE)$(CY_SPACE)    http://www.apache.org/licenses/LICENSE-2.0               )
	$(info                                                                                    )
	$(info $(CY_SPACE)Unless required by applicable law or agreed to in writing, software     )
	$(info $(CY_SPACE)distributed under the License is distributed on an "AS IS" BASIS,       )
	$(info $(CY_SPACE)WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.)
	$(info $(CY_SPACE)See the License for the specific language governing permissions and     )
	$(info $(CY_SPACE)limitations under the License.                                          )
	$(info ==============================================================================     )
	$(info                                                                                    )
	$(info $(CY_SPACE)This is the help documentation for the Cypress build system.            )
	$(info $(CY_SPACE)It lists the supported make targets and make variables.                 )
	$(info                                                                                    )
	$(info $(CY_SPACE)Usage:   make [target][variable]                                        )
	$(info $(CY_SPACE)Example: make build TARGET=CY8CPROTO-062-4343W                          )
	$(info                                                                                    )
	$(info $(CY_SPACE)The CY_HELP make variable can be used for information on a particular   )
	$(info $(CY_SPACE)make target or variable                                                 )
	$(info                                                                                    )
	$(info $(CY_SPACE)Usage:   make help CY_HELP=[target/variable]                            )
	$(info $(CY_SPACE)Example: make help CY_HELP=APPNAME                                      )
	$(info                                                               )
	$(info =======================================                       )
	$(info $(CY_SPACE)General make targets                               )
	$(info =======================================                       )
	$(info $(CY_SPACE)all                 $(CY_HELP_all))
	$(info $(CY_SPACE)getlibs             $(CY_HELP_getlibs))
	$(info $(CY_SPACE)build               $(CY_HELP_build))
	$(info $(CY_SPACE)qbuild              $(CY_HELP_qbuild))
	$(info $(CY_SPACE)program             $(CY_HELP_program))
	$(info $(CY_SPACE)qprogram            $(CY_HELP_qprogram))
	$(info $(CY_SPACE)debug               $(CY_HELP_debug))
	$(info $(CY_SPACE)qdebug              $(CY_HELP_qdebug))
	$(info $(CY_SPACE)attach              $(CY_HELP_attach))
	$(info $(CY_SPACE)clean               $(CY_HELP_clean))
	$(info $(CY_SPACE)help                $(CY_HELP_help))
	$(info                                                               )
	$(info =======================================                       )
	$(info $(CY_SPACE)IDE make targets                                   )
	$(info =======================================                       )
	$(info $(CY_SPACE)eclipse             $(CY_HELP_eclipse))
	$(info $(CY_SPACE)vscode              $(CY_HELP_vscode))
	$(info $(CY_SPACE)ewarm8              $(CY_HELP_ewarm8))
	$(info $(CY_SPACE)uvision5            $(CY_HELP_uvision5))
	$(info                                                               )
	$(info =======================================                       )
	$(info $(CY_SPACE)Tools make targets                                 )
	$(info =======================================                       )
	$(info $(CY_SPACE)open                $(CY_HELP_open))
	$(info $(CY_SPACE)modlibs             $(CY_HELP_modlibs))
	$(info $(CY_SPACE)config              $(CY_HELP_config))
	$(info $(CY_SPACE)config_bt           $(CY_HELP_config_bt))
	$(info $(CY_SPACE)config_usbdev       $(CY_HELP_config_usbdev))
	$(info $(CY_SPACE)config_secure       $(CY_HELP_config_secure))
	$(info $(CY_SPACE)config_ezpd         $(CY_HELP_config_ezpd))
	$(info $(CY_SPACE)config_lin          $(CY_HELP_config_lin))
	$(info                                                               )
	$(info =======================================                       )
	$(info $(CY_SPACE)Utility make targets                               )
	$(info =======================================                       )
	$(info $(CY_SPACE)progtool            $(CY_HELP_progtool))
	$(info $(CY_SPACE)bsp                 $(CY_HELP_bsp))
	$(info $(CY_SPACE)update_bsp          $(CY_HELP_update_bsp))
	$(info $(CY_SPACE)lib2mtbx            $(CY_HELP_lib2mtbx))
	$(info $(CY_SPACE)import_deps         $(CY_HELP_import_deps))
	$(info $(CY_SPACE)get_app_info        $(CY_HELP_get_app_info))
	$(info $(CY_SPACE)get_env_info        $(CY_HELP_get_env_info))
	$(info $(CY_SPACE)printlibs           $(CY_HELP_printlibs))
	$(info $(CY_SPACE)check               $(CY_HELP_check))
	$(info                                                               )
	$(info =======================================                       )
	$(info $(CY_SPACE)Basic configuration make variables                 )
	$(info =======================================                       )
	$(info $(CY_SPACE)TARGET              $(CY_HELP_TARGET))
	$(info $(CY_SPACE)APPNAME             $(CY_HELP_APPNAME))
	$(info $(CY_SPACE)LIBNAME             $(CY_HELP_LIBNAME))
	$(info $(CY_SPACE)TOOLCHAIN           $(CY_HELP_TOOLCHAIN))
	$(info $(CY_SPACE)CONFIG              $(CY_HELP_CONFIG))
	$(info $(CY_SPACE)VERBOSE             $(CY_HELP_VERBOSE))
	$(info                                                               )
	$(info =======================================                       )
	$(info $(CY_SPACE)Advanced configuration make variables              )
	$(info =======================================                       )
	$(info $(CY_SPACE)SOURCES             $(CY_HELP_SOURCES))
	$(info $(CY_SPACE)INCLUDES            $(CY_HELP_INCLUDES))
	$(info $(CY_SPACE)DEFINES             $(CY_HELP_DEFINES))
	$(info $(CY_SPACE)VFP_SELECT          $(CY_HELP_VFP_SELECT))
	$(info $(CY_SPACE)CFLAGS              $(CY_HELP_CFLAGS))
	$(info $(CY_SPACE)CXXFLAGS            $(CY_HELP_CXXFLAGS))
	$(info $(CY_SPACE)ASFLAGS             $(CY_HELP_ASFLAGS))
	$(info $(CY_SPACE)LDFLAGS             $(CY_HELP_LDFLAGS))
	$(info $(CY_SPACE)LDLIBS              $(CY_HELP_LDLIBS))
	$(info $(CY_SPACE)LINKER_SCRIPT       $(CY_HELP_LINKER_SCRIPT))
	$(info $(CY_SPACE)PREBUILD            $(CY_HELP_PREBUILD))
	$(info $(CY_SPACE)POSTBUILD           $(CY_HELP_POSTBUILD))
	$(info $(CY_SPACE)COMPONENTS          $(CY_HELP_COMPONENTS))
	$(info $(CY_SPACE)DISABLE_COMPONENTS  $(CY_HELP_DISABLE_COMPONENTS))
	$(info $(CY_SPACE)DEPENDENT_LIB_PATHS  $(CY_HELP_DEPENDENT_LIB_PATHS))
	$(info $(CY_SPACE)DEPENDENT_APP_PATHS  $(CY_HELP_DEPENDENT_APP_PATHS))
	$(info $(CY_SPACE)SEARCH              $(CY_HELP_SEARCH))
	$(info $(CY_SPACE)IMPORT_PATH         $(CY_HELP_IMPORT_PATH))
	$(info $(CY_SPACE)CONVERSION_PATH     $(CY_HELP_CONVERSION_PATH))
	$(info $(CY_SPACE)CONVERSION_TYPE     $(CY_HELP_CONVERSION_TYPE))
	$(info $(CY_SPACE)FORCE               $(CY_HELP_FORCE))
	$(info                                                               )
	$(info =======================================                       )
	$(info $(CY_SPACE)BSP make variables                                 )
	$(info =======================================                       )
	$(info $(CY_SPACE)DEVICE              $(CY_HELP_DEVICE))
	$(info $(CY_SPACE)TARGET_GEN          $(CY_HELP_TARGET_GEN))
	$(info $(CY_SPACE)DEVICE_GEN          $(CY_HELP_DEVICE_GEN))
	$(info                                                               )
	$(info =======================================                       )
	$(info $(CY_SPACE)Getlibs make variables                             )
	$(info =======================================                       )
	$(info $(CY_SPACE)CY_GETLIBS_NO_CACHE $(CY_HELP_CY_GETLIBS_NO_CACHE))
	$(info $(CY_SPACE)CY_GETLIBS_OFFLINE  $(CY_HELP_CY_GETLIBS_OFFLINE))
	$(info $(CY_SPACE)CY_GETLIBS_PATH     $(CY_HELP_CY_GETLIBS_PATH))
	$(info $(CY_SPACE)CY_GETLIBS_DEPS_PATH  $(CY_HELP_CY_GETLIBS_DEPS_PATH))
	$(info $(CY_SPACE)CY_GETLIBS_CACHE_PATH  $(CY_HELP_CY_GETLIBS_CACHE_PATH))
	$(info $(CY_SPACE)CY_GETLIBS_OFFLINE_PATH  $(CY_HELP_CY_GETLIBS_OFFLINE_PATH))
	$(info $(CY_SPACE)CY_GETLIBS_SEARCH_PATH  $(CY_HELP_CY_GETLIBS_SEARCH_PATH))
	$(info $(CY_SPACE)CY_GETLIBS_SHARED_PATH $(CY_HELP_CY_GETLIBS_SHARED_PATH))
	$(info $(CY_SPACE)CY_GETLIBS_SHARED_NAME $(CY_HELP_CY_GETLIBS_SHARED_NAME))
	$(info                                                               )
	$(info =======================================                       )
	$(info $(CY_SPACE)Path make variables                                )
	$(info =======================================                       )
	$(info $(CY_SPACE)CY_APP_PATH         $(CY_HELP_CY_APP_PATH))
	$(info $(CY_SPACE)CY_BASELIB_PATH     $(CY_HELP_CY_BASELIB_PATH))
	$(info $(CY_SPACE)CY_BASELIB_CORE_PATH  $(CY_HELP_CY_BASELIB_CORE_PATH))
	$(info $(CY_SPACE)CY_EXTAPP_PATH      $(CY_HELP_CY_EXTAPP_PATH))
	$(info $(CY_SPACE)CY_COMPILER_PATH    $(CY_HELP_CY_COMPILER_PATH))
	$(info $(CY_SPACE)CY_TOOLS_DIR        $(CY_HELP_CY_TOOLS_DIR))
	$(info $(CY_SPACE)CY_BUILD_LOCATION   $(CY_HELP_CY_BUILD_LOCATION))
	$(info $(CY_SPACE)CY_PYTHON_PATH      $(CY_HELP_CY_PYTHON_PATH))
	$(info $(CY_SPACE)CY_DEVICESUPPORT_PATH  $(CY_HELP_CY_DEVICESUPPORT_PATH))
	$(info $(CY_SPACE)TOOLCHAIN_MK_PATH   $(CY_HELP_TOOLCHAIN_MK_PATH))
	$(info                                                               )
	$(info =======================================                       )
	$(info $(CY_SPACE)Miscellaneous make variables                       )
	$(info =======================================                       )
	$(info $(CY_SPACE)CY_IGNORE           $(CY_HELP_CY_IGNORE))
	$(info $(CY_SPACE)CY_SKIP_RECIPE      $(CY_HELP_CY_SKIP_RECIPE))
	$(info $(CY_SPACE)CY_SKIP_CDB         $(CY_HELP_CY_SKIP_CDB))
	$(info $(CY_SPACE)CY_EXTRA_INCLUDES   $(CY_HELP_CY_EXTRA_INCLUDES))
	$(info $(CY_SPACE)CY_LIBS_SEARCH_DEPTH  $(CY_HELP_CY_LIBS_SEARCH_DEPTH))
	$(info $(CY_SPACE)CY_UTILS_SEARCH_DEPTH  $(CY_HELP_CY_UTILS_SEARCH_DEPTH))
	$(info $(CY_SPACE)CY_IDE_PRJNAME      $(CY_HELP_CY_IDE_PRJNAME))
	$(info $(CY_SPACE)CY_CONFIG_FILE_EXT  $(CY_HELP_CY_CONFIG_FILE_EXT))
	$(info $(CY_SPACE)CY_SUPPORTED_TOOL_TYPES  $(CY_HELP_CY_SUPPORTED_TOOL_TYPES))
	$(info )
endif

#
# Identify the phony targets
#
.PHONY: help help_default
