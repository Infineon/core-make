################################################################################
# \file utils.mk
#
# \brief
# Global utilities used across the application recipes and BSPs
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
# Components
################################################################################

#
# VFP-specific component
#
ifeq ($(VFP_SELECT),hardfp)
CY_COMPONENT_VFP:=HARDFP
else
CY_COMPONENT_VFP:=SOFTFP
endif

#
# Component list
#
CY_COMPONENT_LIST_DEFAULT=$(CORE) $(CY_COMPONENT_VFP) $(COMPONENTS)
# Note: CY_DEFAULT_COMPONENT is needed as DISABLE_COMPONENTS cannot be empty
DISABLE_COMPONENTS+=CY_DEFAULT_COMPONENT
CY_COMPONENT_LIST?=$(sort $(filter-out $(DISABLE_COMPONENTS),$(CY_COMPONENT_LIST_DEFAULT)))


################################################################################
# Utility variables
################################################################################
# Create a make variable that contains a space
CY_EMPTY:=
CY_SPACE:=$(CY_EMPTY) $(CY_EMPTY)

# Create a make variable that contains a soft tab
CY_INDENT:=$(CY_SPACE)$(CY_SPACE)$(CY_SPACE)$(CY_SPACE)

# Create a make variable that contains a hard tab
CY_TAB:= $(CY_SPACE)	$(CY_SPACE)

# Create a make variable that contains a line break
define CY_NEWLINE


endef

# Create a maker that can be used by a replace operation to insert a newline
CY_NEWLINE_MARKER=__!__

# Create a make variable that contains a comma
CY_COMMA:=,

# Displays/Hides the build steps
ifneq (,$(filter $(VERBOSE),true 1))
CY_NOISE:=
CY_CMD_TERM:=
else
CY_NOISE:=@
CY_CMD_TERM:= > /dev/null 2>&1
endif

# Extract the make version number
CY_MAKE_MAJOR_VERSION=$(word 1, $(subst ., ,$(MAKE_VERSION)))
CY_MAKE_MINOR_VERSION=$(word 2, $(subst ., ,$(MAKE_VERSION)))

# This setting allows the command to run in the background.  Some invocations of "make config"
# need to override this behavior (ex. VS Code in Windows)
CY_CONFIG_JOB_CONTROL=&


################################################################################
# Environment-specific
################################################################################

# Set the location of the find utility (Avoid conflict with Windows system32/find.exe)
CY_FIND:=/usr/bin/find

CY_SHELL_TYPE=make
CY_FILE_TYPE=cat
ifeq ($(strip $(filter 3 2 1,$(CY_MAKE_MAJOR_VERSION))),)
ifeq ($(strip $(filter 2 1 0,$(CY_MAKE_MINOR_VERSION))),)
# GNU make v4.3 and higher interprets "#" symbols differently.
# Prior to this, it needed an escape character (in shell function) as it is interpreted as a comment.
CY_SHELL_TYPE=shell
endif
ifeq ($(strip $(filter 1 0,$(CY_MAKE_MINOR_VERSION))),)
# Use the file function to speed up file reads and writes. Only applicable for GNU make v4.2 and above
CY_FILE_TYPE=file
endif
endif


################################################################################
# Macros
################################################################################

#
# Reads from file
# $(1) : File to read
#
ifeq ($(CY_FILE_TYPE),file)
CY_MACRO_FILE_READ=$(file <$1)
else
CY_MACRO_FILE_READ=$(shell cat $1)
endif

#
# Writes to file
# $(1) : File to write
# $(2) : String
#
ifeq ($(CY_FILE_TYPE),file)
CY_MACRO_FILE_WRITE=$(file >$1,$2)
else
CY_MACRO_FILE_WRITE=$(shell echo "$2" >$1)
endif

#
# Prints for bypassing TARGET/DEVICE checks
# $(1) : String to print
#
ifeq ($(CY_COMMENCE_BUILD),true)
CY_MACRO_ERROR=$(error $(1))
else
CY_MACRO_ERROR=$(info WARNING: $(1))
endif

#
# Prints the warning and creates a variable to hold that warning (for printing later)
# Note that this doesn't use the $(warning) function as that adds the line number (not useful for end user)
# $(1) : Message ID
# $(2) : String to print
#
define CY_MACRO_WARNING
$(info )
$(info $(2))
CY_WARNING_$(1)=$(2)
endef

