################################################################################
# \file build_v1.mk
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

$(info )
$(info Constructing build rules...)

################################################################################
# Macros
################################################################################

#
# Prints full/shortened source name
# This can't be set with = since it contains $<
#
ifneq (,$(filter $(VERBOSE),true 1))
_MTB_CORE__BUILD_COMPILE_PRINT=$<
else
_MTB_CORE__BUILD_COMPILE_PRINT=$(notdir $<)
endif


################################################################################
# Target output
################################################################################

ifneq ($(LIBNAME),)
_MTB_CORE__BUILD_TARGET:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(LIBNAME).$(MTB_RECIPE__SUFFIX_A)
else
_MTB_CORE__BUILD_TARGET:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_TARGET)
_MTB_CORE__BUILD_MAPFILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_MAP)
endif

#
# Construct explicit rules for select files
# $(1) : source file
# $(2) : object file
# $(3) : file origin identifier
#
define mtb_explicit_build_rule

# Build the correct compiler arguments
$(2)_SUFFIX=$$(suffix $(1))
ifeq ($$($(2)_SUFFIX),.$(MTB_RECIPE__SUFFIX_s))
$(2)_EXPLICIT_COMPILE_ARGS=$(_MTB_CORE__BUILD_COMPILE_AS_LC)
else ifeq ($$($(2)_SUFFIX),.$(MTB_RECIPE__SUFFIX_S))
$(2)_EXPLICIT_COMPILE_ARGS=$(_MTB_CORE__BUILD_COMPILE_AS_UC)
else ifeq ($$($(2)_SUFFIX),.$(MTB_RECIPE__SUFFIX_C))
$(2)_EXPLICIT_COMPILE_ARGS=$(_MTB_CORE__BUILD_COMPILE_EXPLICIT_C)
else ifeq ($$($(2)_SUFFIX),.$(MTB_RECIPE__SUFFIX_CPP))
$(2)_EXPLICIT_COMPILE_ARGS=$(_MTB_CORE__BUILD_COMPILE_EXPLICIT_CPP)
else ifeq ($$($(2)_SUFFIX),.$(MTB_RECIPE__SUFFIX_CXX))
$(2)_EXPLICIT_COMPILE_ARGS=$(_MTB_CORE__BUILD_COMPILE_EXPLICIT_CPP)
else ifeq ($$($(2)_SUFFIX),.$(MTB_RECIPE__SUFFIX_CC))
$(2)_EXPLICIT_COMPILE_ARGS=$(_MTB_CORE__BUILD_COMPILE_EXPLICIT_CPP)
else
$$(call mtb__error,Incompatible source file type encountered while constructing explicit rule: $(1))
endif

$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(2): $(1)
ifneq ($(CY_MAKE_IDE),eclipse)
	$$(info $$(MTB__INDENT)Compiling $(3) file $$(_MTB_CORE__BUILD_COMPILE_PRINT))
else
	$$(info Compiling $$< $$(MTB_RECIPE__DEFINES) $$(MTB_RECIPE__INCLUDES))
endif
	$(MTB__NOISE)$$($(2)_EXPLICIT_COMPILE_ARGS) $$@ $$(call mtb_core__abspath,$$<)

endef

################################################################################
# Build arguments
################################################################################

