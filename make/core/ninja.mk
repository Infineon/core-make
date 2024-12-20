################################################################################
# \file ninja.mk
#
# \brief
# Defines the public facing build targets common to all recipes and includes
# the core makefiles.
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

##########################################################################
# bit of error checking.

# 1. If we can't find ninja bundled in the ModusToolbox "tools" package, try PATH
ifeq ($(CY_TOOL_ninja_EXE_ABS),)
CY_TOOL_ninja_EXE_ABS:=$(shell type -P ninja)
endif

ifeq ($(CY_TOOL_ninja_EXE_ABS),)
$(error Unable to find 'ninja' in the ModusToolbox tools or in PATH)
else
$(info  NOTE: Using '$(CY_TOOL_ninja_EXE_ABS)' from PATH.)
endif

# 2. If we can't find mtbninja as a dedicated tool, try looking next to mtbsearch.
ifeq ($(CY_TOOL_mtbninja_EXE_ABS),)
CY_TOOL_mtbninja_EXE_ABS:=$(wildcard $(CY_TOOLS_DIR)/mtbsearch/mtbninja)
endif

ifeq ($(CY_TOOL_mtbninja_EXE_ABS),)
$(error Unable to find 'mtbninja' in the ModusToolbox tools)
endif


##########################################################################
# display memory usage
build_proj: app memcalc
qbuild_proj: app memcalc
memcalc: app

##########################################################################
# If make verbose is set, forward to ninja.
ifneq ($(VERBOSE),)
NINJAFLAGS:=$(NINJAFLAGS) -v
endif

# Ninja flow does autodiscovery internally. These are not required.
MTB_CORE__SEARCH_APP_INCLUDES:=
MTB_CORE__SEARCH_APP_SOURCE:=
MTB_CORE__SEARCH_APP_LIBS:=

# temporary work-around for recipes (they are not yet ninja-aware).

# if recipes provide their ninja-dependency generation args, use them.
_MTB_CORE__DEPS_CC=$(MTB_RECIPE__NINJA_DEPS_CC)
_MTB_CORE__DEPS_AS=$(MTB_RECIPE__NINJA_DEPS_AS)

# else fallback on sensible defaults
ifeq ($(_MTB_CORE__DEPS_CC),)

ifeq ($(TOOLCHAIN),IAR)
_MTB_CORE__DEPS_CC=--dependencies=m $$out.d
_MTB_CORE__DEPS_AS=
else ifeq ($(TOOLCHAIN),ARM)
_MTB_CORE__DEPS_CC=-MMD -MP -MF $$out.d -MT $$out
_MTB_CORE__DEPS_AS=
else
_MTB_CORE__DEPS_CC=-MMD -MP -MF $$out.d -MT $$out
_MTB_CORE__DEPS_AS=$(_MTB_CORE__DEPS_CC)
endif

endif # ifeq ($(_MTB_CORE__DEPS_CC)),)


##########################################################################
# paths to various things we need to communicate to mtbninja.

_MTB_CORE__CC_PATH=$(CC)
_MTB_CORE__CXX_PATH=$(CXX)
_MTB_CORE__LD_PATH=$(LD)
_MTB_CORE__AR_PATH=$(AR)
_MTB_CORE__AS_PATH=$(AS)
_MTB_CORE__OBJCOPY_PATH=$(MTB_TOOLCHAIN_GCC_ARM__OBJCOPY)

ifeq ($(_MTB_RECIPE__TARG_FILE),)
_MTB_RECIPE__TARG_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_TARGET)
endif

_MTB_CORE__ELF_FILE=$(_MTB_RECIPE__TARG_FILE)
_MTB_CORE__HEX_FILE=$(_MTB_CORE__ELF_FILE:.$(MTB_RECIPE__SUFFIX_TARGET)=.hex)
_MTB_CORE__MAP_FILE=$(_MTB_CORE__ELF_FILE:.$(MTB_RECIPE__SUFFIX_TARGET)=.$(MTB_RECIPE__SUFFIX_MAP))

_MTB_CORE__DEFINES_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.defines
_MTB_CORE__ASFLAGS_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.asflags
_MTB_CORE__CFLAGS_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cflags
_MTB_CORE__CXXFLAGS_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cxxflags
_MTB_CORE__ARFLAGS_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.arflags
_MTB_CORE__LDFLAGS_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.ldflags

_MTB_CORE__SOURCES_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.sources
_MTB_CORE__INCLUDES_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.includes
_MTB_CORE__LDLIBS_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.ldlibs

_MTB_CORE__TMP_LDFLAGS=$(MTB_RECIPE__LDFLAGS) $(MTB_RECIPE__MAPFILE)@mapfile $(MTB_RECIPE__STARTGROUP) @objs $(MTB_RECIPE__ENDGROUP) $(MTB_RECIPE__OUTPUT_OPTION) @elffile

