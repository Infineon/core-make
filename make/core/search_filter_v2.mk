################################################################################
# \file search_filter.mk
#
# \brief
# Parses the data from cyqbuild.mk to generate useful build variables
#
################################################################################
# \copyright
# Copyright 2021-2024 Cypress Semiconductor Corporation
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

_MTB_CORE__SEARCH_HEADER_EXT=$(foreach ext,$(MTB_RECIPE__SUFFIX_H) $(MTB_RECIPE__SUFFIX_HPP),.$(ext))

MTB_CORE__SEARCH_APP_SOURCE:=$(MTB_SEARCH_SOURCES)

# Use filter-out %.o instead because some libraries have .a or .ar extension.
MTB_CORE__SEARCH_APP_LIBS:=$(sort $(filter-out %.$(MTB_RECIPE__SUFFIX_O),$(MTB_SEARCH_ALL_OBJECTS) $(MTB_SEARCH_OBJECTS)))
MTB_CORE__SEARCH_APP_OBJECTS:=$(sort $(filter %.$(MTB_RECIPE__SUFFIX_O),$(CY_SEARCH_ALL_FILES) $(MTB_SEARCH_OBJECTS)))

MTB_CORE__SEARCH_APP_INCLUDES:=$(CY_SEARCH_ALL_INCLUDES)
_MTB_CORE__SEACH_APP_HEADERS:=$(sort $(filter $(foreach ext, $(_MTB_CORE__SEARCH_HEADER_EXT),%$(ext)),$(CY_SEARCH_ALL_FILES)))