#
# Strip off the paths for conversion to build output files
#
_MTB_CORE__BUILD_EXTSRC_LIST:=$(SOURCES) $(_MTB_CORE__SEARCH_EXT_SOURCE_ASSET)
_MTB_CORE__BUILD_INTSRC_LIST:=$(filter-out $(_MTB_CORE__BUILD_EXTSRC_LIST),$(MTB_RECIPE__SOURCE))
_MTB_CORE__BUILD_SRC_STRIPPED:=$(patsubst $(MTB_TOOLS__REL_PRJ_PATH)/%,%,$(_MTB_CORE__BUILD_INTSRC_LIST))
_MTB_CORE__BUILD_EXTSRC_RELATIVE:=$(sort $(filter $(MTB_TOOLS__REL_PRJ_PATH)/%,$(_MTB_CORE__BUILD_EXTSRC_LIST)) $(filter ../%,$(_MTB_CORE__BUILD_EXTSRC_LIST)) $(filter ./%,$(_MTB_CORE__BUILD_EXTSRC_LIST)))
_MTB_CORE__BUILD_EXTSRC_ABSOLUTE:=$(filter-out $(_MTB_CORE__BUILD_EXTSRC_RELATIVE),$(_MTB_CORE__BUILD_EXTSRC_LIST))
_MTB_CORE__BUILD_EXTSRC_RELATIVE_STRIPPED:=$(patsubst $(MTB_TOOLS__REL_PRJ_PATH)/%,%,$(subst ../,,$(_MTB_CORE__BUILD_EXTSRC_RELATIVE)))
_MTB_CORE__BUILD_EXTSRC_ABSOLUTE_STRIPPED:=$(notdir $(_MTB_CORE__BUILD_EXTSRC_ABSOLUTE))

#
# Source files that come from the application, and external input
#
_MTB_CORE__BUILD_SRC_S_FILES  :=$(filter %.$(MTB_RECIPE__SUFFIX_S),$(_MTB_CORE__BUILD_SRC_STRIPPED))
_MTB_CORE__BUILD_SRC_s_FILES  :=$(filter %.$(MTB_RECIPE__SUFFIX_s),$(_MTB_CORE__BUILD_SRC_STRIPPED))
_MTB_CORE__BUILD_SRC_C_FILES  :=$(filter %.$(MTB_RECIPE__SUFFIX_C),$(_MTB_CORE__BUILD_SRC_STRIPPED))
_MTB_CORE__BUILD_SRC_CPP_FILES:=$(filter %.$(MTB_RECIPE__SUFFIX_CPP),$(_MTB_CORE__BUILD_SRC_STRIPPED))
_MTB_CORE__BUILD_SRC_CXX_FILES:=$(filter %.$(MTB_RECIPE__SUFFIX_CXX),$(_MTB_CORE__BUILD_SRC_STRIPPED))
_MTB_CORE__BUILD_SRC_CC_FILES :=$(filter %.$(MTB_RECIPE__SUFFIX_CC),$(_MTB_CORE__BUILD_SRC_STRIPPED))

_MTB_CORE__BUILD_EXTSRC_S_FILES  :=$(filter %.$(MTB_RECIPE__SUFFIX_S),$(_MTB_CORE__BUILD_EXTSRC_RELATIVE_STRIPPED) $(_MTB_CORE__BUILD_EXTSRC_ABSOLUTE_STRIPPED))
_MTB_CORE__BUILD_EXTSRC_s_FILES  :=$(filter %.$(MTB_RECIPE__SUFFIX_s),$(_MTB_CORE__BUILD_EXTSRC_RELATIVE_STRIPPED) $(_MTB_CORE__BUILD_EXTSRC_ABSOLUTE_STRIPPED))
_MTB_CORE__BUILD_EXTSRC_C_FILES  :=$(filter %.$(MTB_RECIPE__SUFFIX_C),$(_MTB_CORE__BUILD_EXTSRC_RELATIVE_STRIPPED) $(_MTB_CORE__BUILD_EXTSRC_ABSOLUTE_STRIPPED))
_MTB_CORE__BUILD_EXTSRC_CPP_FILES:=$(filter %.$(MTB_RECIPE__SUFFIX_CPP),$(_MTB_CORE__BUILD_EXTSRC_RELATIVE_STRIPPED) $(_MTB_CORE__BUILD_EXTSRC_ABSOLUTE_STRIPPED))
_MTB_CORE__BUILD_EXTSRC_CXX_FILES:=$(filter %.$(MTB_RECIPE__SUFFIX_CXX),$(_MTB_CORE__BUILD_EXTSRC_RELATIVE_STRIPPED) $(_MTB_CORE__BUILD_EXTSRC_ABSOLUTE_STRIPPED))
_MTB_CORE__BUILD_EXTSRC_CC_FILES :=$(filter %.$(MTB_RECIPE__SUFFIX_CC),$(_MTB_CORE__BUILD_EXTSRC_RELATIVE_STRIPPED) $(_MTB_CORE__BUILD_EXTSRC_ABSOLUTE_STRIPPED))

