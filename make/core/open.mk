################################################################################
# \file open.mk
#
# \brief
# Opens/launches a specified tool 
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


################################################################################
# Additional tools
################################################################################

# Tools that can be launched using make open CY_OPEN_TYPE=<tool name> command,
# but are not shown in the Eclipse for ModusToolbox.
CY_SUPPORTED_HIDDEN_TOOL_TYPES+=project-creator library-manager

##########################
# online-simulator
##########################

# CY_ALL_TOOLS_DIRS wildcard/filter-out tools that don't exist on disk. Provide an absolute path to these tools so that they won't be filtered out
ifeq ($(OS),Windows_NT)
CY_OPEN_online_simulator_TOOL=$(subst \,/,${COMSPEC})
CY_OPEN_online_simulator_TOOL_FLAGS=/c start
else
ifneq ($(findstring Darwin,$(shell uname)),)
CY_OPEN_online_simulator_TOOL=/usr/bin/open
CY_OPEN_online_simulator_TOOL_FLAGS=
else
CY_OPEN_online_simulator_TOOL=/usr/bin/xdg-open
CY_OPEN_online_simulator_TOOL_FLAGS=
endif
endif
CY_OPEN_online_simulator_EXT=
CY_OPEN_online_simulator_TOOL_NEWCFG_FLAGS=

################################################################################
# New configurations
################################################################################

# Limit this as it can be a performance hit
ifneq ($(filter get_app_info open,$(MAKECMDGOALS)),)

# The list of BSP configurators. (Application level configurators)
MTB_CORE_BSP_OPEN_FILTERED_SUPPORTED_TYPES=$(filter $(MTB_BSP_CONFIGURATORS),$(CY_SUPPORTED_TOOL_TYPES))
# The list of MW configurators. (Project level configurators)
MTB_CORE_OPEN_MW_FILTER_SUPPORTED_TYPES=$(filter-out $(MTB_CORE_BSP_OPEN_FILTERED_SUPPORTED_TYPES),$(CY_SUPPORTED_TOOL_TYPES))

endif

################################################################################
# Prepare tool launch
################################################################################

# Extension construction from given file
ifneq ($(CY_OPEN_FILE)),)
CY_OPEN_EXT=$(subst .,,$(suffix $(CY_OPEN_FILE)))
endif

# Only file is given. Use the default type for that file extension
ifneq ($(CY_OPEN_FILE),)
ifeq ($(CY_OPEN_TYPE),)
CY_OPEN_TYPE=$(firstword $($(CY_OPEN_EXT)_DEFAULT_TYPE))
endif
endif

# Set the tool and its arguments
CY_OPEN_TOOL_FILE=$(CY_OPEN_$(subst -,_,$(CY_OPEN_TYPE))_FILE)
CY_OPEN_TOOL_LAUNCH="$(CY_OPEN_$(subst -,_,$(CY_OPEN_TYPE))_TOOL)"
CY_OPEN_TOOL_FLAGS=$(CY_OPEN_$(subst -,_,$(CY_OPEN_TYPE))_TOOL_FLAGS)
CY_OPEN_TOOL_ARGS=$(CY_OPEN_$(subst -,_,$(CY_OPEN_TYPE))_TOOL_ARGS)
CY_OPEN_TOOL_NEWCFG_FLAGS=$(CY_OPEN_$(subst -,_,$(CY_OPEN_TYPE))_TOOL_NEWCFG_FLAGS)
CY_OPEN_TOOL_ADDITIONAL_ARGS=$(CY_OPEN_$(subst -,_,$(CY_OPEN_TYPE))_ADDITIONAL_ARGS)

# Use the file if provided
ifneq ($(CY_OPEN_FILE),)
CY_OPEN_TOOL_FILE=$(CY_OPEN_FILE)
endif

ifneq ($(CY_MAKE_IDE),)
CY_OPEN_STDOUT=>& /dev/null
endif


################################################################################
# Tool launch target
################################################################################

open:
ifeq ($(CY_OPEN_FILE),)
ifeq ($(CY_OPEN_TYPE),)
	$(call CY_MACRO_ERROR,Neither tool type or file specified to launch a tool)
endif
endif
ifneq ($(CY_OPEN_TYPE),)
ifeq ($(filter $(CY_OPEN_TYPE),$(CY_SUPPORTED_TOOL_TYPES) $(CY_SUPPORTED_HIDDEN_TOOL_TYPES)),)
	$(call CY_MACRO_ERROR,Unsupported tool type - $(CY_OPEN_TYPE). $(CY_NEWLINE)Supported types are: $(sort $(CY_SUPPORTED_TOOL_TYPES) $(CY_SUPPORTED_HIDDEN_TOOL_TYPES)))
endif
endif
ifeq ($(CY_OPEN_TOOL_LAUNCH),)
	$(call CY_MACRO_ERROR,Unable to find a default tool to launch .$(CY_OPEN_EXT) file extension)
endif
ifneq ($(filter $(CY_OPEN_TYPE),$(CY_SUPPORTED_HIDDEN_TOOL_TYPES)),)
	$(info $(CY_NEWLINE)Launching $(notdir $(CY_OPEN_TOOL_LAUNCH)) tool)
	$(CY_NOISE) $(CY_OPEN_TOOL_LAUNCH)
else
ifeq ($(CY_OPEN_TOOL_FILE),)
	$(info Launching $(notdir $(CY_OPEN_TOOL_LAUNCH)) tool for a new configuration)
	$(CY_NOISE) $(CY_OPEN_TOOL_LAUNCH) $(CY_OPEN_TOOL_ARGS) $(CY_OPEN_TOOL_NEWCFG_FLAGS) $(CY_OPEN_TOOL_ADDITIONAL_ARGS) $(CY_OPEN_STDOUT) $(CY_CONFIG_JOB_CONTROL)
else 
	$(info $(CY_NEWLINE)Launching $(notdir $(CY_OPEN_TOOL_LAUNCH)) tool on $(CY_OPEN_TOOL_FILE))
	$(CY_NOISE) $(CY_OPEN_TOOL_LAUNCH) $(CY_OPEN_TOOL_ARGS) $(CY_OPEN_TOOL_FLAGS) $(CY_OPEN_TOOL_FILE) $(CY_OPEN_TOOL_ADDITIONAL_ARGS) $(CY_OPEN_STDOUT) $(CY_CONFIG_JOB_CONTROL)
endif
endif

modlibs:
	$(info Launching library-manager)
	$(CY_NOISE) $(CY_OPEN_library_manager_TOOL) $(CY_OPEN_library_manager_TOOL_FLAGS) $(CY_CONFIG_JOB_CONTROL)

#
# Identify the phony targets
#
.PHONY: open
