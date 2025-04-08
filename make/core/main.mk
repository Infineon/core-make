################################################################################
# \file main.mk
#
# \brief
# Defines the public facing build targets common to all recipes and includes
# the core makefiles.
#
################################################################################
# \copyright
# (c) 2018-2025, Cypress Semiconductor Corporation (an Infineon company) or
# an affiliate of Cypress Semiconductor Corporation. All rights reserved.
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

################################################################################
# Application support
################################################################################

ifeq ($(MTB_TYPE),PROJECT)
_MTB_RECIPE__APPLICATION_RELATIVE=..
ifeq ($(MTB_APPLICATION_SUBPROJECTS),)
ifneq ($(filter $(MAKECMDGOALS),all build qbuild program qprogram clean eclipse vscode),)
# We are directly calling make target from the project that belongs to multi-core
# application - pass this target to the application level
MTB_CORE__APPLICATION_BOOTSTRAP=true
endif
endif
else
_MTB_RECIPE__APPLICATION_RELATIVE=.
endif

clean_proj:
	rm -rf $(MTB_TOOLS__OUTPUT_BASE_DIR)

# Backwards-compatibility variables
include $(MTB_TOOLS__CORE_DIR)/make/core/bwc.mk

################################################################################
# User-facing make targets
################################################################################

all: build

getlibs:

prebuild:

build build_proj qbuild qbuild_proj:

program program_proj qprogram qprogram_proj:

debug qdebug:

clean clean_proj:

# Note: Define the help target in BSP/recipe for custom help
help:

eclipse vscode ewarm ewarm8 uvision uvision5:

check get_app_info get_env_info printlibs check_toolchain:

memcalc application_postbuild mtb_conditional_postbuild project_postbuild:

include $(MTB_TOOLS__CORE_DIR)/make/core/application_bootstrap.mk

FORCE:
_MTB_CORE__SKIP_BUILD_MK_FILES:=
ifeq ($(MTB_CORE__APPLICATION_BOOTSTRAP),)

_MTB_CORE__QBUILD_MK_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/cyqbuild.mk
_MTB_CORE__NINJA_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).ninja
ifneq ($(filter $(MAKECMDGOALS),all build build_proj app program program_proj debug erase attach eclipse vscode ewarm8 uvision5 ewarm uvision),)
$(_MTB_CORE__NINJA_FILE): FORCE prebuild
ifeq ($(MAKE_RESTARTS),)
$(_MTB_CORE__QBUILD_MK_FILE): FORCE prebuild
endif
endif

# optimization if command is not one of these (i.e. clean) then don't load files like build.mk and program.mk
ifeq ($(filter $(MAKECMDGOALS),all build build_proj qbuild qbuild_proj app program program_proj qprogram qprogram_proj debug qdebug erase attach eclipse vscode ewarm8 uvision5 ewarm uvision),)
_MTB_CORE__SKIP_BUILD_MK_FILES:=1
endif

$(_MTB_CORE__QBUILD_MK_FILE) $(_MTB_CORE__NINJA_FILE):| start_build

##########################
# Include make files
##########################

#
# Include utilities used by all make files
#
include $(MTB_TOOLS__CORE_DIR)/make/core/core_utils.mk

include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/core_selection.mk

# The GCC_ARM readelf is used by all toolchain build for memory calculation. So always include GCC_ARM toolchain.
-include $(MTB_TOOLS__RECIPE_DIR)/make/toolchains/GCC_ARM.mk
ifneq ($(TOOLCHAIN),GCC_ARM)
include $(MTB_TOOLS__RECIPE_DIR)/make/toolchains/$(TOOLCHAIN).mk
endif

include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/recipe_toolchain_file_types.mk

include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/defines.mk

include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/recipe_setup.mk

_MTB_CORE__LIB_MK=$(wildcard $(foreach dir,$(SEARCH_MTB_MK),$(dir)/library.mk))
-include $(_MTB_CORE__LIB_MK)

ifeq ($(MTB_LIBRARY__SKIP_LOAD_MAIN_MK),)

#
# Configurator-related routines
#
include $(MTB_TOOLS__CORE_DIR)/make/core/config.mk

#
# Export interface version set up for IDE file generation
#
_MTB_CORE__EXPORT_SUPPORTED_INTERFACES:=1 2 3 4
_MTB_CORE__ALL_SUPPORTED_EXPORT_VERSION:=$(filter $(filter $(_MTB_CORE__EXPORT_SUPPORTED_INTERFACES),$(CY_TOOL_mtbideexport_EXPORT_SUPPORTED_INTERFACES)),$(MTB_RECIPE__EXPORT_INTERFACES))

