################################################################################
# \file search.mk
#
# \brief
# Performs create cyqbuild.mk file by calling mtbsearch
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

_MTB_CORE__CODE_GEN_FLAG:=$(if $(SKIP_CODE_GEN),,--generate)

ifneq ($(MTB_GENERATE_DEPENDENCIES),)
_MTB_CORE__MTBSEARCH_CREATE_DEPENDENCY_FLAG=--create-dependencies
endif

_MTB_CORE__SEARCH_GET_APP_INFO_DATA="@MTB_MPN_LIST=$(MPN_LIST)" "@MTB_DEVICE_LIST=$(DEVICE_LIST)" "@MTB_DEVICE=$(DEVICE)" "@MTB_SEARCH=$(MTB_TOOLS__SEARCH)" "@MTB_TOOLCHAIN=$(TOOLCHAIN)" "@MTB_TARGET=$(TARGET)" "@MTB_CONFIG=$(CONFIG)" "@MTB_APP_NAME=$(APPNAME)$(LIBNAME)" "@MTB_COMPONENTS=$(MTB_CORE__FULL_COMPONENT_LIST)" "@MTB_DISABLED_COMPONENTS=$(DISABLE_COMPONENTS)" "@MTB_ADDITIONAL_DEVICES=$(ADDITIONAL_DEVICES)" "@MTB_LIBS=$(CY_GETLIBS_PATH)" "@MTB_DEPS=$(CY_GETLIBS_DEPS_PATH)" "@MTB_WKS_SHARED_NAME=$(CY_GETLIBS_SHARED_NAME)" "@MTB_WKS_SHARED_DIR=$(CY_GETLIBS_SHARED_PATH)" "@MTB_FLOW_VERSION=$(FLOW_VERSION)" "@MTB_QUERY=$(MTB_CORE__MTB_QUERY)" "@MTB_TOOLS_DIR=$(MTB_TOOLS__TOOLS_DIR)" "@MTB_DEVICE_PROGRAM_IDS=$(strip $(DEVICE_TOOL_IDS) $(CY_SUPPORTED_TOOL_TYPES))" "@MTB_BSP_TOOL_TYPES=$(_MTB_CORE__SUPPORTED_TOOL_ID)" "@MTB_MW_TOOL_TYPES=" "@MTB_IGNORE=$(strip $(CY_IGNORE) $(MTB_TOOLS__OUTPUT_BASE_DIR))" "@MTB_TYPE=$(MTB_TYPE)" "@MTB_CORE_TYPE=$(MTB_RECIPE__CORE)" "@MTB_CORE_NAME=$(MTB_RECIPE__CORE_NAME)" "@MTB_BUILD_SUPPORT=$(MTB_BUILD_SUPPORT)" "@MTB_CACHE_DIR=$(MTB_TOOLS__CACHE_DIR)" "@MTB_OFFLINE_DIR=$(MTB_TOOLS__OFFLINE_DIR)" "@MTB_GLOBAL_DIR=$(MTB_TOOLS__GLOBAL_DIR)" "@MTB_APP_PATH=$(MTB_TOOLS__REL_PRJ_PATH)" "@MTB_BUILD_LOCATION=$(MTB_TOOLS__OUTPUT_BASE_DIR)" "@MTB_SKIP_CODE_GEN=$(SKIP_CODE_GEN)"

# generate the cyqbuild.mk file
$(_MTB_CORE__QBUILD_MK_FILE):
	$(info )
	$(info Auto-discovery in progress...)
	$(MTB__NOISE)mkdir -p $(MTB_TOOLS__OUTPUT_CONFIG_DIR)
	$(MTB__NOISE)$(CY_TOOL_mtbsearch_EXE_ABS) $(_MTB_CORE__MTBSEARCH_CREATE_DEPENDENCY_FLAG) --project $(MTB_TOOLS__PRJ_DIR) $(_MTB_CORE__SEARCH_GET_APP_INFO_DATA) $(_MTB_CORE__CODE_GEN_FLAG) $(_MTB_CORE__ASSET_ARCHIVES) -o $@.tmp
	$(MTB__NOISE)if ! cmp -s "$@" "$@.tmp"; then \
		mv -f "$@.tmp" "$@" ; \
	else \
		rm -f "$@.tmp"; \
	fi
	$(MTB__NOISE)echo Auto-discovery complete