#
# Prints the info and creates a variable to hold that info (for printing later)
# $(1) : Message ID
# $(2) : String to print
#
define CY_MACRO_INFO
$(info )
$(info $(2))
CY_INFO_$(1)=$(2)
endef

#
# Macros to find all COMPONENTS not listed in the component list.
# Step 1: Find all COMPONENT directories in app
# Step 2: Process the list and get a list of all COMPONENTS
# Step 3: Compare the found COMPONENTS with the expected components list
#
# $(1): List of files of a certain file type
#
CY_MACRO_FIND_COMPONENTS=$(strip $(foreach item,$(1),$(if $(findstring /COMPONENT_,/$(item)),$(item),)))
CY_MACRO_PROCESS_COMPONENTS=\
$(foreach item,$(1),\
    $(if $(findstring /COMPONENT_,/$(notdir $(item))),$(subst COMPONENT_,,$(notdir $(item))),)\
    $(if $(call CY_MACRO_EQUALITY,$(CY_INTERNAL_APP_PATH),$(item)),,$(call CY_MACRO_PROCESS_COMPONENTS,$(call CY_MACRO_DIR,$(item))))\
)
CY_MACRO_COMPARE_COMPONENTS=$(filter-out $(CY_COMPONENT_LIST),$(sort $(call CY_MACRO_PROCESS_COMPONENTS,$(call CY_MACRO_FIND_COMPONENTS,$(1)))))

#
# Filters for components. Iterates through CY_COMPONENT_LIST
# $(1) : List of files of a certain file type
#
CY_MACRO_MATCH_COMPONENT=$(sort $(foreach component,$(2),\
				$(foreach item,$(1),$(if $(findstring /COMPONENT_$(component)/,/$(item)/),$(item),))))
CY_MACRO_GET_COMPONENT=$(filter-out \
                $(call CY_MACRO_MATCH_COMPONENT,$(1),$(call CY_MACRO_COMPARE_COMPONENTS,$(1))),\
                $(call CY_MACRO_MATCH_COMPONENT,$(1),$(CY_COMPONENT_LIST)))
CY_MACRO_REMOVE_COMPONENT=$(strip $(foreach item,$(1),$(if $(findstring /COMPONENT_,/$(item)),,$(item))))
CY_MACRO_FILTER_COMPONENT=$(call CY_MACRO_REMOVE_COMPONENT,$(1)) $(call CY_MACRO_GET_COMPONENT,$(1))

#
# Filters for configurations
# $(1) : List of files of a certain file type
# $(2) : Filter string
#
CY_MACRO_MATCH_CONFIGURATION=$(strip $(foreach item,$(1),$(if $(findstring $(2),/$(item)/),$(item),)))
CY_MACRO_REMOVE_CONFIGURATION=$(strip $(foreach item,$(1),$(if $(findstring $(2),/$(item)),,$(item))))
CY_MACRO_FILTER_CONFIGURATION=$(call CY_MACRO_REMOVE_CONFIGURATION,$(1),/$(strip $(2))_)\
							$(call CY_MACRO_MATCH_CONFIGURATION,$(1),/$(strip $(2))_$($(strip $(2)))/)\
							$(strip $(if $(findstring -,$($(strip $(2)))),\
							$(call CY_MACRO_MATCH_CONFIGURATION,$(1),/$(strip $(2))_$(subst -,_,$($(strip $(2))))/),\
							))

#
# Filter for defined components and configurations
# $(1) : List of files of a certain file type
#
CY_MACRO_FILTER=\
	$(strip \
	$(call CY_MACRO_FILTER_COMPONENT,\
	$(call CY_MACRO_FILTER_CONFIGURATION,\
	$(call CY_MACRO_FILTER_CONFIGURATION,\
	$(call CY_MACRO_FILTER_CONFIGURATION,\
	$(1),\
	TOOLCHAIN),\
	TARGET),\
	CONFIG)))

#
# Search for files
# $(1) : File type
#
CY_MACRO_FILTER_FILES=$(call CY_MACRO_FILTER,$(CY_SEARCH_PRUNED_$(1)_FILES))

#
# Test for equality
# $(1) : Base path
# $(2) : Directory containing header file
#
CY_MACRO_EQUALITY=$(if $(and $(findstring $1,$2),$(findstring $2,$1)),TRUE)

