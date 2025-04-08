################################################################################
# \file ninja.mk
#
# \brief
# Defines the public facing build targets common to all recipes and includes
# the core makefiles.
#
################################################################################
# \copyright
# (c) 2024-2025, Cypress Semiconductor Corporation (an Infineon company) or
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
# generate compile_commands.json is a side effect of generating ninja file.
_mtb_build_cdb_postprint: $(_MTB_CORE__NINJA_FILE)

##########################################################################
# If make verbose is set, forward to ninja.
ifneq ($(VERBOSE),)
NINJAFLAGS:=$(NINJAFLAGS) -v
endif

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

# get_app_info data
_MTB_CORE__SEARCH_GET_APP_INFO_DATA="@MTB_MPN_LIST=$(MPN_LIST)" "@MTB_DEVICE_LIST=$(DEVICE_LIST)" "@MTB_DEVICE=$(DEVICE)" "@MTB_SEARCH=$(MTB_TOOLS__SEARCH)" "@MTB_TOOLCHAIN=$(TOOLCHAIN)" "@MTB_TARGET=$(TARGET)" "@MTB_CONFIG=$(CONFIG)" "@MTB_APP_NAME=$(APPNAME)$(LIBNAME)" "@MTB_COMPONENTS=$(MTB_CORE__FULL_COMPONENT_LIST)" "@MTB_DISABLED_COMPONENTS=$(DISABLE_COMPONENTS)" "@MTB_ADDITIONAL_DEVICES=$(ADDITIONAL_DEVICES)" "@MTB_LIBS=$(CY_GETLIBS_PATH)" "@MTB_DEPS=$(CY_GETLIBS_DEPS_PATH)" "@MTB_WKS_SHARED_NAME=$(CY_GETLIBS_SHARED_NAME)" "@MTB_WKS_SHARED_DIR=$(CY_GETLIBS_SHARED_PATH)" "@MTB_FLOW_VERSION=$(FLOW_VERSION)" "@MTB_QUERY=$(MTB_CORE__MTB_QUERY)" "@MTB_TOOLS_DIR=$(MTB_TOOLS__TOOLS_DIR)" "@MTB_DEVICE_PROGRAM_IDS=$(strip $(DEVICE_TOOL_IDS) $(CY_SUPPORTED_TOOL_TYPES))" "@MTB_BSP_TOOL_TYPES=$(_MTB_CORE__SUPPORTED_TOOL_ID)" "@MTB_MW_TOOL_TYPES=" "@MTB_IGNORE=$(strip $(CY_IGNORE) $(MTB_TOOLS__OUTPUT_BASE_DIR))" "@MTB_TYPE=$(MTB_TYPE)" "@MTB_CORE_TYPE=$(MTB_RECIPE__CORE)" "@MTB_CORE_NAME=$(MTB_RECIPE__CORE_NAME)" "@MTB_BUILD_SUPPORT=$(MTB_BUILD_SUPPORT)" "@MTB_CACHE_DIR=$(MTB_TOOLS__CACHE_DIR)" "@MTB_OFFLINE_DIR=$(MTB_TOOLS__OFFLINE_DIR)" "@MTB_GLOBAL_DIR=$(MTB_TOOLS__GLOBAL_DIR)" "@MTB_APP_PATH=$(MTB_TOOLS__REL_PRJ_PATH)" "@MTB_BUILD_LOCATION=$(MTB_TOOLS__OUTPUT_BASE_DIR)" "@MTB_SKIP_CODE_GEN=$(SKIP_CODE_GEN)"

##########################################################################
# paths to various things we need to communicate to mtbninja.

_MTB_CORE__CC_PATH=$(CC)
_MTB_CORE__CXX_PATH=$(CXX)
_MTB_CORE__LD_PATH=$(LD)
_MTB_CORE__AR_PATH=$(AR)
_MTB_CORE__AS_PATH=$(AS)
_MTB_CORE__AS_LC_PATH=$(AS_LC)
_MTB_CORE__AS_UC_PATH=$(AS_UC)
_MTB_CORE__OBJCOPY_PATH=$(MTB_TOOLCHAIN_GCC_ARM__OBJCOPY)

