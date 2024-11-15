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

$(info )
$(info =======================================)
$(info NOTE: Ninja support is _EXPERIMENTAL_.)
$(info =======================================)
$(info )

# order of build operations handled by make:
#
# 1.  prebuild
#     - recipe
#     - bsp
#     - user
#
# 2. build
#     - ninja gen
#     - ninja
#
# 3. postbuild
#     - recipe
#     - bsp
#     - user
#
# 4. application-postbuild (if applicable, handled by the recipe)
#     - sign-combine


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
# If make verbose is set, forward to ninja.
ifneq ($(VERBOSE),)
NINJAFLAGS:=$(NINJAFLAGS) -v
endif


##########################################################################
# recipe statically defined info (not dependent on core-make).

# from legacy make flow -- main.mk
include $(MTB_TOOLS__CORE_DIR)/make/core/core_utils.mk

-include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/recipe_version.mk
-include $(MTB_TOOLS__RECIPE_DIR)/make/udd/features.mk
include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/core_selection.mk

# The GCC_ARM readelf is used by all toolchain build for memory calculation. So always include GCC_ARM toolchain.
-include $(MTB_TOOLS__RECIPE_DIR)/make/toolchains/GCC_ARM.mk
ifneq ($(TOOLCHAIN),GCC_ARM)
include $(MTB_TOOLS__RECIPE_DIR)/make/toolchains/$(TOOLCHAIN).mk
endif

include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/recipe_toolchain_file_types.mk
include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/defines.mk
include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/recipe_setup.mk

-include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/program.mk


##########################################################################
# pull in any library.mk files from middleware.
_MTB_CORE__LIB_MK=$(wildcard $(foreach dir,$(SEARCH_MTB_MK),$(dir)/library.mk))
-include $(_MTB_CORE__LIB_MK)


# Ninja flow does autodiscovery internally. These are not required.
MTB_CORE__SEARCH_APP_INCLUDES:=
MTB_CORE__SEARCH_APP_SOURCE:=
MTB_CORE__SEARCH_APP_LIBS:=


##########################################################################
# include the remainder of the recipe.
include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/recipe.mk

# temporary work-around for recipe. copy elf and hex file to last_config
MTB_RECIPE__LAST_CONFIG_DIR:=$(MTB_TOOLS__OUTPUT_BASE_DIR)/last_config
$(MTB_RECIPE__LAST_CONFIG_DIR):|
	$(MTB__NOISE)mkdir -p $(MTB_RECIPE__LAST_CONFIG_DIR)

_MTB_RECIPE__LAST_CONFIG_PROG_FILE:=$(MTB_RECIPE__LAST_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_PROGRAM)
_MTB_RECIPE__LAST_CONFIG_TARG_FILE:=$(MTB_RECIPE__LAST_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_TARGET)
_MTB_RECIPE__LAST_CONFIG_PROG_FILE_D:=$(_MTB_RECIPE__LAST_CONFIG_PROG_FILE).d

build_proj qbuild_proj: $(_MTB_RECIPE__LAST_CONFIG_PROG_FILE)

$(_MTB_RECIPE__LAST_CONFIG_PROG_FILE_D): | $(MTB_RECIPE__LAST_CONFIG_DIR)
	$(MTB__NOISE)echo $(_MTB_RECIPE__PROG_FILE_USER) > $@.tmp
	$(MTB__NOISE)if ! cmp -s "$@" "$@.tmp"; then \
		mv -f "$@.tmp" "$@" ; \
	else \
		rm -f "$@.tmp"; \
	fi

$(_MTB_RECIPE__LAST_CONFIG_PROG_FILE): $(_MTB_RECIPE__PROG_FILE) $(_MTB_RECIPE__LAST_CONFIG_PROG_FILE_D) | project_postbuild
	$(MTB__NOISE)cp -rf $(_MTB_RECIPE__PROG_FILE_USER) $@
	$(MTB__NOISE)cp -rf $(_MTB_RECIPE__TARG_FILE) $(_MTB_RECIPE__LAST_CONFIG_TARG_FILE)

# temporary workaround. ninja does not have auto-discovry info. Use a wildcard function to locate QSPI flash loader path.
# get the path of design.cyqspi file
mtb_core__rwildcard=$(strip $(foreach d,$(wildcard $1*),$(call mtb_core__rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d)))
_MTB_RECIPE__QSPI_CONFIG_FILE:=$(call mtb_core__rwildcard,$(SEARCH_TARGET_$(TARGET)),*.cyqspi)
ifneq ($(words $(_MTB_RECIPE__QSPI_CONFIG_FILE)),1)
ifneq ($(words $(_MTB_RECIPE__QSPI_CONFIG_FILE)),0)
$(warning Multiple .cyqspi files found: $(_MTB_RECIPE__QSPI_CONFIG_FILE) -- using the first.)
 _MTB_RECIPE__QSPI_CONFIG_FILE:=$(word 1,$(_MTB_RECIPE__QSPI_CONFIG_FILE))