#
# Recursively search for the parent directories up to the given base directory
# $(1) : Directories containing header files
# $(2) : Base directory
#
CY_MACRO_SEARCH_PARENT=\
$(foreach item,$(1),\
    $(if $(call CY_MACRO_EQUALITY,$(2),$(item)),\
        $(2)\
    ,\
        $(call CY_MACRO_DIR,$(item))\
        $(call CY_MACRO_SEARCH_PARENT,$(call CY_MACRO_DIR,$(item)),$(2))\
    )\
)

#
# Convert to lower case
# $(1) : String to convert to lower case
#
CY_MACRO_LC=$(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,$(subst G,g,$(subst \
		H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst \
		Q,q,$(subst R,r,$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst \
		W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$1))))))))))))))))))))))))))

#
# Convert to upper case
# $(1) : String to convert to upper case
#
CY_MACRO_UC=$(subst a,A,$(subst b,B,$(subst c,C,$(subst d,D,$(subst e,E,$(subst f,F,$(subst g,G,$(subst \
		h,H,$(subst i,I,$(subst j,J,$(subst k,K,$(subst l,L,$(subst m,M,$(subst n,N,$(subst o,O,$(subst p,P,$(subst \
		q,Q,$(subst r,R,$(subst s,S,$(subst t,T,$(subst u,U,$(subst v,V,$(subst \
		w,W,$(subst x,X,$(subst y,Y,$(subst z,Z,$1))))))))))))))))))))))))))

#
# Return the location of a library
# 	Look for library defined in mtb.mk (flow version 2).
# 	If not found, search in ./libs (flow version 1).
#	Return "NotPresent" if both fail
# $(1) : library name
#
CY_MACRO_FINDLIB=$(strip $(if $(SEARCH_$(1)),$(SEARCH_$(1)),\
					$(if $(wildcard $(patsubst %/,%,$(CY_GETLIBS_PATH))/$(1)),\
						$(patsubst %/,%,$(CY_GETLIBS_PATH))/$(1),\
						NotPresent)))


################################################################################
# Misc.
################################################################################

# Note: VSCode .cdb file needs to be known in multiple make files
ifneq ($(CY_BUILD_LOCATION),)
CY_CDB_FILE:=$(CY_INTERNAL_BUILD_LOC)/compile_commands.json
else
CY_CDB_FILE:=./$(notdir $(CY_INTERNAL_BUILD_LOC))/compile_commands.json
endif

# Used to determine locations of dirs and files relative to devicesupport.xml
CY_DEVICESUPPORT_SEARCH_PATH:=$(call CY_MACRO_SEARCH,devicesupport.xml,$(CY_INTERNAL_APP_PATH))\
                    $(if $(CY_INTERNAL_EXTAPP_PATH),$(call CY_MACRO_SEARCH,devicesupport.xml,$(CY_INTERNAL_EXTAPP_PATH)))\
                    $(if $(SEARCH_LIBS_AND_INCLUDES),$(foreach d,$(SEARCH_LIBS_AND_INCLUDES),$(call CY_MACRO_SEARCH,devicesupport.xml,$(d))))\
					$(if $(SEARCH),$(foreach d,$(SEARCH),$(call CY_MACRO_SEARCH,devicesupport.xml,$(d))))

# Note: Used only for legacy BTSDK apps
ifneq ($(SEARCH_LIBS_AND_INCLUDES),)
ifneq ($(CY_SHARED_PATH),)
CY_SHARED_ALL_LIB_FILES:=$(call CY_MACRO_SEARCH,.lib,$(CY_SHARED_PATH))
CY_SHARED_USED_LIB_NAMES=$(foreach item,$(SEARCH_LIBS_AND_INCLUDES),$(notdir $(item).lib))
CY_SHARED_USED_LIB_FILES=$(foreach name,$(CY_SHARED_USED_LIB_NAMES),$(filter %/$(name),$(CY_SHARED_ALL_LIB_FILES)))
endif
endif


################################################################################
# Utility targets
################################################################################

ifeq ($(filter bsp,$(MAKECMDGOALS)),bsp)
CY_INTERNAL_IS_RUNNING_BSP_TARGET=true
CY_INTERNAL_BSP_TARGET_CREATE_BACK_UP=false
else
ifeq ($(filter update_bsp,$(MAKECMDGOALS)),update_bsp)
CY_INTERNAL_IS_RUNNING_BSP_TARGET=true
CY_INTERNAL_BSP_TARGET_CREATE_BACK_UP=true
else
CY_INTERNAL_IS_RUNNING_BSP_TARGET=false
endif
endif