ifeq ($(_MTB_RECIPE__TARG_FILE),)
_MTB_RECIPE__TARG_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_TARGET)
endif

_MTB_CORE__ELF_FILE=$(_MTB_RECIPE__TARG_FILE)
_MTB_CORE__HEX_FILE=$(_MTB_CORE__ELF_FILE:.$(MTB_RECIPE__SUFFIX_TARGET)=.hex)
_MTB_CORE__MAP_FILE=$(_MTB_CORE__ELF_FILE:.$(MTB_RECIPE__SUFFIX_TARGET)=.$(MTB_RECIPE__SUFFIX_MAP))

_MTB_CORE__DEFINES_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.defines
_MTB_CORE__ASFLAGS_UC_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.asflags
_MTB_CORE__ASFLAGS_LC_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.asflags_s

ifeq ($(TOOLCHAIN),ARM)
_MTB_CORE__ASFLAGS_FILE=$(_MTB_CORE__ASFLAGS_LC_FILE)
else
_MTB_CORE__ASFLAGS_FILE=$(_MTB_CORE__ASFLAGS_UC_FILE)
endif

_MTB_CORE__CFLAGS_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cflags
_MTB_CORE__CXXFLAGS_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cxxflags
_MTB_CORE__ARFLAGS_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.arflags
_MTB_CORE__LDFLAGS_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.ldflags

_MTB_CORE__SOURCES_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.sources
_MTB_CORE__INCLUDES_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.includes
_MTB_CORE__LDLIBS_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.ldlibs

_MTB_CORE__TMP_LDFLAGS=$(MTB_RECIPE__LDFLAGS) $(MTB_RECIPE__MAPFILE)@mapfile $(MTB_RECIPE__STARTGROUP) @objs $(MTB_RECIPE__ENDGROUP) $(MTB_RECIPE__OUTPUT_OPTION) @elffile

_MTB_CORE__FINAL_DEFINES=$(MTB_RECIPE__DEFINES)
ifneq ($(MTB_RECIPE__ASFLAGS_UC),)
_MTB_CORE__FINAL_ASFLAGS_UC=$(filter-out $(filter-out $(ASFLAGS),$(DISABLE_ASFLAGS)),$(MTB_RECIPE__ASFLAGS_UC) $(_MTB_CORE__DEPS_AS))
else
_MTB_CORE__FINAL_ASFLAGS_UC=$(filter-out $(filter-out $(ASFLAGS),$(DISABLE_ASFLAGS)),$(MTB_RECIPE__ASFLAGS) $(_MTB_CORE__DEPS_AS))
endif
ifneq ($(MTB_RECIPE__ASFLAGS_LC),)
_MTB_CORE__FINAL_ASFLAGS_LC=$(filter-out $(filter-out $(ASFLAGS),$(DISABLE_ASFLAGS)),$(MTB_RECIPE__ASFLAGS_LC))
else
_MTB_CORE__FINAL_ASFLAGS_LC=$(filter-out $(filter-out $(ASFLAGS),$(DISABLE_ASFLAGS)),$(MTB_RECIPE__ASFLAGS))
endif
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
$(call mtb__file_write,$(_MTB_CORE__DEFINES_FILE),$(_MTB_CORE__FINAL_DEFINES))
$(call mtb__file_write,$(_MTB_CORE__ASFLAGS_UC_FILE),$(_MTB_CORE__FINAL_ASFLAGS_UC))
$(call mtb__file_write,$(_MTB_CORE__ASFLAGS_LC_FILE),$(_MTB_CORE__FINAL_ASFLAGS_LC))
$(call mtb__file_write,$(_MTB_CORE__CFLAGS_FILE),$(_MTB_CORE__FINAL_CFLAGS))
$(call mtb__file_write,$(_MTB_CORE__CXXFLAGS_FILE),$(_MTB_CORE__FINAL_CXXFLAGS))
$(call mtb__file_write,$(_MTB_CORE__ARFLAGS_FILE),$(_MTB_CORE__FINAL_ARFLAGS))
$(call mtb__file_write,$(_MTB_CORE__LDFLAGS_FILE),$(_MTB_CORE__FINAL_LDFLAGS))

