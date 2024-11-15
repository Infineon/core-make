################################################################################
# \file core_utils.mk
#
# \brief
# Global utilities used across the application recipes and BSPs
#
################################################################################
# \copyright
# Copyright 2018-2024 Cypress Semiconductor Corporation
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
# Components
################################################################################

#
# VFP-specific component
#
ifeq ($(VFP_SELECT),hardfp)
CY_COMPONENT_VFP:=HARDFP
else
CY_COMPONENT_VFP:=SOFTFP
endif

MTB_CORE__FULL_COMPONENT_LIST=$(sort $(MTB_RECIPE__CORE) $(MTB_RECIPE__CORE_NAME) $(CY_COMPONENT_VFP) $(COMPONENTS) $(TOOLCHAIN) $(TARGET) $(CONFIG) $(MTB_RECIPE__COMPONENT) $(DEVICE_COMPONENTS) $(BSP_COMPONENTS))

_MTB_CORE__FULL_SEARCH_ROOTS=$(strip $(SEARCH) $(SEARCH_MTB_MK))

################################################################################
# Defines
################################################################################

#
# VFP-specific defines
#
ifeq ($(VFP_SELECT),softfloat)
DEFINES+=MTB_SOFTFLOAT
endif

################################################################################
# Macros
################################################################################

#
# Convert a relative or absolute path to absolute path
# 
# $1 : the path to convert
#
ifeq ($(OS),Windows_NT)
# NOTE: Cannot use $(abspath) function on windows as it might generate a cygwin path.
# Which we would require a very slow function to convert back to windows path for each path.
# Instead we run cygpath once and just prepend that to the path.
_MTB_CORE__WIN_PROJECT_ABSPATH:=$(call mtb__path_normalize,.)
_MTB_CORE__WIN_ABSPATH_FILTER:=A:/% B:/% C:/% D:/% E:/% F:/% G:/% H:/% I:/% J:/% K:/% L:/% M:/% N:/% O:/% P:/% Q:/% R:/% S:/% T:/% U:/% V:/% W:/% X:/% Y:/% Z:/%
mtb_core__abspath=$(if $(filter $(_MTB_CORE__WIN_ABSPATH_FILTER),$1),$1,$(_MTB_CORE__WIN_PROJECT_ABSPATH)/$1)
else
mtb_core__abspath=$(abspath $1)
endif

mtb_core__search_in_path=$(if $(shell type -P $(1)),$(1),)

#
# Prints for bypassing TARGET/DEVICE checks
# $(1) : String to print
#
ifneq (,$(filter build build_proj qbuild qbuild_proj program program_proj debug,$(MAKECMDGOALS)))
_MTB_CORE__FAIL_ON_ERROR:=true
endif
ifeq ($(_MTB_CORE__FAIL_ON_ERROR),true)
mtb__error=$(error $(1))
else
mtb__error=$(info WARNING: $(1))
endif

#
# Get unquoted path with escaped spaces
# $(1) : path for which quotes and escapes should be removed but spaces should be escaped
#
mtb_core__escaped_path=$(subst $(MTB__OPEN_PAREN),\$(MTB__OPEN_PAREN),$(subst $(MTB__CLOSE_PAREN),\$(MTB__CLOSE_PAREN),$(subst $(MTB__SPACE),\$(MTB__SPACE),$(1))))


