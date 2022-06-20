################################################################################
# \file search.mk
#
# \brief
# Parses the data from cyqbuild.mk to generate useful build variables
#
################################################################################
# \copyright
# Copyright 2021 Cypress Semiconductor Corporation
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

_MTB_SEARCH_SOURCE_EXT=$(foreach ext,$(CY_TOOLCHAIN_SUFFIX_C) $(CY_TOOLCHAIN_SUFFIX_S) $(CY_TOOLCHAIN_SUFFIX_s) $(CY_TOOLCHAIN_SUFFIX_CPP),.$(ext))
_MTB_SEARCH_LIB_EXT=$(foreach ext,$(CY_TOOLCHAIN_SUFFIX_O) $(CY_TOOLCHAIN_SUFFIX_A),.$(ext))
_MTB_SEARCH_HEADER_EXT=$(foreach ext,$(CY_TOOLCHAIN_SUFFIX_H) $(CY_TOOLCHAIN_SUFFIX_HPP),.$(ext))

CY_SEARCH_APP_SOURCE:=$(sort $(filter $(foreach ext,$(_MTB_SEARCH_SOURCE_EXT),%$(ext)),$(CY_SEARCH_ALL_FILES)))
CY_SEARCH_APP_LIBS:=$(sort $(filter $(foreach ext,$(_MTB_SEARCH_LIB_EXT),%$(ext)),$(CY_SEARCH_ALL_FILES)))
CY_SEARCH_APP_INCLUDES:=$(sort $(CY_SEARCH_ALL_INCLUDES))
CY_SEACH_APP_HEADERS:=$(sort $(filter $(foreach ext, $(_MTB_SEARCH_HEADER_EXT),%$(ext)),$(CY_SEARCH_ALL_FILES)))

CY_SEARCH_APP_SOURCE_ASSET:=$(sort $(foreach s,$(SEARCH),$(filter $(s)/%,$(CY_SEARCH_APP_SOURCE))))
