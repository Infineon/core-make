################################################################################
# \file search.mk
#
# \brief
# Performs auto-discovery of files in the project directories.
#
################################################################################
# \copyright
# Copyright 2018-2020 Cypress Semiconductor Corporation
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
$(info Auto-discovery in progress...)


################################################################################
# Macros
################################################################################

#
# Construct absolute paths for given relative paths
# $(1) : relative paths
#
define CY_MACRO_ABSPATHS

CY_SEARCH_ABSPATH_$(1)=$(abspath $(1))
CY_SEARCH_RELPATH_$(abspath $(1))=$(1)

endef

#
# Convert absolute paths to relative paths
# $(1) : asbolute paths
#
CY_MACRO_RELPATHS=$(foreach abs,$(CY_SEARCH_ABSPATH_LIST),$(patsubst $(abs)%,$(CY_SEARCH_RELPATH_$(abs))%,$(filter $(abs)%,$(1))))


################################################################################
# Ignore files
################################################################################

# Extract the files as this will be used to filter individual files in search.mk
CY_IGNORE_FILES:=$(filter %.$(CY_TOOLCHAIN_SUFFIX_C),$(CY_IGNORE_DIRS))\
					$(filter %.$(CY_TOOLCHAIN_SUFFIX_S),$(CY_IGNORE_DIRS))\
					$(filter %.$(CY_TOOLCHAIN_SUFFIX_s),$(CY_IGNORE_DIRS))\
					$(filter %.$(CY_TOOLCHAIN_SUFFIX_CPP),$(CY_IGNORE_DIRS))\
					$(filter %.$(CY_TOOLCHAIN_SUFFIX_A),$(CY_IGNORE_DIRS))\
					$(filter %.$(CY_TOOLCHAIN_SUFFIX_H),$(CY_IGNORE_DIRS))\
					$(filter %.$(CY_TOOLCHAIN_SUFFIX_HPP),$(CY_IGNORE_DIRS))

# Construct the arguments for directories to prune
CY_IGNORE_ABSPATH_LIST:=$(abspath $(filter-out $(CY_IGNORE_FILES),$(CY_IGNORE_DIRS)))
CY_IGNORE_PRUNE:=-name ‘.git’ $(addprefix -o -path ,$(CY_IGNORE_ABSPATH_LIST))


################################################################################
# Dependent apps shared directories
################################################################################

ifneq ($(DEPENDENT_APP_PATHS),)

CY_DEPAPP_EXTAPP_LIST:=$(foreach app,$(DEPENDENT_APP_PATHS),$($(notdir $(app))_DEPAPP_BUILD_LOCATION)/extapp.rsp)
# Convert to relative paths
CY_DEPAPP_EXTAPP_DIRS:=$(foreach extapp,$(CY_DEPAPP_EXTAPP_LIST),$(if $(wildcard $(extapp)),\
                        $(shell extappVal=$$(cat $(extapp)); \
                        perl -e 'use File::Spec; print File::Spec->abs2rel(@ARGV) . "\n"' $$extappVal $(CY_INTERNAL_APP_PATH))))

endif


################################################################################
# Search Files
################################################################################

# Create paths
CY_SEARCH_ASSET:=$(sort $(SEARCH))
CY_SEARCH_PATHCONV_LIST:=$(CY_INTERNAL_APP_PATH) $(CY_INTERNAL_EXTAPP_PATH) $(CY_SEARCH_ASSET) $(CY_DEPAPP_EXTAPP_DIRS)
$(foreach path,$(CY_SEARCH_PATHCONV_LIST),$(eval $(call CY_MACRO_ABSPATHS,$(path))))

# Filter out directories that may be higher in directory hierarchy
CY_SEARCH_ABSPATH_LIST_RAW:=$(foreach path,$(CY_SEARCH_PATHCONV_LIST),$(CY_SEARCH_ABSPATH_$(path)))
CY_SEARCH_ABSPATH_LIST_REMOVE:=$(foreach ignore,$(CY_IGNORE_ABSPATH_LIST),$(filter $(ignore)%,$(CY_SEARCH_ABSPATH_LIST_RAW)))
CY_SEARCH_ABSPATH_LIST:=$(filter-out $(CY_SEARCH_ABSPATH_LIST_REMOVE),$(CY_SEARCH_ABSPATH_LIST_RAW))
CY_SEARCH_RELPATH_LIST:=$(foreach path,$(CY_SEARCH_ABSPATH_LIST),$(CY_SEARCH_RELPATH_$(path)))
CY_SEARCH_IGNORE_FILES:=$(call CY_MACRO_RELPATHS,$(abspath $(CY_IGNORE_FILES)))