endif
endif

_MTB_RECIPE__PROJECT_DIR_NAME=$(notdir $(realpath $(MTB_TOOLS__PRJ_DIR)))

ifeq ($(_MTB_RECIPE__QSPI_CONFIG_FILE),)
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH=
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_WITH_FLAG=
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_APPLICATION_WITH_FLAG=
else
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH=$(call mtb__get_dir,$(_MTB_RECIPE__QSPI_CONFIG_FILE))/GeneratedSource
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_WITH_FLAG=-s &quot;$(_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH)&quot;&\#13;&\#10;
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_APPLICATION_WITH_FLAG=-s &quot;$(patsubst $(call mtb_path_normalize,$(MTB_TOOLS__PRJ_DIR)/..)/%,%,$(call mtb_path_normalize,$(_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH)))&quot;&\#13;&\#10;
endif
_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH_APPLICATION=$(patsubst $(call mtb_path_normalize,$(MTB_TOOLS__PRJ_DIR)/..)/%,%,$(call mtb_path_normalize,$(_MTB_RECIPE__OPENOCD_QSPI_CFG_PATH)))


##########################################################################
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

_MTB_CORE__NINJA_FILE=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).ninja
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


_MTB_CORE__GET_APP_INFO_DATA=\
    "@MTB_MPN_LIST=$(MPN_LIST)" \
    "@MTB_DEVICE_LIST=$(DEVICE_LIST)" \
    "@MTB_DEVICE=$(DEVICE)" \
    "@MTB_SEARCH=$(MTB_TOOLS__SEARCH)" \
    "@MTB_TOOLCHAIN=$(TOOLCHAIN)" \
    "@MTB_TARGET=$(TARGET)" \
    "@MTB_CONFIG=$(CONFIG)" \
    "@MTB_APP_NAME=$(APPNAME)$(LIBNAME)" \
    "@MTB_COMPONENTS=$(MTB_CORE__FULL_COMPONENT_LIST)" \
    "@MTB_DISABLED_COMPONENTS=$(DISABLE_COMPONENTS)" \
    "@MTB_ADDITIONAL_DEVICES=$(ADDITIONAL_DEVICES)" \
    "@MTB_LIBS=$(CY_GETLIBS_PATH)" \
    "@MTB_DEPS=$(CY_GETLIBS_DEPS_PATH)" \
    "@MTB_WKS_SHARED_NAME=$(CY_GETLIBS_SHARED_NAME)" \
    "@MTB_WKS_SHARED_DIR=$(CY_GETLIBS_SHARED_PATH)" \
    "@MTB_FLOW_VERSION=$(FLOW_VERSION)" \
    "@MTB_QUERY=$(MTB_CORE__MTB_QUERY)" \
    "@MTB_TOOLS_DIR=$(MTB_TOOLS__TOOLS_DIR)" \
    "@MTB_DEVICE_PROGRAM_IDS=$(strip $(DEVICE_TOOL_IDS) $(CY_SUPPORTED_TOOL_TYPES))" \
    "@MTB_BSP_TOOL_TYPES=$(_MTB_CORE__SUPPORTED_TOOL_ID)" \
    "@MTB_MW_TOOL_TYPES=" \
    "@MTB_IGNORE=$(strip $(CY_IGNORE) $(MTB_TOOLS__OUTPUT_BASE_DIR))" \
    "@MTB_TYPE=$(MTB_TYPE)" \
    "@MTB_CORE_TYPE=$(MTB_RECIPE__CORE)" \
    "@MTB_CORE_NAME=$(MTB_RECIPE__CORE_NAME)" \
    "@MTB_BUILD_SUPPORT=$(MTB_BUILD_SUPPORT)" \
    "@MTB_CACHE_DIR=$(MTB_TOOLS__CACHE_DIR)" \
    "@MTB_OFFLINE_DIR=$(MTB_TOOLS__OFFLINE_DIR)" \
    "@MTB_GLOBAL_DIR=$(MTB_TOOLS__GLOBAL_DIR)" \
    "@MTB_APP_PATH=$(MTB_TOOLS__REL_PRJ_PATH)"


##########################################################################
# order all prebuilds
prebuild: mtb_prebuild

# NOTE: additonal user prebuild related targets can use mtb_prebuild to
#       ensure ours run and finish before theirs are started.
mtb_prebuild: project_prebuild
	$(MTB__NOISE)echo "ModusToolbox pre-build complete."

project_prebuild: bsp_prebuild

ifneq ($(PREBUILD),)
project_prebuild: _mtb_build__legacy_project_prebuild
_mtb_build__legacy_project_prebuild: bsp_prebuild
	$(PREBUILD)
endif


bsp_prebuild: recipe_prebuild

# BWC
ifneq ($(CY_BSP_PREBUILD),)
bsp_prebuild: _mtb_build__legacy_bsp_prebuild
_mtb_build__legacy_bsp_prebuild: _mtb_core__prebuild_mkdirs recipe_prebuild
	$(CY_BSP_PREBUILD)