_MTB_CORE__BUILD_EXTSRC_CDB_S_FILES  :=$(filter %.$(MTB_RECIPE__SUFFIX_S),$(_MTB_CORE__BUILD_EXTSRC_RELATIVE) $(_MTB_CORE__BUILD_EXTSRC_ABSOLUTE))
_MTB_CORE__BUILD_EXTSRC_CDB_s_FILES  :=$(filter %.$(MTB_RECIPE__SUFFIX_s),$(_MTB_CORE__BUILD_EXTSRC_RELATIVE) $(_MTB_CORE__BUILD_EXTSRC_ABSOLUTE))
_MTB_CORE__BUILD_EXTSRC_CDB_C_FILES  :=$(filter %.$(MTB_RECIPE__SUFFIX_C),$(_MTB_CORE__BUILD_EXTSRC_RELATIVE) $(_MTB_CORE__BUILD_EXTSRC_ABSOLUTE))
_MTB_CORE__BUILD_EXTSRC_CDB_CPP_FILES:=$(filter %.$(MTB_RECIPE__SUFFIX_CPP),$(_MTB_CORE__BUILD_EXTSRC_RELATIVE) $(_MTB_CORE__BUILD_EXTSRC_ABSOLUTE))

#
# The list of object files
#
_MTB_CORE__BUILD_SRC_S_OBJ_FILES:=$(addprefix $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/,$(_MTB_CORE__BUILD_SRC_S_FILES:%.$(MTB_RECIPE__SUFFIX_S)=%.$(MTB_RECIPE__SUFFIX_O)))
_MTB_CORE__BUILD_SRC_s_OBJ_FILES:=$(addprefix $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/,$(_MTB_CORE__BUILD_SRC_s_FILES:%.$(MTB_RECIPE__SUFFIX_s)=%.$(MTB_RECIPE__SUFFIX_O)))
_MTB_CORE__BUILD_SRC_C_OBJ_FILES:=$(addprefix $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/,$(_MTB_CORE__BUILD_SRC_C_FILES:%.$(MTB_RECIPE__SUFFIX_C)=%.$(MTB_RECIPE__SUFFIX_O)))
_MTB_CORE__BUILD_SRC_CPP_OBJ_FILES:=$(addprefix $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/,$(_MTB_CORE__BUILD_SRC_CPP_FILES:%.$(MTB_RECIPE__SUFFIX_CPP)=%.$(MTB_RECIPE__SUFFIX_O)))
_MTB_CORE__BUILD_SRC_CXX_OBJ_FILES:=$(addprefix $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/,$(_MTB_CORE__BUILD_SRC_CXX_FILES:%.$(MTB_RECIPE__SUFFIX_CXX)=%.$(MTB_RECIPE__SUFFIX_O)))
_MTB_CORE__BUILD_SRC_CC_OBJ_FILES:=$(addprefix $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/,$(_MTB_CORE__BUILD_SRC_CC_FILES:%.$(MTB_RECIPE__SUFFIX_CC)=%.$(MTB_RECIPE__SUFFIX_O)))