#
# Search for files. Use := assignment for better performance.
# Note: find -prune requires absolute paths. Convert the result back to relative path afterwards.
#
CY_SEARCH_ALL_FILES:=$(sort $(call CY_MACRO_RELPATHS,\
                        $(shell $(CY_FIND) -L $(CY_SEARCH_ABSPATH_LIST) \( $(CY_IGNORE_PRUNE) \) -prune \
                        -o -type f -name "*.$(CY_TOOLCHAIN_SUFFIX_C)" -print \
                        -o -type f -name "*.$(CY_TOOLCHAIN_SUFFIX_S)" -print \
                        -o -type f -name "*.$(CY_TOOLCHAIN_SUFFIX_s)" -print \
                        -o -type f -name "*.$(CY_TOOLCHAIN_SUFFIX_CPP)" -print \
                        -o -type f -name "*.$(CY_TOOLCHAIN_SUFFIX_O)" -print \
                        -o -type f -name "*.$(CY_TOOLCHAIN_SUFFIX_A)" -print \
                        -o -type f -name "*.$(CY_TOOLCHAIN_SUFFIX_H)" -print \
                        -o -type f -name "*.$(CY_TOOLCHAIN_SUFFIX_HPP)" -print \
                        -o -type d -name "COMPONENT_RESOURCE" -print \
                        -o -type d -name "* *" -print)))

CY_SEARCH_C_FILES:=$(filter %.$(CY_TOOLCHAIN_SUFFIX_C),$(CY_SEARCH_ALL_FILES))
CY_SEARCH_S_FILES:=$(filter %.$(CY_TOOLCHAIN_SUFFIX_S),$(CY_SEARCH_ALL_FILES))
CY_SEARCH_s_FILES:=$(filter %.$(CY_TOOLCHAIN_SUFFIX_s),$(CY_SEARCH_ALL_FILES))
CY_SEARCH_CPP_FILES:=$(filter %.$(CY_TOOLCHAIN_SUFFIX_CPP),$(CY_SEARCH_ALL_FILES))
CY_SEARCH_O_FILES:=$(filter %.$(CY_TOOLCHAIN_SUFFIX_O),$(CY_SEARCH_ALL_FILES))
CY_SEARCH_A_FILES:=$(filter %.$(CY_TOOLCHAIN_SUFFIX_A),$(CY_SEARCH_ALL_FILES))
CY_SEARCH_H_FILES:=$(filter %.$(CY_TOOLCHAIN_SUFFIX_H),$(CY_SEARCH_ALL_FILES))
CY_SEARCH_HPP_FILES:=$(filter %.$(CY_TOOLCHAIN_SUFFIX_HPP),$(CY_SEARCH_ALL_FILES))