ifeq ($(CY_INTERNAL_IS_RUNNING_BSP_TARGET),true)
# Applicable for tools_2.2 and above
ifneq ($(CY_TOOL_library-manager-cli_EXE),)
ifneq ($(CY_GETLIBS_OFFLINE),)
CY_BSP_DEPENDENCIES_OFFLINE=--offline
endif
# Check if the BSP is a repo. If so, get all tags associated with the checked out commit
CY_BSP_TAGS=$(strip $(shell cd $(CY_TARGET_DIR); \
	if [[ "$(abspath $(CY_TARGET_DIR))" == "$$(git rev-parse --show-toplevel 2>/dev/null)" ]]; then\
		git tag --points-at HEAD;\
	fi;))
ifneq ($(CY_BSP_TAGS),)
CY_BSP_DEPENDENCIES_COMMIT=--get_bsp_deps_commit "$(CY_BSP_TAGS)"
endif
CY_BSP_DEPENDENCIES_CMD=$(CY_TOOL_library-manager-cli_EXE) --get_bsp_deps_id $(TARGET) $(CY_BSP_DEPENDENCIES_COMMIT) --get_bsp_deps_dir $(CY_TARGET_GEN_DIR)/deps $(CY_BSP_DEPENDENCIES_OFFLINE);
endif
endif

bsp:
	$(if $(TARGET_GEN),,$(info )$(call CY_MACRO_ERROR, TARGET_GEN variable must be specified to generate a BSP))
	$(if $(ADDITIONAL_DEVICE_GEN),$(error ADDITIONAL_DEVICE_GEN variable is no longer supported))
	$(if $(wildcard $(CY_TARGET_GEN_DIR)),$(info )$(call CY_MACRO_ERROR,"$(TARGET_GEN)" TARGET already exists at "$(CY_TARGET_GEN_DIR)"))
	$(info $(CY_NEWLINE)Creating $(TARGET_GEN) TARGET from $(TARGET)...)
	$(CY_NOISE)cp -rf $(CY_TARGET_DIR) $(CY_TARGET_GEN_DIR);\
	rm -rf $(CY_TARGET_GEN_DIR)/.git;\
	mv -f $(CY_TARGET_GEN_DIR)/$(TARGET).mk $(CY_TARGET_GEN_DIR)/$(TARGET_GEN).mk;\
	sed -i -e s/$(TARGET)/"$(TARGET_GEN)"/g $(CY_TARGET_GEN_DIR)/$(TARGET_GEN).mk;\
	sed -i -e /^DEVICE/s%=.*%="$(DEVICE_GEN)"\% $(CY_TARGET_GEN_DIR)/$(TARGET_GEN).mk;\
	$(CY_BACK_OLD_BSP_TEMPLATES_CMD)\
	$(CY_BSP_TEMPLATES_CMD)\
	$(CY_BSP_DEPENDENCIES_CMD)\
	$(CY_BSP_DEVICES_CMD)\
	$(CY_BSP_UPDATE_FLASH_LOADER_CMD)\
	rm -f $(CY_TARGET_GEN_DIR)/$(TARGET_GEN).mk-e;\
	echo ""$(TARGET_GEN)" TARGET created at "$(CY_TARGET_GEN_DIR)""; echo;

update_bsp:
	$(if $(TARGET_GEN),,$(info )$(call CY_MACRO_ERROR, TARGET_GEN variable must be specified to update a BSP))
	$(if $(ADDITIONAL_DEVICE_GEN),$(error ADDITIONAL_DEVICE_GEN variable is no longer supported))
	$(if $(wildcard $(CY_TARGET_GEN_DIR)),,$(info )$(call CY_MACRO_ERROR,"$(TARGET_GEN)" TARGET does not exists at "$(CY_TARGET_GEN_DIR)"))
	$(info $(CY_NEWLINE)Updating $(TARGET_GEN) TARGET...)
	$(CY_NOISE)sed -i -e s/$(TARGET)/"$(TARGET_GEN)"/g $(CY_TARGET_GEN_DIR)/$(TARGET_GEN).mk;\
	sed -i -e /^DEVICE/s%=.*%="$(DEVICE_GEN)"\% $(CY_TARGET_GEN_DIR)/$(TARGET_GEN).mk;\
	$(CY_BACK_OLD_BSP_TEMPLATES_CMD)\
	$(CY_BSP_TEMPLATES_CMD)\
	$(CY_BSP_DEPENDENCIES_CMD)\
	$(CY_BSP_DEVICES_CMD)\
	$(CY_BSP_UPDATE_FLASH_LOADER_CMD)\
	echo ""$(TARGET_GEN) TARGET was updated ""$(CY_TARGET_GEN_DIR)""; echo;