_MTB_CORE__BUILD_EXTSRC_S_OBJ_FILES:=$(addprefix $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/ext/,$(_MTB_CORE__BUILD_EXTSRC_S_FILES:%.$(MTB_RECIPE__SUFFIX_S)=%.$(MTB_RECIPE__SUFFIX_O)))
_MTB_CORE__BUILD_EXTSRC_s_OBJ_FILES:=$(addprefix $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/ext/,$(_MTB_CORE__BUILD_EXTSRC_s_FILES:%.$(MTB_RECIPE__SUFFIX_s)=%.$(MTB_RECIPE__SUFFIX_O)))
_MTB_CORE__BUILD_EXTSRC_C_OBJ_FILES:=$(addprefix $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/ext/,$(_MTB_CORE__BUILD_EXTSRC_C_FILES:%.$(MTB_RECIPE__SUFFIX_C)=%.$(MTB_RECIPE__SUFFIX_O)))
_MTB_CORE__BUILD_EXTSRC_CPP_OBJ_FILES:=$(addprefix $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/ext/,$(_MTB_CORE__BUILD_EXTSRC_CPP_FILES:%.$(MTB_RECIPE__SUFFIX_CPP)=%.$(MTB_RECIPE__SUFFIX_O)))
_MTB_CORE__BUILD_EXTSRC_CXX_OBJ_FILES:=$(addprefix $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/ext/,$(_MTB_CORE__BUILD_EXTSRC_CXX_FILES:%.$(MTB_RECIPE__SUFFIX_CXX)=%.$(MTB_RECIPE__SUFFIX_O)))
_MTB_CORE__BUILD_EXTSRC_CC_OBJ_FILES:=$(addprefix $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/ext/,$(_MTB_CORE__BUILD_EXTSRC_CC_FILES:%.$(MTB_RECIPE__SUFFIX_CC)=%.$(MTB_RECIPE__SUFFIX_O)))

# All object files from the application
_MTB_CORE__BUILD_ALL_OBJ_FILES:=\
	$(subst //,/,\
	$(_MTB_CORE__BUILD_SRC_S_OBJ_FILES)\
	$(_MTB_CORE__BUILD_SRC_s_OBJ_FILES)\
	$(_MTB_CORE__BUILD_SRC_C_OBJ_FILES)\
	$(_MTB_CORE__BUILD_SRC_CPP_OBJ_FILES)\
	$(_MTB_CORE__BUILD_SRC_CXX_OBJ_FILES)\
	$(_MTB_CORE__BUILD_SRC_CC_OBJ_FILES)\
	$(_MTB_CORE__BUILD_EXTSRC_S_OBJ_FILES)\
	$(_MTB_CORE__BUILD_EXTSRC_s_OBJ_FILES)\
	$(_MTB_CORE__BUILD_EXTSRC_C_OBJ_FILES)\
	$(_MTB_CORE__BUILD_EXTSRC_CPP_OBJ_FILES)\
	$(_MTB_CORE__BUILD_EXTSRC_CXX_OBJ_FILES)\
	$(_MTB_CORE__BUILD_EXTSRC_CC_OBJ_FILES))

#
# Dependency files
#
_MTB_CORE__DEPENDENCY_FILES:=$(_MTB_CORE__BUILD_ALL_OBJ_FILES:%.$(MTB_RECIPE__SUFFIX_O)=%.$(MTB_RECIPE__SUFFIX_D))

#
# Construct the full list of flags
#
_MTB_CORE__BUILD_ALL_ASFLAGS_UC=$(filter-out $(filter-out $(ASFLAGS),$(DISABLE_ASFLAGS)),$(MTB_RECIPE__ASFLAGS) $(MTB_RECIPE__DEFINES))
_MTB_CORE__BUILD_ALL_ASFLAGS_LC=$(filter-out $(filter-out $(ASFLAGS),$(DISABLE_ASFLAGS)),$(MTB_RECIPE__ASFLAGS))
_MTB_CORE__BUILD_ALL_CFLAGS=$(filter-out $(filter-out $(CFLAGS),$(DISABLE_CFLAGS)),$(MTB_RECIPE__CFLAGS) $(MTB_RECIPE__DEFINES))
_MTB_CORE__BUILD_ALL_CXXFLAGS=$(filter-out $(filter-out $(CXXFLAGS),$(DISABLE_CXXFLAGS)),$(MTB_RECIPE__CXXFLAGS) $(MTB_RECIPE__DEFINES))
_MTB_CORE__BUILD_ARFLAGS=$(filter-out $(filter-out $(ARFLAGS),$(DISABLE_ARFLAGS)),$(MTB_RECIPE__ARFLAGS))
_MTB_CORE__BUILD_LDFLAGS=$(filter-out $(filter-out $(LDFLAGS),$(DISABLE_LDFLAGS)),$(MTB_RECIPE__LDFLAGS))