#
# Search for resource directories and gather the files
#
CY_SEARCH_RESOURCE_DIR:=$(filter %/COMPONENT_RESOURCE,$(CY_SEARCH_ALL_FILES))
CY_SEARCH_RESOURCE_FILES:=$(foreach dir,$(CY_SEARCH_RESOURCE_DIR),$(wildcard $(dir)/*))

#
# Check that the directories do not contain spaces
#
CY_SEARCH_EMPTY_DIRS:=$(filter-out $(CY_SEARCH_C_FILES) $(CY_SEARCH_S_FILES) $(CY_SEARCH_s_FILES) $(CY_SEARCH_CPP_FILES)\
                        $(CY_SEARCH_O_FILES) $(CY_SEARCH_A_FILES) $(CY_SEARCH_H_FILES) $(CY_SEARCH_HPP_FILES)\
                        $(CY_SEARCH_RESOURCE_DIR),$(CY_SEARCH_ALL_FILES))

#
# Print the number of discovered files
#
ifneq ($(CY_SEARCH_EMPTY_DIRS),)
$(call CY_MACRO_ERROR,The application must not contain spaces in the paths. Detected dir(s): $(CY_SEARCH_EMPTY_DIRS))
else
$(info -> Found $(words $(CY_SEARCH_C_FILES)) .$(CY_TOOLCHAIN_SUFFIX_C) file(s))
$(info -> Found $(words $(CY_SEARCH_S_FILES)) .$(CY_TOOLCHAIN_SUFFIX_S) file(s))
$(info -> Found $(words $(CY_SEARCH_s_FILES)) .$(CY_TOOLCHAIN_SUFFIX_s) file(s))
$(info -> Found $(words $(CY_SEARCH_CPP_FILES)) .$(CY_TOOLCHAIN_SUFFIX_CPP) file(s))
$(info -> Found $(words $(CY_SEARCH_O_FILES)) .$(CY_TOOLCHAIN_SUFFIX_O) file(s))
$(info -> Found $(words $(CY_SEARCH_A_FILES)) .$(CY_TOOLCHAIN_SUFFIX_A) file(s))
$(info -> Found $(words $(CY_SEARCH_H_FILES)) .$(CY_TOOLCHAIN_SUFFIX_H) file(s))
$(info -> Found $(words $(CY_SEARCH_HPP_FILES)) .$(CY_TOOLCHAIN_SUFFIX_HPP) file(s))
$(info -> Found $(words $(CY_SEARCH_RESOURCE_FILES)) resource file(s))
endif


################################################################################
# Filter lists
################################################################################

$(info Applying filters...)

#
# Apply the filtering for files in .cyignore
#
CY_SEARCH_PRUNED_C_FILES:=$(filter-out $(foreach d,$(CY_SEARCH_IGNORE_FILES),$(filter $(d)%,$(CY_SEARCH_C_FILES))),$(CY_SEARCH_C_FILES))
CY_SEARCH_PRUNED_S_FILES:=$(filter-out $(foreach d,$(CY_SEARCH_IGNORE_FILES),$(filter $(d)%,$(CY_SEARCH_S_FILES))),$(CY_SEARCH_S_FILES))
CY_SEARCH_PRUNED_s_FILES:=$(filter-out $(foreach d,$(CY_SEARCH_IGNORE_FILES),$(filter $(d)%,$(CY_SEARCH_s_FILES))),$(CY_SEARCH_s_FILES))
CY_SEARCH_PRUNED_CPP_FILES:=$(filter-out $(foreach d,$(CY_SEARCH_IGNORE_FILES),$(filter $(d)%,$(CY_SEARCH_CPP_FILES))),$(CY_SEARCH_CPP_FILES))
CY_SEARCH_PRUNED_O_FILES:=$(filter-out $(foreach d,$(CY_SEARCH_IGNORE_FILES),$(filter $(d)%,$(CY_SEARCH_O_FILES))),$(CY_SEARCH_O_FILES))
CY_SEARCH_PRUNED_A_FILES:=$(filter-out $(foreach d,$(CY_SEARCH_IGNORE_FILES),$(filter $(d)%,$(CY_SEARCH_A_FILES))),$(CY_SEARCH_A_FILES))
CY_SEARCH_PRUNED_H_FILES:=$(filter-out $(foreach d,$(CY_SEARCH_IGNORE_FILES),$(filter $(d)%,$(CY_SEARCH_H_FILES))),$(CY_SEARCH_H_FILES))
CY_SEARCH_PRUNED_HPP_FILES:=$(filter-out $(foreach d,$(CY_SEARCH_IGNORE_FILES),$(filter $(d)%,$(CY_SEARCH_HPP_FILES))),$(CY_SEARCH_HPP_FILES))

#
# Apply the COMPONENT and configuration filtering
#
CY_SEARCH_AVAILABLE_C_SOURCES:=$(call CY_MACRO_FILTER_FILES,C)
CY_SEARCH_AVAILABLE_S_SOURCES:=$(call CY_MACRO_FILTER_FILES,S)
CY_SEARCH_AVAILABLE_s_SOURCES:=$(call CY_MACRO_FILTER_FILES,s)
CY_SEARCH_AVAILABLE_CPP_SOURCES:=$(call CY_MACRO_FILTER_FILES,CPP)
CY_SEARCH_AVAILABLE_O_SOURCES:=$(call CY_MACRO_FILTER_FILES,O)
CY_SEARCH_AVAILABLE_A_LIBS:=$(call CY_MACRO_FILTER_FILES,A)

CY_SEARCH_AVAILABLE_H_INCLUDES:=$(sort $(call CY_MACRO_DIR,$(call CY_MACRO_FILTER_FILES,H)))
CY_SEARCH_AVAILABLE_HPP_INCLUDES:=$(sort $(call CY_MACRO_DIR,$(call CY_MACRO_FILTER_FILES,HPP)))

#
# Separate out the external and internal includes
#
CY_SEARCH_DEPAPP_INCLUDES:=$(foreach depapp,$(CY_DEPAPP_EXTAPP_DIRS),$(filter $(depapp)%,$(CY_SEARCH_AVAILABLE_H_INCLUDES) $(CY_SEARCH_AVAILABLE_HPP_INCLUDES)))
CY_SEARCH_ASSET_INCLUDES:=$(foreach asset,$(CY_SEARCH_ASSET),$(filter $(asset)%,$(CY_SEARCH_AVAILABLE_H_INCLUDES) $(CY_SEARCH_AVAILABLE_HPP_INCLUDES)))
CY_SEARCH_EXTAPP_INCLUDES:=$(filter $(CY_INTERNAL_EXTAPP_PATH)/%,$(CY_SEARCH_AVAILABLE_H_INCLUDES) $(CY_SEARCH_AVAILABLE_HPP_INCLUDES))
CY_SEARCH_INTAPP_INCLUDES:=$(filter-out $(CY_SEARCH_EXTAPP_INCLUDES) $(CY_SEARCH_ASSET_INCLUDES) $(CY_SEARCH_DEPAPP_INCLUDES),$(CY_SEARCH_AVAILABLE_H_INCLUDES) $(CY_SEARCH_AVAILABLE_HPP_INCLUDES))

#
# Combine the directories of the header files and its parent directories  
#
CY_SEARCH_AVAILABLE_INCLUDES:=\
    $(sort $(CY_SEARCH_INTAPP_INCLUDES) $(call CY_MACRO_SEARCH_PARENT,$(CY_SEARCH_INTAPP_INCLUDES),$(CY_INTERNAL_APP_PATH)))\
    $(sort $(CY_SEARCH_EXTAPP_INCLUDES) $(call CY_MACRO_SEARCH_PARENT,$(CY_SEARCH_EXTAPP_INCLUDES),$(CY_INTERNAL_EXTAPP_PATH)))\
    $(sort $(CY_SEARCH_ASSET_INCLUDES) $(foreach asset,$(CY_SEARCH_ASSET),$(call CY_MACRO_SEARCH_PARENT,$(filter $(asset)%,$(CY_SEARCH_ASSET_INCLUDES)),$(asset))))\
    $(sort $(CY_SEARCH_DEPAPP_INCLUDES))

# Conditionally add the generated source includes
ifneq ($(CY_SEARCH_RESOURCE_FILES),)
CY_SEARCH_AVAILABLE_INCLUDES+=$(CY_GENERATED_DIR)
endif

#
# Add to the list
#
CY_SEARCH_APP_SOURCE:=$(sort $(CY_SEARCH_AVAILABLE_S_SOURCES) $(CY_SEARCH_AVAILABLE_s_SOURCES)\
                $(CY_SEARCH_AVAILABLE_C_SOURCES) $(CY_SEARCH_AVAILABLE_CPP_SOURCES))
CY_SEARCH_APP_LIBS:=$(sort $(CY_SEARCH_AVAILABLE_O_SOURCES) $(CY_SEARCH_AVAILABLE_A_LIBS))
CY_SEARCH_APP_INCLUDES:=$(CY_SEARCH_AVAILABLE_INCLUDES)

# Filter out the asset sources to create build targets in build.mk
CY_SEARCH_APP_SOURCE_ASSET:=$(foreach asset,$(CY_SEARCH_ASSET),$(filter $(asset)%,$(CY_SEARCH_APP_SOURCE)))

#
# Create cyqbuild makefile
#
CY_SEARCH_GENERATE_QBUILD=\
    mkdir -p $(CY_CONFIG_DIR); \
    echo "CY_COMPONENT_LIST:=$(CY_COMPONENT_LIST)" > $(CY_CONFIG_DIR)/cyqbuild.mk; \
    echo "CY_SEARCH_APP_SOURCE:=$(CY_SEARCH_APP_SOURCE)" >> $(CY_CONFIG_DIR)/cyqbuild.mk; \
    echo "CY_SEARCH_APP_LIBS:=$(CY_SEARCH_APP_LIBS)" >> $(CY_CONFIG_DIR)/cyqbuild.mk; \
    echo "CY_SEARCH_APP_INCLUDES:=$(CY_SEARCH_APP_INCLUDES)" >> $(CY_CONFIG_DIR)/cyqbuild.mk; \
	echo "CY_SEARCH_APP_SOURCE_ASSET:=$(CY_SEARCH_APP_SOURCE_ASSET)" >> $(CY_CONFIG_DIR)/cyqbuild.mk;

$(info Auto-discovery complete)