endif

recipe_prebuild:

_mtb_core__prebuild_mkdirs:
	$(MTB__NOISE)mkdir -p $(MTB_TOOLS__OUTPUT_CONFIG_DIR)


.PHONY: prebuild mtb_prebuild bsp_prebuild recipe_prebuild


##########################################################################
# order all postbuilds
postbuild: mtb_postbuild

# NOTE: additonal user postbuild related targets can use mtb_postbuild to
#       ensure ours run and finish before theirs are started.
mtb_postbuild: bsp_postbuild
	$(info ModusToolbox post-build complete.)

bsp_postbuild: recipe_postbuild

recipe_postbuild: project_postbuild

$(_MTB_CORE__ELF_FILE): _mtb_core__build_proj
$(_MTB_CORE__HEX_FILE): $(_MTB_CORE__ELF_FILE)

# if project has a legacy post-build then run it.
project_postbuild: _mtb_core__build_proj
ifneq ($(POSTBUILD),)
	$(POSTBUILD)
endif

ifneq ($(CY_BSP_POSTBUILD),)
bsp_postbuild: _mtb_build__legacy_bsp_postbuild
_mtb_build__legacy_bsp_postbuild: recipe_postbuild
	$(CY_BSP_POSTBUILD)
endif

ifneq ($(POSTBUILD),)
project_postbuild: _mtb_build__legacy_project_postbuild
_mtb_build__legacy_project_postbuild: bsp_postbuild
	$(POSTBUILD)
endif


.PHONY: postbuild mtb_postbuild bsp_postbuild recipe_postbuild project_postbuild

##########################################################################
# additional post-builds for multi-core apps.
ifeq ($(MTB_TYPE),PROJECT)
_MTB_CORE__PROMOTE=true
endif

ifeq ($(MTB_TYPE),COMBINED)
ifneq ($(COMBINE_SIGN_JSON),)
_MTB_CORE__PROMOTE=true
endif
endif


ifneq ($(_MTB_CORE__PROMOTE),)

# promotion & signing related targets (not used unless this is a multicore app).
_MTB_CORE__PROMOTED_HEX:=$(MTB_TOOLS__PRJ_DIR)/$(_MTB_RECIPE__PRJ_HEX_DIR)/$(notdir $(MTB_TOOLS__PRJ_DIR)).hex
_MTB_CORE__PROMOTED_DIR:=$(dir $(_MTB_CORE__PROMOTED_HEX))

$(_MTB_CORE__PROMOTED_DIR):
	$(MTB__NOISE)mkdir -p $@

$(_MTB_CORE__PROMOTED_HEX): $(_MTB_CORE__HEX_FILE) | $(_MTB_CORE__PROMOTED_DIR)
	$(MTB__NOISE)cp -rf "$<" "$@"
	$(call mtb__file_write,$(_MTB_CORE__PROMOTED_HEX).d,$(_MTB_CORE__PROMOTED_HEX))

# when building the project, we need to promote it.
project_postbuild: $(_MTB_CORE__PROMOTED_HEX)

# if we're part of a multi-core app, handle promotion for sign/combine
application_postbuild: sign_combine

endif # ifneq ($(_MTB_CORE__PROMOTE),)


##########################################################################
# build / build_proj + app vs. prj
ifeq ($(MTB_TYPE),PROJECT)

# we're 1 project in an app that likely has more projects.
build qbuild:
	$(MTB__NOISE)make -C .. $@
else # ($(MTB_TYPE),PROJECT)
# we're a unified app+prj
build: build_proj
qbuild: qbuild_proj
endif # ($(MTB_TYPE),PROJECT)

build_proj qbuild_proj: postbuild

ifneq ($(filter all build build_proj,$(MAKECMDGOALS)),)
# only run mtbninja if not doing a qbuild / qbuild_proj
_MTB_CORE__NINJA_RUN_DEP=_mtb_core__ninja_gen
_MTB_CORE__NINJA_GEN_DEP=prebuild
endif


##########################################################################
# Are we enabling asset static archives.

ifneq ($(ASSET_ARCHIVES),)
_MTB_CORE__ASSET_ARCHIVES=--archive-assets
else
_MTB_CORE__ASSET_ARCHIVES=
endif


##########################################################################
# Where the ninja build "magic" happens

$(_MTB_RECIPE__TARG_FILE): | _mtb_core__ninja_run

_mtb_core__build_proj: _mtb_core__ninja_run

_mtb_core__ninja_run: $(_MTB_CORE__NINJA_RUN_DEP)
	$(MTB__NOISE)$(CY_TOOL_ninja_EXE_ABS) -f $(_MTB_CORE__NINJA_FILE) $(NINJAFLAGS)

_mtb_core__ninja_gen: $(_MTB_CORE__NINJA_GEN_DEP)
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
		$(_MTB_CORE__GET_APP_INFO_DATA)

.PHONY: _mtb_core__build_proj _mtb_core__ninja_gen _mtb_core__ninja_run