# escape " and \ for json
mtb_core__json_escaped_string=$(subst ",\",$(subst \,\\,$(strip $1)))

#
# Prints the warning and creates a variable to hold that warning (for printing later)
# Note that this doesn't use the $(warning) function as that adds the line number (not useful for end user)
# $(1) : Message ID
# $(2) : String to print
#
define CY_MACRO_WARNING
$(info )
$(info $(2))
CY_WARNING_$(1)=$(2)
endef

#
# Prints the info and creates a variable to hold that info (for printing later)
# $(1) : Message ID
# $(2) : String to print
#
define CY_MACRO_INFO
$(info )
$(info $(2))
CY_INFO_$(1)=$(2)
endef

################################################################################
# Misc.
################################################################################

# Create a maker that can be used by a replace operation to insert a newline
MTB__NEWLINE_MARKER:=__!__

################################################################################
# Utility targets
################################################################################

bsp:
	@:
	$(error Make bsp target is no longer supported. Use BSP assistant tool instead.)

update_bsp:
	@:
	$(error Make bsp target is no longer supported. Use BSP assistant tool instead.)


################################################################################
# Test/debug targets
################################################################################

CY_TOOLS_LIST+=bash git find ls cp mkdir rm cat sed awk perl file whereis

check:
	@:
	$(info )
	$(foreach tool,$(CY_TOOLS_LIST),$(if $(shell which $(tool)),\
		$(info SUCCESS: "$(tool)" found in PATH),$(info FAILED : "$(tool)" was not found in PATH)$(info )))
	$(info )
	$(info Tools check complete.)
	$(info )

get_env_info:
	$(MTB__NOISE)echo;\
	echo "make location :" $$(which make);\
	echo "make version  :" $(MAKE_VERSION);\
	echo "git location  :" $$(which git);\
	echo "git version   :" $$(git --version);\
	echo "git remote    :";\
	git remote -v;\
	echo "git rev-parse :" $$(git rev-parse HEAD)

printlibs:

# Defined in recipe's program.mk
progtool:

# Empty libs on purpose. May be defined by the application
shared_libs:

ifeq ($(CY_PROTOCOL),)
MTB_CORE__CY_PROTOCOL_VERSION:=2
else
MTB_CORE__CY_PROTOCOL_VERSION:=$(CY_PROTOCOL)
endif
MTB_CORE__SUPPORTED_PROTOCAL_VERSIONS=1

ifeq ($(MTB_QUERY),)
# undefined MTB_QUERY. Use the latest
MTB_CORE__MTB_QUERY=$(lastword $(MTB_CORE__SUPPORTED_PROTOCAL_VERSIONS))
# MTB_QUERY version is supported
else
ifeq ($(filter $(MTB_QUERY),$(MTB_CORE__SUPPORTED_PROTOCAL_VERSIONS)),$(MTB_QUERY))
MTB_CORE__MTB_QUERY=$(MTB_QUERY)
else
# MTB_QUERY is newer than max supported version. Use the latest
MTB_CORE__MTB_QUERY=$(lastword $(MTB_CORE__SUPPORTED_PROTOCAL_VERSIONS))
$(warning Requested MTB_QUERY version is newer than is supported.)
endif
endif

# CY_PROTOCOl=2, MTB_QUERY=1. Supports ModusToolbox 3.0
get_app_info_2_1:
	@:
	$(info MTB_MPN_LIST=$(MPN_LIST))
	$(info MTB_DEVICE_LIST=$(DEVICE_LIST))
	$(info MTB_DEVICE=$(DEVICE))
	$(info MTB_SEARCH=$(MTB_TOOLS__SEARCH))
	$(info MTB_TOOLCHAIN=$(TOOLCHAIN))
	$(info MTB_TARGET=$(TARGET))
	$(info MTB_CONFIG=$(CONFIG))
	$(info MTB_APP_NAME=$(APPNAME)$(LIBNAME))
	$(info MTB_COMPONENTS=$(MTB_CORE__FULL_COMPONENT_LIST))
	$(info MTB_DISABLED_COMPONENTS=$(DISABLE_COMPONENTS))
	$(info MTB_ADDITIONAL_DEVICES=$(ADDITIONAL_DEVICES))
	$(info MTB_LIBS=$(CY_GETLIBS_PATH))
	$(info MTB_DEPS=$(CY_GETLIBS_DEPS_PATH))
	$(info MTB_WKS_SHARED_NAME=$(CY_GETLIBS_SHARED_NAME))
	$(info MTB_WKS_SHARED_DIR=$(CY_GETLIBS_SHARED_PATH))
	$(info MTB_FLOW_VERSION=$(FLOW_VERSION))
	$(info MTB_QUERY=$(MTB_CORE__MTB_QUERY))
	$(info MTB_TOOLS_DIR=$(MTB_TOOLS__TOOLS_DIR))
	$(info MTB_DEVICE_PROGRAM_IDS=$(strip $(DEVICE_TOOL_IDS) $(CY_SUPPORTED_TOOL_TYPES)))
	$(info MTB_BSP_TOOL_TYPES=$(_MTB_CORE__SUPPORTED_TOOL_ID))
	$(info MTB_MW_TOOL_TYPES=)
	$(info MTB_IGNORE=$(strip $(CY_IGNORE) $(MTB_TOOLS__OUTPUT_BASE_DIR)))
	$(info MTB_TYPE=$(MTB_TYPE))
	$(info MTB_CORE_TYPE=$(MTB_RECIPE__CORE))
	$(info MTB_CORE_NAME=$(MTB_RECIPE__CORE_NAME))
	$(info MTB_BUILD_SUPPORT=$(MTB_BUILD_SUPPORT))
	$(info MTB_CACHE_DIR=$(MTB_TOOLS__CACHE_DIR))
	$(info MTB_OFFLINE_DIR=$(MTB_TOOLS__OFFLINE_DIR))
	$(info MTB_GLOBAL_DIR=$(MTB_TOOLS__GLOBAL_DIR))
	$(info MTB_APP_PATH=$(MTB_TOOLS__REL_PRJ_PATH))

get_app_info: get_app_info_$(MTB_CORE__CY_PROTOCOL_VERSION)_$(MTB_CORE__MTB_QUERY)
	@:

.PHONY: get_app_info get_app_info_2_1

#
# Identify the phony targets
#
.PHONY: bsp update_bsp check get_env_info get_app_info printlibs shared_libs