_MTB_CORE__FINAL_DEFINES=$(MTB_RECIPE__DEFINES)
_MTB_CORE__FINAL_ASFLAGS=$(filter-out $(filter-out $(ASFLAGS),$(DISABLE_ASFLAGS)),$(MTB_RECIPE__ASFLAGS) $(_MTB_CORE__DEPS_AS))
_MTB_CORE__FINAL_CFLAGS=$(filter-out $(filter-out $(CFLAGS),$(DISABLE_CFLAGS)),$(MTB_RECIPE__CFLAGS) $(_MTB_CORE__DEPS_CC))
_MTB_CORE__FINAL_CXXFLAGS=$(filter-out $(filter-out $(CXXFLAGS),$(DISABLE_CXXFLAGS)),$(MTB_RECIPE__CXXFLAGS) $(_MTB_CORE__DEPS_CC))
_MTB_CORE__FINAL_ARFLAGS=$(filter-out $(filter-out $(ARFLAGS),$(DISABLE_ARFLAGS)),$(MTB_RECIPE__ARFLAGS))
_MTB_CORE__FINAL_LDFLAGS=$(filter-out $(filter-out $(LDFLAGS),$(DISABLE_LDFLAGS)),$(_MTB_CORE__TMP_LDFLAGS))

_MTB_CORE__FILTERED_USER_SOURCES=$(SOURCES)


##########################################################################
# write various flags to their required files.

# NOTE: this is such a small fraction of a second we just (re)write them every build.
$(info Generating mtbninja data files...)
$(shell mkdir -p $(dir $(_MTB_CORE__DEFINES_FILE)))
$(call mtb__file_write,$(_MTB_CORE__DEFINES_FILE),$(foreach  x,$(_MTB_CORE__FINAL_DEFINES),$(x)$(MTB__NEWLINE)))
$(call mtb__file_write,$(_MTB_CORE__ASFLAGS_FILE),$(foreach  x,$(_MTB_CORE__FINAL_ASFLAGS),$(x)$(MTB__NEWLINE)))
$(call mtb__file_write,$(_MTB_CORE__CFLAGS_FILE),$(foreach   x,$(_MTB_CORE__FINAL_CFLAGS),$(x)$(MTB__NEWLINE)))
$(call mtb__file_write,$(_MTB_CORE__CXXFLAGS_FILE),$(foreach x,$(_MTB_CORE__FINAL_CXXFLAGS),$(x)$(MTB__NEWLINE)))
$(call mtb__file_write,$(_MTB_CORE__ARFLAGS_FILE),$(foreach  x,$(_MTB_CORE__FINAL_ARFLAGS),$(x)$(MTB__NEWLINE)))
$(call mtb__file_write,$(_MTB_CORE__LDFLAGS_FILE),$(foreach  x,$(_MTB_CORE__FINAL_LDFLAGS),$(x)$(MTB__NEWLINE)))

$(call mtb__file_write,$(_MTB_CORE__SOURCES_FILE),$(foreach  x,$(_MTB_CORE__FILTERED_USER_SOURCES),$(x)$(MTB__NEWLINE)))
$(call mtb__file_write,$(_MTB_CORE__INCLUDES_FILE),$(foreach  x,$(INCLUDES),$(x)$(MTB__NEWLINE)))
$(call mtb__file_write,$(_MTB_CORE__LDLIBS_FILE),$(foreach  x,$(LDLIBS) $(CY_RECIPE_EXTRA_LIBS),$(x)$(MTB__NEWLINE)))

$(info Generating mtbninja data complete...)


##########################################################################
# Handle any make argumens that influence "get_app_info" / make sure we
# pass them along to mtbninja via it's command-line.

# from core_utils.mk (copied here for experimental phase, needs to be unified later.
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

##########################################################################
# Where the ninja build "magic" happens
$(_MTB_RECIPE__TARG_FILE): $(_MTB_CORE__NINJA_FILE)
	$(MTB__NOISE)$(CY_TOOL_ninja_EXE_ABS) -f $(_MTB_CORE__NINJA_FILE) -d keeprsp $(NINJAFLAGS)

$(_MTB_CORE__NINJA_FILE):
	$(MTB__NOISE)$(CY_TOOL_mtbninja_EXE_ABS) \
		--project $(MTB_TOOLS__PRJ_DIR) \
		--generate \
		$(_MTB_CORE__ASSET_ARCHIVES) \
		--ninja    $(_MTB_CORE__NINJA_FILE) \
		--ccpath   $(_MTB_CORE__CC_PATH) \
		--cpppath  $(_MTB_CORE__CXX_PATH) \
		--ldpath   $(_MTB_CORE__LD_PATH) \
		--arpath   $(_MTB_CORE__AR_PATH) \
		--aspath   $(_MTB_CORE__AS_PATH) \
		--objcopypath $(_MTB_CORE__OBJCOPY_PATH) \
		--elffile  $(_MTB_CORE__ELF_FILE) \
		--mapfile  $(_MTB_CORE__MAP_FILE) \
		--defines  $(_MTB_CORE__DEFINES_FILE) \
		--asflags  $(_MTB_CORE__ASFLAGS_FILE) \
		--cflags   $(_MTB_CORE__CFLAGS_FILE) \
		--cppflags $(_MTB_CORE__CXXFLAGS_FILE) \
		--arflags  $(_MTB_CORE__ARFLAGS_FILE) \
		--ldflags  $(_MTB_CORE__LDFLAGS_FILE) \
		--sources  $(_MTB_CORE__SOURCES_FILE) \
		--includes $(_MTB_CORE__INCLUDES_FILE) \
		--ldlibs   $(_MTB_CORE__LDLIBS_FILE) \
		--build-dir $(MTB_TOOLS__OUTPUT_BASE_DIR) \
		$(_MTB_CORE__SEARCH_GET_APP_INFO_DATA)

.PHONY: app