#
# Compiler arguments
#
_MTB_CORE__BUILD_COMPILE_AS_UC=$(AS) $(_MTB_CORE__BUILD_ALL_ASFLAGS_UC) $(MTB_RECIPE__INCRSPFILE_ASM)$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/inclist.rsp $(MTB_RECIPE__OUTPUT_OPTION)
_MTB_CORE__BUILD_COMPILE_AS_LC=$(AS) $(_MTB_CORE__BUILD_ALL_ASFLAGS_LC) $(MTB_RECIPE__INCRSPFILE_ASM)$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/inclist.rsp $(MTB_RECIPE__OUTPUT_OPTION)
# Meant for custom rules. 
_MTB_CORE__BUILD_COMPILE_C=$(CC) $(_MTB_CORE__BUILD_ALL_CFLAGS) $(MTB_RECIPE__INCRSPFILE)$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/inclist.rsp $(MTB_RECIPE__DEPENDENCIES) $(MTB_RECIPE__OUTPUT_OPTION)
_MTB_CORE__BUILD_COMPILE_CPP=$(CXX) $(_MTB_CORE__BUILD_ALL_CXXFLAGS) $(MTB_RECIPE__INCRSPFILE)$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/inclist.rsp $(MTB_RECIPE__DEPENDENCIES) $(MTB_RECIPE__OUTPUT_OPTION)
# Used in mtb_explicit_build_rule. 
_MTB_CORE__BUILD_COMPILE_EXPLICIT_C=$(CC) $(_MTB_CORE__BUILD_ALL_CFLAGS) $(MTB_RECIPE__INCRSPFILE)$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/inclist.rsp $(MTB_RECIPE__EXPLICIT_DEPENDENCIES) $(MTB_RECIPE__OUTPUT_OPTION)
_MTB_CORE__BUILD_COMPILE_EXPLICIT_CPP=$(CXX) $(_MTB_CORE__BUILD_ALL_CXXFLAGS) $(MTB_RECIPE__INCRSPFILE)$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/inclist.rsp $(MTB_RECIPE__EXPLICIT_DEPENDENCIES) $(MTB_RECIPE__OUTPUT_OPTION)

_MTB_CORE__CDB_BUILD_COMPILE_AS_UC=$(AS) $(_MTB_CORE__BUILD_ALL_ASFLAGS_UC) $(MTB_RECIPE__INCLUDES) $(MTB_RECIPE__OUTPUT_OPTION)
_MTB_CORE__CDB_BUILD_COMPILE_AS_LC=$(AS) $(_MTB_CORE__BUILD_ALL_ASFLAGS_LC) $(MTB_RECIPE__INCLUDES) $(MTB_RECIPE__OUTPUT_OPTION)
_MTB_CORE__CDB_BUILD_COMPILE_EXPLICIT_C=$(CC) $(_MTB_CORE__BUILD_ALL_CFLAGS) $(MTB_RECIPE__INCLUDES) $(MTB_RECIPE__OUTPUT_OPTION)
_MTB_CORE__CDB_BUILD_COMPILE_EXPLICIT_CPP=$(CXX) $(_MTB_CORE__BUILD_ALL_CXXFLAGS) $(MTB_RECIPE__INCLUDES) $(MTB_RECIPE__OUTPUT_OPTION)

#
# Linker arguments
# this must use = instead of := since this variable contains $@
#
_MTB_CORE__BUILD_LINK=$(LD) $(_MTB_CORE__BUILD_LDFLAGS) $(MTB_RECIPE__OUTPUT_OPTION) $@ $(MTB_RECIPE__MAPFILE)$(_MTB_CORE__BUILD_MAPFILE) $(MTB_RECIPE__OBJRSPFILE)$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/objlist.rsp $(MTB_RECIPE__STARTGROUP) $(CY_RECIPE_EXTRA_LIBS) $(MTB_RECIPE__LIBS) $(MTB_RECIPE__ENDGROUP)