$(call mtb__file_write,$(_MTB_CORE__SOURCES_FILE),$(_MTB_CORE__FILTERED_USER_SOURCES))
$(call mtb__file_write,$(_MTB_CORE__INCLUDES_FILE),$(INCLUDES))
$(call mtb__file_write,$(_MTB_CORE__LDLIBS_FILE),$(LDLIBS) $(CY_RECIPE_EXTRA_LIBS))

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

_MTB_CORE__NINJA_EXTRA:=

##########################################################################
# Only include the new options when the recipe has a separate LC assembler
# defined and when we are supporting the ninja interface greater than 1
# which has support for multiple assemblers.
ifneq ($(strip $(filter-out 0 1,$(_MTB_CORE__NINJA_VERSIONS_SUPPORTED))),)
_MTB_CORE__NINJA_EXTRA+=--ld-ext   $(MTB_RECIPE__SUFFIX_LS)
_MTB_CORE__NINJA_EXTRA+=--aspath_s $(_MTB_CORE__AS_LC_PATH) --asflags_s $(_MTB_CORE__ASFLAGS_LC_FILE)
_MTB_CORE__NINJA_EXTRA+=--aspath   $(_MTB_CORE__AS_UC_PATH) --asflags   $(_MTB_CORE__ASFLAGS_UC_FILE)
_MTB_CORE__NINJA_EXTRA+= --out-mk $(_MTB_CORE__QBUILD_MK_FILE)

ifeq ($(MAKE_RESTARTS),)
$(_MTB_CORE__QBUILD_MK_FILE): $(_MTB_CORE__NINJA_FILE)
	@:
endif

else
_MTB_CORE__NINJA_EXTRA+=--aspath   $(_MTB_CORE__AS_PATH)    --asflags   $(_MTB_CORE__ASFLAGS_FILE)
endif

# Check GCC toolchain is installed.
# Regardless of selected toolchain. Most toolchain use GCC tools for:
# - hex file generation (objcopy)
# - memcalc (readelf)
# - debugging (gdb)
check_gcc_install:
		$(if $(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR),,$(error GCC Package was not found, \
					run the ModusToolbox SetupTool and install the GCC package to continue. \
					More information can be found in the user guide at https://www.infineon.com/ModusToolboxInstallguide))

##########################################################################
# Where the ninja build "magic" happens
$(_MTB_RECIPE__TARG_FILE): $(_MTB_CORE__NINJA_FILE) FORCE check_gcc_install
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
		--objcopypath $(_MTB_CORE__OBJCOPY_PATH) \
		--elffile  $(_MTB_CORE__ELF_FILE) \
		--mapfile  $(_MTB_CORE__MAP_FILE) \
		--defines  $(_MTB_CORE__DEFINES_FILE) \
		--cflags   $(_MTB_CORE__CFLAGS_FILE) \
		--cppflags $(_MTB_CORE__CXXFLAGS_FILE) \
		--arflags  $(_MTB_CORE__ARFLAGS_FILE) \
		--ldflags  $(_MTB_CORE__LDFLAGS_FILE) \
		--sources  $(_MTB_CORE__SOURCES_FILE) \
		--includes $(_MTB_CORE__INCLUDES_FILE) \
		--ldlibs   $(_MTB_CORE__LDLIBS_FILE) \
		--build-dir $(MTB_TOOLS__OUTPUT_BASE_DIR) \
		$(_MTB_CORE__NINJA_EXTRA) \
		$(_MTB_CORE__SEARCH_GET_APP_INFO_DATA)

.PHONY: app _mtb_build_cdb_postprint check_gcc_install