ifneq ($(_MTB_CORE__ALL_SUPPORTED_EXPORT_VERSION),)
_MTB_CORE__EXPORT_INTERFACE_VERSION:=$(lastword $(_MTB_CORE__ALL_SUPPORTED_EXPORT_VERSION))
else
_MTB_CORE__EXPORT_INTERFACE_VERSION:=1
ifeq ($(CY_TOOL_mtbideexport_EXPORT_INTERFACE),3.1)
ifeq ($(MTB_RECIPE__INTERFACE_VERSION),2)
_MTB_CORE__EXPORT_INTERFACE_VERSION:=2
endif #($(MTB_RECIPE__INTERFACE_VERSION),2)
ifeq ($(filter 2,$(MTB_RECIPE__EXPORT_INTERFACES)),2)
_MTB_CORE__EXPORT_INTERFACE_VERSION:=2
endif #($(filter 2,$(MTB_RECIPE__EXPORT_INTERFACES)),2)
endif #($(CY_TOOL_mtbideexport_EXPORT_INTERFACE),3.1)
endif #($(_MTB_CORE__ALL_SUPPORTED_EXPORT_VERSION),)

ifeq ($(filter $(MAKECMDGOALS),get_app_info getlibs),)
ifeq ($(MTB_RECIPE__NINJA_SUPPORT),)
$(error $(MTB__NEWLINE)$(MTB__NEWLINE)Error: The current version of core-make is incompatible with the current version of recipe-make.\
$(MTB__NEWLINE)See https://community.infineon.com/t5/ModusToolbox/ModusToolbox-incompatible-core-make-version-error-message/td-p/918743 for more information.$(MTB__NEWLINE)$(MTB__NEWLINE))
endif
endif
# Set ninja as default if all assets support a matching version
_MTB_CORE__NINJA_SUPPORT:=1 2
_MTB_CORE__NINJA_VERSIONS_SUPPORTED:=$(filter $(filter $(MTB_RECIPE__NINJA_SUPPORT),$(_MTB_CORE__NINJA_SUPPORT)),$(MTB_TOOLS__NINJA_SUPPORT))
NINJA?=$(_MTB_CORE__NINJA_VERSIONS_SUPPORTED)

#
# Targets that require auto-discovery
#
ifeq ($(NINJA),)
_MTB_CORE__AUTO_DISCOVERY_FILE:=$(_MTB_CORE__QBUILD_MK_FILE)
else
_MTB_CORE__AUTO_DISCOVERY_FILE:=$(_MTB_CORE__NINJA_FILE)
endif
build build_proj qbuild qbuild_proj app program program_proj: $(_MTB_CORE__AUTO_DISCOVERY_FILE)

################################################################################
# Include make files continued only for first build stage
################################################################################

# Check that there's only 1 version of tools and inform the user if there is not.
ifneq ($(sort $(notdir $(wildcard $(CY_TOOLS_PATHS)))),$(notdir $(CY_TOOLS_DIR)))
$(info INFO: Multiple tools versions were found in "$(sort $(CY_TOOLS_PATHS))".\
				This build is currently using "$(CY_TOOLS_DIR)".\
				Check that this is the correct version that should be used in this build.\
				To stop seeing this message, set the CY_TOOLS_PATHS environment variable to the location of\
				the tools directory. This can be done either as an environment variable or set in the application Makefile.)
endif

#
# Help documentation
#
include $(MTB_TOOLS__CORE_DIR)/make/core/help.mk

include $(MTB_TOOLS__CORE_DIR)/make/core/prebuild.mk
include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/recipe.mk

#
# Device transtion related targets
#
include $(MTB_TOOLS__CORE_DIR)/make/core/transition.mk

##########################
# Environment check
##########################

#
# Toolchain compatibility check
#
check_toolchain:
	$(if $(filter $(TOOLCHAIN),$(MTB_SUPPORTED_TOOLCHAINS) $(CY_SUPPORTED_TOOLCHAINS)),\
	$(info Toolchain validation: PASS),\
	$(error Toolchain validation: FAIL. The TOOLCHAIN=$(TOOLCHAIN) value is not supported. \
					Supported TOOLCHAIN values are: \
					$(sort $(MTB_SUPPORTED_TOOLCHAINS) $(CY_SUPPORTED_TOOLCHAINS))))

ifeq ($(CY_PYTHON_REQUIREMENT),true)
ifeq ($(CY_PYTHON_PATH),)

ifeq ($(OS),Windows_NT)
#
# CygWin/MSYS
#

#
# On Windows, when using windows store python, cygwin or msys are not
# able to run the python executable downloaded from windows store. So,
# we run python from command prompt (in cygwin/msys) by prepending
# cmd /c.
# Do not remove the space at the end of the following variable assignment
#
CY_PYTHON_FROM_CMD=cmd /c 

#
# Other Windows environments
#
else
CY_PYTHON_FROM_CMD=
endif

# Look for python install in the cypress tools directory
ifeq ($(wildcard $(CY_TOOL_python_EXE_ABS)),)
CY_PYTHON_SEARCH_PATH=NotFoundError
else
CY_PYTHON_SEARCH_PATH=$(CY_TOOL_python_EXE_ABS)
endif

#
# Check for python 3 intallation in the user's PATH
#   python - Mapped python3 to python
#   python3 - Standard python3
#   py -3 - Windows python installer from python.org
#
ifeq ($(CY_PYTHON_SEARCH_PATH),NotFoundError)
CY_PYTHON_SEARCH_PATH:=$(shell \
	if [[ $$($(CY_PYTHON_FROM_CMD)python --version 2>&1) == "Python 3"* ]]; then\
		echo $(MTB_TOOLS__CORE_DIR)/make/scripts/python.bash;\
	elif [[ $$($(CY_PYTHON_FROM_CMD)python3 --version 2>&1) == "Python 3"* ]]; then\
		echo $(MTB_TOOLS__CORE_DIR)/make/scripts/python3.bash;\
	elif [[ $$(py -3 --version 2>&1) == "Python 3"* ]]; then\
		echo $(MTB_TOOLS__CORE_DIR)/make/scripts/py.bash;\
	else\
		echo NotFoundError;\
	fi)
endif

ifeq ($(CY_PYTHON_SEARCH_PATH),NotFoundError)
$(info )
$(info Python 3 was not found in the user's PATH and it was not explicitly defined in the CY_PYTHON_PATH variable.\
This target requires a python 3 installation. You can obtain python 3 from "https://www.python.org" or you may\
obtain it using the following alternate methods.$(MTB_NEWLINE)\
$(MTB_NEWLINE)\
Windows: Windows Store$(MTB_NEWLINE)\
macOS: brew install python3 $(MTB_NEWLINE)\
Linux (Debian/Ubuntu): sudo apt-get install python3 $(MTB_NEWLINE)\
)
$(call mtb__error,)
endif

export CY_PYTHON_PATH=$(CY_PYTHON_SEARCH_PATH)

# User specified python path
else

ifeq ($(shell [[ $$($(CY_PYTHON_FROM_CMD)$(CY_PYTHON_PATH) --version 2>&1) == "Python 3"* ]] && { echo true; } || { echo false; }),false)
$(info The path "$(CY_PYTHON_PATH)" is either an invalid path or contains an incorrect version of python.$(MTB_NEWLINE)\
Please provide the path to the python 3 executable. For example, "usr/bin/python3".$(MTB_NEWLINE) )
$(call mtb__error,)
endif

endif # ifeq ($(CY_PYTHON_PATH),)
endif # ifeq ($(CY_PYTHON_REQUIREMENT),true)

start_build: check_recipe check_toolchain 
	@:
	$(info Initializing build: $(APPNAME)$(LIBNAME) $(CONFIG) $(TARGET) $(TOOLCHAIN))

check_recipe: check_toolchain
ifeq ($(wildcard $(MTB_TOOLS__RECIPE_DIR)),)
	$(info )
	$(call mtb__error,Cannot find recipe-make. Run "make getlibs" and/or check\
	the location is correct in the CY_BASELIB_PATH variable)
endif

################################################################################
# Include make files continued for second build stage
################################################################################

##########################
# User input check
##########################

ifeq ($(_MTB_CORE__SKIP_BUILD_MK_FILES),)

ifneq ($(APPNAME),)
ifneq ($(LIBNAME),)
$(call mtb__error,An application cannot define both APPNAME and LIBNAME. Define one or the other)
endif
endif
ifneq ($(filter -I%,$(INCLUDES)),)
$(call mtb__error,INCLUDES must be directories without -I prepended)
endif
ifneq ($(filter -D%,$(DEFINES)),)
$(call mtb__error,DEFINES must be specified without -D prepended)
endif
ifneq ($(filter -I%,$(CFLAGS)),)
$(call mtb__error,Include paths must be specified in the INCLUDES variable instead\
of directly in CFLAGS. These must be directories without -I prepended)
endif
ifneq ($(filter -D%,$(CFLAGS)),)
$(call mtb__error,Defines must be specified in the DEFINES variable instead\
of directly in CFLAGS. These must be specified without -D prepended)
endif
ifneq ($(filter -I%,$(CXXFLAGS)),)
$(call mtb__error,Include paths must be specified in the INCLUDES variable instead\
of directly in CXXFLAGS. These must be directories without -I prepended)
endif
ifneq ($(filter -D%,$(CXXFLAGS)),)
$(call mtb__error,Defines must be specified in the DEFINES variable instead\
of directly in CXXFLAGS. These must be specified without -D prepended)
endif
ifneq ($(filter -I%,$(ASFLAGS)),)
$(call mtb__error,Include paths must be specified in the INCLUDES variable instead\
of directly in ASFLAGS. These must be directories without -I prepended)
endif
ifneq ($(filter -D%,$(ASFLAGS)),)
$(call mtb__error,Defines must be specified in the DEFINES variable instead\
of directly in ASFLAGS. These must be specified without -D prepended)
endif

##########################
# Search and build
##########################
#
# Build-related routines
#
_MTB_CORE__LOAD_QBUILD_MK_FILE:=

ifeq ($(NINJA),)
_MTB_CORE__LOAD_QBUILD_MK_FILE:=1
endif

# IDE export will use old auto-discovery if unless new mtbninja can also generate the qbuild.mk file.
ifneq ($(filter $(MAKECMDGOALS),eclipse vscode ewarm8 uvision5 ewarm uvision),)
_MTB_CORE__LOAD_QBUILD_MK_FILE:=1
endif
ifneq ($(CY_SIMULATOR_GEN_AUTO),)
_MTB_CORE__LOAD_QBUILD_MK_FILE:=1
endif

ifneq ($(ASSET_ARCHIVES),)
_MTB_CORE__ASSET_ARCHIVES=--archive-assets
else
_MTB_CORE__ASSET_ARCHIVES=
endif

ifneq ($(_MTB_CORE__LOAD_QBUILD_MK_FILE),)
include $(_MTB_CORE__QBUILD_MK_FILE)
ifneq ($(MTB_GENERATE_DEPENDENCIES),)
include $(MTB_TOOLS__CORE_DIR)/make/core/search_filter_v2.mk
else
include $(MTB_TOOLS__CORE_DIR)/make/core/search_filter_v1.mk
endif
endif

ifeq ($(NINJA),)
ifneq ($(MTB_GENERATE_DEPENDENCIES),)
include $(MTB_TOOLS__CORE_DIR)/make/core/build_v2.mk
else
include $(MTB_TOOLS__CORE_DIR)/make/core/build_v1.mk
endif
include $(MTB_TOOLS__CORE_DIR)/make/core/search.mk

else
include $(MTB_TOOLS__CORE_DIR)/make/core/ninja.mk
endif

include $(MTB_TOOLS__CORE_DIR)/make/core/postbuild.mk
#
# Setup JLink path for IDE export and make program
#
include $(MTB_TOOLS__CORE_DIR)/make/core/jlink.mk

#
# Optional recipe-specific program routine
#
-include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/program.mk

ifneq ($(_MTB_CORE__EXPORT_INTERFACE_VERSION),1)
uvision: uvision5
ewarm: ewarm8
endif
-include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/interface_version_$(_MTB_CORE__EXPORT_INTERFACE_VERSION)/recipe_ide.mk
include $(MTB_TOOLS__CORE_DIR)/make/core/interface_version_$(_MTB_CORE__EXPORT_INTERFACE_VERSION)/ide.mk

endif #ifneq ($(_MTB_CORE__SKIP_BUILD_MK_FILES),)

endif #ifeq ($(MTB_LIBRARY__SKIP_LOAD_MAIN_MK),)

endif #ifeq ($(MTB_CORE__APPLICATION_BOOTSTRAP),)

#
# Identify the phony targets
#
.PHONY: all getlibs clean clean_proj help
.PHONY: modlibs config config_bt config_usbdev config_secure config_ezpd config_lin
.PHONY: bsp check get_env_info printlibs check_toolchain check_recipe start_build
.PHONY: app memcalc help_default mtb_conditional_postbuild

.PHONY: build build_proj qbuild qbuild_proj
.PHONY: program program_proj qprogram debug qdebug erase attach