# Default conversion type set to local
CONVERSION_TYPE?=local

# Note the .lib file processing is the same as that in getlibs.bash
lib2mtbx:
	$(if $(CONVERSION_PATH),,$(info )$(call CY_MACRO_ERROR, CONVERSION_PATH variable must be specified to convert files))
	$(if $(wildcard $(CONVERSION_PATH)),,$(info )$(call CY_MACRO_ERROR,"$(CONVERSION_PATH)" directory does not exist))
	$(if $(filter local shared,$(CONVERSION_TYPE)),,$(call CY_MACRO_ERROR, CONVERSION_TYPE must be either "local" or "shared"))
	$(info $(CY_NEWLINE)Converting .lib files to "$(CONVERSION_TYPE)" .mtbx files in "$(CONVERSION_PATH)"...)
	$(CY_NOISE)libFiles=$$($(CY_FIND) $(CONVERSION_PATH) -type f \( -name "*.lib" \));\
	for libFile in $$libFiles; do \
		mtbxFile="$${libFile%.lib}.mtbx";\
		read -r currLibRaw < "$$libFile" || [[ $$libFile ]];\
		currLibRaw="$$(echo -e "$${currLibRaw}" | tr -d '[:space:]')";\
		currLibTag="$${currLibRaw##*#}";\
		currLibTag="$${currLibTag%/*}";\
		currLibUrl="$${currLibRaw%#*}";\
		if [[ "$${currLibUrl: -1}" == "/" ]]; then\
			currLibUrl="$${currLibUrl%/*}";\
			currLibName="$${currLibUrl##*/}";\
		else\
			currLibName="$${currLibUrl##*/}";\
		fi;\
		if [[ "$(CONVERSION_TYPE)" == "local" ]]; then\
			mtbxContent='$$$$LOCAL$$$$'/"$$currLibName";\
		else\
			mtbxContent='$$$$ASSET_REPO$$$$'/"$$currLibName"/"$$currLibTag";\
		fi;\
		if [[ -f "$$mtbxFile" ]] && [[ ! "$(FORCE)" ]] ; then\
			mtbxIgnored+=($$mtbxFile);\
		else\
			echo ""$$currLibRaw"#"$$mtbxContent"" > "$$mtbxFile";\
			mtbxFiles+=($$mtbxFile);\
		fi;\
	done;\
	if [[ "$$libFiles" ]]; then\
		if [[ "$$mtbxFiles" ]]; then\
			echo "Dependency .mtbx files created.";\
			printf '  %s\n' "$${mtbxFiles[@]}";\
			echo;\
		fi;\
		if [[ "$$mtbxIgnored" ]]; then \
			echo "Skipped creating following .mtbx files as they already exist.";\
			printf '  %s\n' "$${mtbxIgnored[@]}";\
			echo;\
		fi;\
	else\
		echo "Could not locate any .lib files."; \
		echo "Check that the CONVERSION_PATH variable contains the correct path.";\
		echo;\
		exit 1;\
	fi

_CY_FULL_COMPONENT_LIST=$(CORE) $(CY_COMPONENT_VFP) $(COMPONENTS) $(TOOLCHAIN) $(TARGET) $(CONFIG)

ifeq ($(CY_PROTOCOL),)
_CORE_CY_PROTOCOL_VERSION:=2
else
_CORE_CY_PROTOCOL_VERSION:=$(CY_PROTOCOL)
endif
_CORE_MAKE_SUPPORTED_PROTOCAL_VERSIONS=1

ifeq ($(MTB_QUERY),)
# undefined MTB_QUERY. Use the latest
_CORE_MTB_QUERY=$(lastword $(_CORE_MAKE_SUPPORTED_PROTOCAL_VERSIONS))
# MTB_QUERY version is supported
else ifeq ($(filter $(MTB_QUERY),$(_CORE_MAKE_SUPPORTED_PROTOCAL_VERSIONS)),$(MTB_QUERY))
_CORE_MTB_QUERY=$(MTB_QUERY)
else
# MTB_QUERY is newer than max supported version. Use the latest
_CORE_MTB_QUERY=$(lastword $(_CORE_MAKE_SUPPORTED_PROTOCAL_VERSIONS))
$(warning Requested MTB_QUERY version is newer than is supported.)
endif

