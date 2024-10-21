################################################################################
# \file postbuild.mk
#
# \brief
# Performs the compilation and linking steps.
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

#
# post-build step
#
recipe_postbuild: $(_MTB_CORE__BUILD_TARGET)

bsp_postbuild: recipe_postbuild

project_postbuild: bsp_postbuild

#
# Perform the post build print step, basically stating we are done
#
_mtb_build_postprint: project_postbuild
	$(info ==============================================================================)
	$(info = Build complete =)
	$(info ==============================================================================)
	$(info )

#
# Top-level application dependency
#
app: _mtb_build_postprint

ifneq (,$(MTB_RECIPE__SIM_GEN_SUPPORTED))
#
# Simulator tar file generation
#
_MTB_CORE__SIMULATOR_TEMPFILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/simulator.temp
_MTB_CORE__SIMULATOR_SOURCES:=$(MTB_RECIPE__SOURCE) $(SOURCES)
_MTB_CORE__SIMULATOR_SOURCES_C:=$(filter %.$(MTB_RECIPE__SUFFIX_C),$(_MTB_CORE__SIMULATOR_SOURCES))
_MTB_CORE__SIMULATOR_SOURCES_CPP:=$(filter %.$(MTB_RECIPE__SUFFIX_CPP),$(_MTB_CORE__SIMULATOR_SOURCES))
_MTB_CORE__SIMULATOR_SOURCES_CXX:=$(filter %.$(MTB_RECIPE__SUFFIX_CXX),$(_MTB_CORE__SIMULATOR_SOURCES))
_MTB_CORE__SIMULATOR_SOURCES_CC:=$(filter %.$(MTB_RECIPE__SUFFIX_CC),$(_MTB_CORE__SIMULATOR_SOURCES))
_MTB_CORE__SIMULATOR_SOURCES_s:=$(filter %.$(MTB_RECIPE__SUFFIX_s),$(_MTB_CORE__SIMULATOR_SOURCES))
_MTB_CORE__SIMULATOR_SOURCES_S:=$(filter %.$(MTB_RECIPE__SUFFIX_S),$(_MTB_CORE__SIMULATOR_SOURCES))

# All files source to include.
_MTB_CORE__SIMULATOR_ALL_FILES:=$(_MTB_CORE__SIMULATOR_SOURCES_C) $(_MTB_CORE__SIMULATOR_SOURCES_CPP) $(_MTB_CORE__SIMULATOR_SOURCES_CXX) $(_MTB_CORE__SIMULATOR_SOURCES_CC) $(_MTB_CORE__SIMULATOR_SOURCES_s) $(_MTB_CORE__SIMULATOR_SOURCES_S) $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_TARGET) $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_PROGRAM)

# All include path to look for header files.
_MTB_CORE__SIMULATOR_ALL_INCLUDE_PATH:=$(INCLUDES) $(MTB_CORE__SEARCH_APP_INCLUDES) $(MTB_RECIPE__TOOLCHAIN_INCLUDES)

# If set, simulator archive file will be automatically created at the end of the build
# Add support for generating simulator tar file
ifneq (,$(CY_SIMULATOR_GEN_AUTO))
app: $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).tar.tgz
endif
$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).tar.tgz: _mtb_build_postprint
	$(info )
	$(info ==============================================================================)
	$(info = Generating simulator archive file =)
	$(info ==============================================================================)
	$(call mtb__file_write,$(_MTB_CORE__SIMULATOR_TEMPFILE),$(_MTB_CORE__SIMULATOR_ALL_FILES))
	$(call mtb__file_append,$(_MTB_CORE__SIMULATOR_TEMPFILE),$(_MTB_CORE__SIMULATOR_ALL_INCLUDE_PATH))
	$(MTB__NOISE) $(MTB_TOOLS_BASH) $(MTB_TOOLS__CORE_DIR)/make/scripts/simulator_gen/simulator_gen.bash $(MTB_TOOLS__OUTPUT_CONFIG_DIR) $(APPNAME) $(patsubst %/,%,$(MTB_TOOLS__PRJ_DIR)) $(patsubst %/,%,$(CY_GETLIBS_SHARED_PATH)) $(_MTB_CORE__SIMULATOR_TEMPFILE)
	$(MTB__NOISE)rm -f $(_MTB_CORE__SIMULATOR_TEMPFILE)
ifneq (,$(CY_OPEN_online_simulator_FILE_RAW))
	$(info The Infineon online simulator link:)
	$(info $(patsubst "%",%,$(CY_OPEN_online_simulator_FILE_RAW)))
endif
endif

.PHONY:  recipe_postbuild bsp_postbuild project_postbuild _mtb_build_postprint