#
# Archiver arguments
# this must use = instead of := since this variable contains $@
#
ifneq ($(LIBNAME),)
_MTB_CORE__BUILD_ARCHIVE=$(AR) $(_MTB_CORE__BUILD_ARFLAGS) $(MTB_RECIPE__ARCHIVE_LIB_OUTPUT_OPTION) $@ $(MTB_RECIPE__OBJRSPFILE)$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/objlist.rsp
else
_MTB_CORE__BUILD_ARCHIVE=$(AR) $(_MTB_CORE__BUILD_ARFLAGS) $(MTB_RECIPE__OUTPUT_OPTION) $@ $(MTB_RECIPE__OBJRSPFILE)$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/objlist.rsp
endif


################################################################################
# Dependency construction
################################################################################

#
# Dependency variables for compilation
#
_MTB_CORE__BUILD_COMPILER_DEPS=\
	$(_MTB_CORE__BUILD_COMPILE_AS_UC)\
	$(_MTB_CORE__BUILD_COMPILE_AS_LC)\
	$(_MTB_CORE__BUILD_COMPILE_C)\
	$(_MTB_CORE__BUILD_COMPILE_CPP)\
	$(MTB_RECIPE__INCLUDES)

#
# Dependency variables for link/archive
#
_MTB_CORE__BUILD_LINKER_DEPS:=\
	$(_MTB_CORE__BUILD_LINK)\
	$(_MTB_CORE__BUILD_ARCHIVE)