# CY_PROTOCOl=2, MTB_QUERY=1. Supports Modustoolbox 3.0
get_app_info_2_1:
	@:
	$(info MTB_DEVICE=$(DEVICE))
	$(info MTB_SEARCH=$(CY_TOOLS_MAKE_SEARCH_DIRS))
	$(info MTB_TOOLCHAIN=$(TOOLCHAIN))
	$(info MTB_TARGET=$(TARGET))
	$(info MTB_APP_NAME=$(APPNAME)$(LIBNAME))
	$(info MTB_COMPONENTS=$(_CY_FULL_COMPONENT_LIST))
	$(info MTB_DISABLED_COMPONENTS=$(DISABLE_COMPONENTS))
	$(info MTB_ADDITIONAL_DEVICES=$(ADDITIONAL_DEVICES))
	$(info MTB_LIBS=$(CY_INTERNAL_GETLIBS_PATH))
	$(info MTB_DEPS=$(CY_INTERNAL_GETLIBS_DEPS_PATH))
	$(info MTB_WKS_SHARED_NAME=$(CY_GETLIBS_SHARED_NAME))
	$(info MTB_WKS_SHARED_DIR=$(CY_GETLIBS_SHARED_PATH))
	$(info MTB_FLOW_VERSION=$(FLOW_VERSION))
	$(info MTB_QUERY=$(_CORE_MTB_QUERY))
	$(info MTB_TOOLS_DIR=$(CY_TOOLS_DIR))
	$(info MTB_BSP_TOOL_TYPES=$(MTB_CORE_BSP_OPEN_FILTERED_SUPPORTED_TYPES))
	$(info MTB_MW_TOOL_TYPES=$(MTB_CORE_OPEN_MW_FILTER_SUPPORTED_TYPES))
	$(info MTB_IGNORE=$(CY_IGNORE_DIRS))
ifneq ($(MTB_TYPE),)
	$(info MTB_TYPE=$(MTB_TYPE))
else
	$(info MTB_TYPE=LEGACY)
endif
	$(info MTB_CORE_TYPE=$(CORE))
	$(info MTB_CORE_NAME=$(CORE_NAME))
	$(info MTB_BUILD_SUPPORT=$(MTB_BUILD_SUPPORT))
	$(info MTB_GIT_CACHE_DIR=$(CY_GETLIBS_CACHE_PATH))
	$(info MTB_OFFLINE_DIR=$(CY_GETLIBS_OFFLINE_PATH))

get_app_info: get_app_info_$(_CORE_CY_PROTOCOL_VERSION)_$(_CORE_MTB_QUERY)
	@:

_GET_APP_INFO_COMMAND_LINE=$(sort $(foreach var,$(.VARIABLES),$(if $(filter command line,$(origin $(var))),$(var)="$($(var))")))

################################################################################
# Test/debug targets
################################################################################

CY_TOOLS_LIST+=bash git find ls cp mkdir rm cat sed awk perl file whereis

check:
	@:
	$(info )
	$(foreach tool,$(CY_TOOLS_LIST),$(if $(shell which $(tool)),\
		$(info SUCCESS: "$(tool)" found in PATH),$(info FAILED : "$(tool)" was not found in PATH)$(info )))
	$(info )
	$(foreach tool,$(sort $(filter CY_INTERNAL_TOOL_%,$(.VARIABLES))),$(if $(wildcard $($(tool))),\
		$(info SUCCESS: "$($(tool))" found on disk),$(info FAILED : "$($(tool))" was not found on disk)$(info )))
	$(info )
	$(info Tools check complete.)
	$(info )

get_env_info:
	$(CY_NOISE)echo;\
	echo "make location :" $$(which make);\
	echo "make version  :" $(MAKE_VERSION);\
	echo "git location  :" $$(which git);\
	echo "git version   :" $$(git --version);\
	echo "git remote    :";\
	git remote -v;\
	echo "git rev-parse :" $$(git rev-parse HEAD)

printlibs:

# Defined in recipe's program.mk
progtool:

# Empty libs on purpose. May be defined by the application
shared_libs:

#
# Identify the phony targets
#
.PHONY: bsp lib2mtbx check get_env_info get_app_info printlibs shared_libs
