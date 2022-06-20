################################################################################
# \file search.mk
#
# \brief
# Performs create cyqbuild.mk file by calling mtbsearch
#
################################################################################
# \copyright
# Copyright 2018-2021 Cypress Semiconductor Corporation
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

_CY_QBUILD_MK_FILE=$(CY_CONFIG_DIR)/cyqbuild.mk

# arguments for mtbsearch
_MTB_SEARCH_CMD=$(CY_TOOL_mtbsearch_EXE) . -o $(_CY_QBUILD_MK_FILE) @MTB_TOOLS_DIR=$(CY_TOOLS_DIR)

# if running a make then remove the cyqbuild.mk file during the first stage, the second stage will be forced to regenerate the cyqbuild.mk file.
ifeq ($(CY_SECONDSTAGE),)
ifeq ($(filter build,$(MAKECMDGOALS)),build)
_MTB_CORE_RUN_MTB_SEARCH=true
endif
ifeq ($(filter all,$(MAKECMDGOALS)),all)
_MTB_CORE_RUN_MTB_SEARCH=true
endif
endif

ifeq (true,$(_MTB_CORE_RUN_MTB_SEARCH))
$(shell rm -f $(_CY_QBUILD_MK_FILE))
endif

# generate the cyqbuild.mk file
$(_CY_QBUILD_MK_FILE): | prebuild
	$(info )
	$(info Auto-discovery in progress...)
	$(CY_NOISE)$(_MTB_SEARCH_CMD)
	$(info Auto-discovery complete)