#
# Take care of the quotes and dollar signs for the echo command
#
_MTB_CORE__BUILD_COMPILER_DEPS_FORMATTED=$(subst $,,$(subst ',,$(subst ",,$(_MTB_CORE__BUILD_COMPILER_DEPS))))
_MTB_CORE__BUILD_LINKER_DEPS_FORMATTED=$(subst $,,$(subst ',,$(subst ",,$(_MTB_CORE__BUILD_LINKER_DEPS))))


################################################################################
# Compilation rules construction
################################################################################

# Create explicit rules for auto-discovered (relative path) files
$(foreach explicit,$(_MTB_CORE__BUILD_INTSRC_LIST),$(eval $(call \
mtb_explicit_build_rule,$(explicit),$(patsubst $(MTB_TOOLS__REL_PRJ_PATH)/%,%,$(addsuffix \
.$(MTB_RECIPE__SUFFIX_O),$(basename $(explicit)))),app)))

# Create explicit rules for ext (relative path) files
$(foreach explicit,$(_MTB_CORE__BUILD_EXTSRC_RELATIVE),$(eval $(call \
mtb_explicit_build_rule,$(explicit),$(addprefix ext/,$(patsubst $(MTB_TOOLS__REL_PRJ_PATH)/%,%,$(subst ../,,$(addsuffix \
.$(MTB_RECIPE__SUFFIX_O),$(basename $(explicit)))))),ext)))

# Create explicit rules for ext (absolute path) files
$(foreach explicit,$(_MTB_CORE__BUILD_EXTSRC_ABSOLUTE),$(eval $(call \
mtb_explicit_build_rule,$(explicit),$(addprefix ext/,$(notdir $(addsuffix \
.$(MTB_RECIPE__SUFFIX_O),$(basename $(explicit))))),ext)))

################################################################################
# Link and Postbuild
################################################################################

#
# Dependencies for compilation
#
$(_MTB_CORE__BUILD_ALL_OBJ_FILES): | _mtb_build_precompile
$(_MTB_CORE__BUILD_ALL_OBJ_FILES): $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cycompiler

#
# Dependencies for link
#
$(_MTB_CORE__BUILD_TARGET): | _mtb_build_precompile
$(_MTB_CORE__BUILD_TARGET): $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker

#
# Link/archive the application
#
ifneq ($(LIBNAME),)
$(_MTB_CORE__BUILD_TARGET): $(_MTB_CORE__BUILD_ALL_OBJ_FILES) $(MTB_RECIPE__LIBS)
ifneq ($(strip $(_MTB_CORE__BUILD_ALL_OBJ_FILES) $(MTB_RECIPE__LIBS)),)
	$(info $(MTB__INDENT)Archiving output file $(notdir $@))
	$(MTB__NOISE)$(_MTB_CORE__BUILD_ARCHIVE) $(MTB__SILENT_OUTPUT)
endif
else
$(_MTB_CORE__BUILD_TARGET): $(_MTB_CORE__BUILD_ALL_OBJ_FILES) $(MTB_RECIPE__LIBS) $(call mtb_core__escaped_path,$(MTB_RECIPE__LINKER_SCRIPT))
	$(info $(MTB__INDENT)Linking output file $(notdir $@))
	$(MTB__NOISE)$(_MTB_CORE__BUILD_LINK)
endif

#
# Include generated dependency files (if rebuilding)
#
-include $(_MTB_CORE__DEPENDENCY_FILES)


################################################################################
# build targets
################################################################################

#
# Build multi-core application
#
ifeq ($(MTB_CORE__APPLICATION_BOOTSTRAP),true)
# Need to force the other cores in multi-core to not skip first stage.
build_application_bootstrap:
	$(MTB__NOISE)$(MAKE) -C .. build CY_SECONDSTAGE=
	$(MTB__NOISE)echo;\
	echo "Note: Running the \"build_proj\" target in this sub-project will only build this sub-project, and not the entire application."

qbuild_application_bootstrap:
	$(MTB__NOISE)$(MAKE) -C .. qbuild CY_SECONDSTAGE=
	$(MTB__NOISE)echo;\
	echo "Note: Running the \"qbuild_proj\" target in this sub-project will only build this sub-project, and not the entire application."

build: build_application_bootstrap
qbuild: qbuild_application_bootstrap
else
build: build_proj
qbuild: qbuild_proj
endif

#
# Dependencies
#
build_proj: app memcalc
qbuild_proj: app memcalc
memcalc: app

#
# Print information before we start the build
#
_mtb_build_preprint:
	$(info )
	$(info ==============================================================================)
	$(info = Building application =)
	$(info ==============================================================================)

#
# Create the directories needed to do the build
#
_MTB_CORE__OBJ_FILE_DIRS:=$(sort $(call mtb__get_dir,$(_MTB_CORE__BUILD_ALL_OBJ_FILES)) $(call mtb__get_dir,$(_MTB_CORE__BUILD_TARGET)))
_mtb_build_mkdirs: _mtb_build_preprint
	$(MTB__NOISE)mkdir -p $(_MTB_CORE__OBJ_FILE_DIRS) $(MTB__SILENT_OUTPUT)

#
# Create .cycompiler file
#
$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cycompiler: _mtb_build_mkdirs
	$(call mtb__file_write,$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cycompiler_tmp,$(_MTB_CORE__BUILD_COMPILER_DEPS_FORMATTED))
	$(MTB__NOISE)if ! cmp -s "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cycompiler" "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cycompiler_tmp"; then \
		mv -f "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cycompiler_tmp" "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cycompiler" ; \
	else \
		rm -f "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cycompiler_tmp"; \
	fi

#
# Create .cylinker file
#
$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker: _mtb_build_mkdirs
	$(call mtb__file_write,$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker_tmp,$(_MTB_CORE__BUILD_LINKER_DEPS_FORMATTED) $(_MTB_CORE__BUILD_ALL_OBJ_FILES))
	$(MTB__NOISE)if ! cmp -s "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker" "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker_tmp"; then \
		mv -f "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker_tmp" "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker" ; \
	else \
		rm -f "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker_tmp"; \
	fi

#
# Print before compilation
#
_mtb_build_precompile: _mtb_build_cdb_postprint $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cycompiler $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker $(_MTB_CORE__QBUILD_MK_FILE)
	$(info Building $(words $(_MTB_CORE__BUILD_ALL_OBJ_FILES)) file(s))
	$(call mtb__file_write,$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/inclist.rsp,$(strip $(MTB_RECIPE__INCLUDES)))
	$(call mtb__file_write,$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/objlist.rsp,$(strip $(_MTB_CORE__BUILD_ALL_OBJ_FILES)))

$(info Build rules construction complete)

#
# Generate the compilation database (cdb) file that is used by the .vscode/c_cpp_properties.json file
#
# Note: VSCode .cdb file needs to be known in multiple make files
ifneq ($(CY_BUILD_LOCATION),)
_MTB_CORE__CDB_FILE:=$(MTB_TOOLS__OUTPUT_BASE_DIR)/compile_commands.json
else
_MTB_CORE__CDB_FILE:=./$(notdir $(MTB_TOOLS__OUTPUT_BASE_DIR))/compile_commands.json
endif

$(_MTB_CORE__CDB_FILE)_temp: _mtb_build_mkdirs
	$(info Generating compilation database file...)
	$(info -> $(_MTB_CORE__CDB_FILE))
	$(call mtb__file_write,$@_s_lc,$(call mtb_core__json_escaped_string,$(_MTB_CORE__CDB_BUILD_COMPILE_AS_LC)))
	$(call mtb__file_append,$@_s_lc,$(_MTB_CORE__BUILD_SRC_s_FILES)$(_MTB_CORE__BUILD_EXTSRC_CDB_s_FILES))
	$(call mtb__file_append,$@_s_lc,$(_MTB_CORE__BUILD_SRC_s_OBJ_FILES) $(_MTB_CORE__BUILD_EXTSRC_s_OBJ_FILES))
	$(call mtb__file_write,$@_S_uc,$(call mtb_core__json_escaped_string,$(_MTB_CORE__CDB_BUILD_COMPILE_AS_UC)))
	$(call mtb__file_append,$@_S_uc,$(_MTB_CORE__BUILD_SRC_S_FILES) $(_MTB_CORE__BUILD_EXTSRC_CDB_S_FILES))
	$(call mtb__file_append,$@_S_uc,$(_MTB_CORE__BUILD_SRC_S_OBJ_FILES) $(_MTB_CORE__BUILD_EXTSRC_S_OBJ_FILES))
	$(call mtb__file_write,$@_c,$(call mtb_core__json_escaped_string,$(_MTB_CORE__CDB_BUILD_COMPILE_EXPLICIT_C)))
	$(call mtb__file_append,$@_c,$(_MTB_CORE__BUILD_SRC_C_FILES) $(_MTB_CORE__BUILD_EXTSRC_CDB_C_FILES))
	$(call mtb__file_append,$@_c,$(_MTB_CORE__BUILD_SRC_C_OBJ_FILES) $(_MTB_CORE__BUILD_EXTSRC_C_OBJ_FILES))
	$(call mtb__file_write,$@_cpp,$(call mtb_core__json_escaped_string,$(_MTB_CORE__CDB_BUILD_COMPILE_EXPLICIT_CPP)))
	$(call mtb__file_append,$@_cpp,$(_MTB_CORE__BUILD_SRC_CPP_FILES) $(_MTB_CORE__BUILD_EXTSRC_CDB_CPP_FILES))
	$(call mtb__file_append,$@_cpp,$(_MTB_CORE__BUILD_SRC_CPP_OBJ_FILES) $(_MTB_CORE__BUILD_EXTSRC_CPP_OBJ_FILES))

$(_MTB_CORE__CDB_FILE): $(_MTB_CORE__CDB_FILE)_temp
	$(MTB__NOISE)$(MTB_TOOLS_BASH) $(MTB_TOOLS__CORE_DIR)/make/scripts/gen_compile_commands.bash $@.tmp $(MTB_TOOLS__PRJ_DIR) $<_s_lc $<_S_uc $<_c $<_cpp
	$(MTB__NOISE)mv $@.tmp $@
	$(MTB__NOISE)rm -f $<_s_lc $<_S_uc $<_c $<_cpp

_mtb_build_cdb_postprint: $(_MTB_CORE__CDB_FILE)
	$(info Compilation database file generation complete)

#
# Indicate all phony targets that should be built regardless
#
.PHONY: app build_application_bootstrap qbuild_application_bootstrap
.PHONY: _mtb_build_mkdirs
.PHONY: _mtb_build_preprint
.PHONY: $(_MTB_CORE__CDB_FILE) $(_MTB_CORE__CDB_FILE)_temp
