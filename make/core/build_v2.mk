################################################################################
# \file build_v2.mk
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

#
# Prints full/shortened source name
# This can't be set with = since it contains $<
#
ifeq ($(CY_MAKE_IDE),eclipse)
_MTB_CORE__BUILD_COMPILE_PRINT=$< $(MTB_RECIPE__DEFINES) $(MTB_RECIPE__INCLUDES)
else
ifneq (,$(filter $(VERBOSE),true 1))
_MTB_CORE__BUILD_COMPILE_PRINT=$<
else
_MTB_CORE__BUILD_COMPILE_PRINT=$(notdir $<)
endif
endif

################################################################################
# Build arguments
################################################################################

_MTB_CORE__FILTERED_USER_SOURCES:=$(sort $(filter-out $(MTB_RECIPE__SOURCE),$(SOURCES)))

# Still need to generate dependencies manually for manually-specified files in SOURCES.
_mtb_core__ext_sources_to_object=\
		$(patsubst %,$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/external/%.$(MTB_RECIPE__SUFFIX_O),\
		$(subst /./,/,\
		$(subst :,_,\
		$(subst ..,__,\
		$(patsubst ./%,%,\
		$(patsubst /%,%,\
		$1))))))
$(foreach c,$(_MTB_CORE__FILTERED_USER_SOURCES),$(eval $(call _mtb_core__ext_sources_to_object,$(c)): $(c)))
_MTB_CORE__EXT_SOURCES_OBJECT:=$(call _mtb_core__ext_sources_to_object,$(_MTB_CORE__FILTERED_USER_SOURCES))

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
_MTB_CORE__BUILD_COMPILE_C=$(CC) $(_MTB_CORE__BUILD_ALL_CFLAGS) $(MTB_RECIPE__INCRSPFILE)$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/inclist.rsp $(MTB_RECIPE__DEPENDENCIES) $(MTB_RECIPE__OUTPUT_OPTION)
_MTB_CORE__BUILD_COMPILE_CPP=$(CXX) $(_MTB_CORE__BUILD_ALL_CXXFLAGS) $(MTB_RECIPE__INCRSPFILE)$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/inclist.rsp $(MTB_RECIPE__DEPENDENCIES) $(MTB_RECIPE__OUTPUT_OPTION)

_MTB_CORE__CDB_BUILD_COMPILE_AS_UC=$(AS) $(_MTB_CORE__BUILD_ALL_ASFLAGS_UC) $(MTB_RECIPE__INCLUDES) $(MTB_RECIPE__OUTPUT_OPTION)
_MTB_CORE__CDB_BUILD_COMPILE_AS_LC=$(AS) $(_MTB_CORE__BUILD_ALL_ASFLAGS_LC) $(MTB_RECIPE__INCLUDES) $(MTB_RECIPE__OUTPUT_OPTION)
_MTB_CORE__CDB_BUILD_COMPILE_C=$(CC) $(_MTB_CORE__BUILD_ALL_CFLAGS) $(MTB_RECIPE__INCLUDES) $(MTB_RECIPE__OUTPUT_OPTION)
_MTB_CORE__CDB_BUILD_COMPILE_CPP=$(CXX) $(_MTB_CORE__BUILD_ALL_CXXFLAGS) $(MTB_RECIPE__INCLUDES) $(MTB_RECIPE__OUTPUT_OPTION)

#
# compile targets
#

# function to filter-out non-sources files (such as headers) from list of files to pass to the compiler.
_MTB_CORE__ALL_SOURCE_EXT:=$(MTB_RECIPE__SUFFIX_C) $(MTB_RECIPE__SUFFIX_S) $(MTB_RECIPE__SUFFIX_s) $(MTB_RECIPE__SUFFIX_C) $(MTB_RECIPE__SUFFIX_CPP) $(MTB_RECIPE__SUFFIX_CXX) $(MTB_RECIPE__SUFFIX_CC)
_mtb_core__all_source_ext_filter=$(filter $(foreach ext,$(_MTB_CORE__ALL_SOURCE_EXT),%.$(ext)),$1)

$(MTB_TOOLS__OUTPUT_BASE_DIR)/%.$(MTB_RECIPE__SUFFIX_C).$(MTB_RECIPE__SUFFIX_O):
	$(info $(MTB__INDENT)Compiling $(_MTB_CORE__BUILD_COMPILE_PRINT))
	$(MTB__NOISE)$(_MTB_CORE__BUILD_COMPILE_C) $@ $(call mtb_core__abspath,$(call _mtb_core__all_source_ext_filter,$<))

$(MTB_TOOLS__OUTPUT_BASE_DIR)/%.$(MTB_RECIPE__SUFFIX_CPP).$(MTB_RECIPE__SUFFIX_O):
	$(info $(MTB__INDENT)Compiling $(_MTB_CORE__BUILD_COMPILE_PRINT))
	$(MTB__NOISE)$(_MTB_CORE__BUILD_COMPILE_CPP) $@ $(call mtb_core__abspath,$(call _mtb_core__all_source_ext_filter,$<))

$(MTB_TOOLS__OUTPUT_BASE_DIR)/%.$(MTB_RECIPE__SUFFIX_CC).$(MTB_RECIPE__SUFFIX_O):
	$(info $(MTB__INDENT)Compiling $(_MTB_CORE__BUILD_COMPILE_PRINT))
	$(MTB__NOISE)$(_MTB_CORE__BUILD_COMPILE_CPP) $@ $(call mtb_core__abspath,$(call _mtb_core__all_source_ext_filter,$<))

$(MTB_TOOLS__OUTPUT_BASE_DIR)/%.$(MTB_RECIPE__SUFFIX_CXX).$(MTB_RECIPE__SUFFIX_O):
	$(info $(MTB__INDENT)Compiling $(_MTB_CORE__BUILD_COMPILE_PRINT))
	$(MTB__NOISE)$(_MTB_CORE__BUILD_COMPILE_CPP) $@ $(call mtb_core__abspath,$(call _mtb_core__all_source_ext_filter,$<))

$(MTB_TOOLS__OUTPUT_BASE_DIR)/%.$(MTB_RECIPE__SUFFIX_S).$(MTB_RECIPE__SUFFIX_O):
	$(info $(MTB__INDENT)Compiling $(_MTB_CORE__BUILD_COMPILE_PRINT))
	$(MTB__NOISE)$(_MTB_CORE__BUILD_COMPILE_AS_UC) $@ $(call mtb_core__abspath,$(call _mtb_core__all_source_ext_filter,$<))

$(MTB_TOOLS__OUTPUT_BASE_DIR)/%.$(MTB_RECIPE__SUFFIX_s).$(MTB_RECIPE__SUFFIX_O):
	$(info $(MTB__INDENT)Compiling $(_MTB_CORE__BUILD_COMPILE_PRINT))
	$(MTB__NOISE)$(_MTB_CORE__BUILD_COMPILE_AS_LC) $@ $(call mtb_core__abspath,$(call _mtb_core__all_source_ext_filter,$<))

################################################################################
# Linking
################################################################################
#
# Archiver arguments
#
_MTB_CORE__BUILD_ARCHIVE=$(AR) $(_MTB_CORE__BUILD_ARFLAGS) $(MTB_RECIPE__ARCHIVE_LIB_OUTPUT_OPTION) $@ $(MTB_RECIPE__OBJRSPFILE)$@.rsp

#
# Linker arguments
#
_MTB_CORE__BUILD_LINK=$(LD) $(_MTB_CORE__BUILD_LDFLAGS) $(MTB_RECIPE__OUTPUT_OPTION) $@ $(MTB_RECIPE__MAPFILE)$(_MTB_CORE__BUILD_MAPFILE) $(MTB_RECIPE__OBJRSPFILE)$@.rsp $(MTB_RECIPE__STARTGROUP) $(CY_RECIPE_EXTRA_LIBS) $(MTB_RECIPE__LIBS) $(MTB_RECIPE__ENDGROUP)

#
# Link/archive the application
#
ifneq ($(LIBNAME),)
_MTB_CORE__BUILD_TARGET:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(LIBNAME).$(MTB_RECIPE__SUFFIX_A)
else
_MTB_CORE__BUILD_TARGET:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_TARGET)
_MTB_CORE__BUILD_MAPFILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_MAP)
$(_MTB_CORE__BUILD_TARGET): $(call mtb_core__escaped_path,$(MTB_RECIPE__LINKER_SCRIPT))
endif

$(_MTB_CORE__BUILD_TARGET): $(_MTB_CORE__EXT_SOURCES_OBJECT) $(MTB_RECIPE__LIBS) $(MTB_SEARCH_ALL_OBJECTS)

# Order the list of file passed to linker. The .o file need to passed first.
$(MTB_TOOLS__OUTPUT_BASE_DIR)/%.$(MTB_RECIPE__SUFFIX_TARGET):
	$(info $(MTB__INDENT)Linking output file $(notdir $@))
	$(call mtb__file_write,$@.rsp,$(_MTB_CORE__EXT_SOURCES_OBJECT) $(filter %.$(MTB_RECIPE__SUFFIX_O),$(MTB_SEARCH_ALL_OBJECTS)))
	$(MTB__NOISE)$(_MTB_CORE__BUILD_LINK)

# need to do a rm -f $@ for GCC.
# GCC toolchain only support replace parts of existing archiving.
# It does not have an option to overwrite an existing achive.
# This would cause problem is some case like switching toolchains.

$(MTB_TOOLS__OUTPUT_BASE_DIR)/%.$(MTB_RECIPE__SUFFIX_A):
	$(info $(MTB__INDENT)Archiving output file $(notdir $@))
	$(call mtb__file_write,$@.rsp,$(filter-out %.cylinker,$^))
	$(MTB__NOISE)rm -f $@
	$(MTB__NOISE)$(_MTB_CORE__BUILD_ARCHIVE)

################################################################################
# Build targets
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
_MTB_CORE__OBJ_FILE_DIRS:=$(sort $(call mtb__get_dir,$(MTB_CORE__SEARCH_APP_OBJECTS) $(MTB_CORE__SEARCH_APP_LIBS) $(_MTB_CORE__BUILD_TARGET) $(_MTB_CORE__EXT_SOURCES_OBJECT)))
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
	$(call mtb__file_write,$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker_tmp,$(_MTB_CORE__BUILD_LINKER_DEPS_FORMATTED) $(strip $(_MTB_CORE__EXT_SOURCES_OBJECT) $(filter %.$(MTB_RECIPE__SUFFIX_O),$(MTB_SEARCH_ALL_OBJECTS))))
	$(MTB__NOISE)if ! cmp -s "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker" "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker_tmp"; then \
		mv -f "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker_tmp" "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker" ; \
	else \
		rm -f "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker_tmp"; \
	fi

#
# Print before compilation
# Need to continue to generate objlist.rsp for BWC with recipe-make-cat5-1.X
#
_mtb_build_precompile: _mtb_build_cdb_postprint $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cycompiler $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker $(_MTB_CORE__QBUILD_MK_FILE)
	$(info Building $(words $(MTB_CORE__SEARCH_APP_OBJECTS)) file(s))
	$(call mtb__file_write,$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/inclist.rsp,$(strip $(MTB_RECIPE__INCLUDES)))
	$(call mtb__file_write,$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/objlist.rsp,$(strip $(_MTB_CORE__EXT_SOURCES_OBJECT) $(filter %.$(MTB_RECIPE__SUFFIX_O),$(MTB_SEARCH_ALL_OBJECTS))))

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
# Take care of the quotes and dollar signs for the mtb__file_write command. mtb__file_write will properly quote this depending on whether it call echo or the make built-in file functions.
#
_MTB_CORE__BUILD_COMPILER_DEPS_FORMATTED=$(subst $,,$(subst ',,$(subst ",,$(_MTB_CORE__BUILD_COMPILER_DEPS))))
_MTB_CORE__BUILD_LINKER_DEPS_FORMATTED=$(subst $,,$(subst ',,$(subst ",,$(_MTB_CORE__BUILD_LINKER_DEPS))))


# Dependencies for compilation
$(MTB_CORE__SEARCH_APP_OBJECTS) $(_MTB_CORE__EXT_SOURCES_OBJECT): $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cycompiler | _mtb_build_precompile
# Dependencies for archiving
$(MTB_RECIPE__LIBS): $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker | _mtb_build_precompile
# Dependencies for link
$(_MTB_CORE__BUILD_TARGET): $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/.cylinker | _mtb_build_precompile

#
# Include generated dependency files (if rebuilding)
#
_MTB_CORE__DEPENDENCY_FILES:=$(MTB_SEARCH_OBJECTS:%.$(MTB_RECIPE__SUFFIX_O)=%.$(MTB_RECIPE__SUFFIX_D))
-include $(_MTB_CORE__DEPENDENCY_FILES)

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

_MTB_CORE__CDB_s_FILES:=$(filter %.$(MTB_RECIPE__SUFFIX_s),$(_MTB_CORE__FILTERED_USER_SOURCES) $(MTB_SEARCH_SOURCES))
_MTB_CORE__CDB_s_O_FILES:=$(filter %.$(MTB_RECIPE__SUFFIX_s).$(MTB_RECIPE__SUFFIX_O),$(_MTB_CORE__EXT_SOURCES_OBJECT) $(MTB_SEARCH_OBJECTS))
_MTB_CORE__CDB_S_FILES:=$(filter %.$(MTB_RECIPE__SUFFIX_S),$(_MTB_CORE__FILTERED_USER_SOURCES) $(MTB_SEARCH_SOURCES))
_MTB_CORE__CDB_S_O_FILES:=$(filter %.$(MTB_RECIPE__SUFFIX_S).$(MTB_RECIPE__SUFFIX_O),$(_MTB_CORE__EXT_SOURCES_OBJECT) $(MTB_SEARCH_OBJECTS))
_MTB_CORE__CDB_c_FILES:=$(filter %.$(MTB_RECIPE__SUFFIX_C),$(_MTB_CORE__FILTERED_USER_SOURCES) $(MTB_SEARCH_SOURCES))
_MTB_CORE__CDB_c_O_FILES:=$(filter %.$(MTB_RECIPE__SUFFIX_C).$(MTB_RECIPE__SUFFIX_O),$(_MTB_CORE__EXT_SOURCES_OBJECT) $(MTB_SEARCH_OBJECTS))
_MTB_CORE__CDB_cpp_FILES:=$(filter %.$(MTB_RECIPE__SUFFIX_CPP) %.$(MTB_RECIPE__SUFFIX_CC) %.$(MTB_RECIPE__SUFFIX_CXX),$(_MTB_CORE__FILTERED_USER_SOURCES) $(MTB_SEARCH_SOURCES))
_MTB_CORE__CDB_cpp_O_FILES:=$(filter %.$(MTB_RECIPE__SUFFIX_CPP).$(MTB_RECIPE__SUFFIX_O) %.$(MTB_RECIPE__SUFFIX_CC).$(MTB_RECIPE__SUFFIX_O) %.$(MTB_RECIPE__SUFFIX_CXX).$(MTB_RECIPE__SUFFIX_O),$(_MTB_CORE__EXT_SOURCES_OBJECT) $(MTB_SEARCH_OBJECTS))

$(_MTB_CORE__CDB_FILE)_temp: _mtb_build_mkdirs
	$(info Generating compilation database file...)
	$(info -> $(_MTB_CORE__CDB_FILE))
	$(call mtb__file_write,$@_s_lc,$(call mtb_core__json_escaped_string,$(_MTB_CORE__CDB_BUILD_COMPILE_AS_LC)))
	$(call mtb__file_append,$@_s_lc,$(_MTB_CORE__CDB_s_FILES))
	$(call mtb__file_append,$@_s_lc,$(_MTB_CORE__CDB_s_O_FILES))
	$(call mtb__file_write,$@_S_uc,$(call mtb_core__json_escaped_string,$(_MTB_CORE__CDB_BUILD_COMPILE_AS_UC)))
	$(call mtb__file_append,$@_S_uc,$(_MTB_CORE__CDB_S_FILES))
	$(call mtb__file_append,$@_S_uc,$(_MTB_CORE__CDB_S_O_FILES))
	$(call mtb__file_write,$@_c,$(call mtb_core__json_escaped_string,$(_MTB_CORE__CDB_BUILD_COMPILE_C)))
	$(call mtb__file_append,$@_c,$(_MTB_CORE__CDB_c_FILES))
	$(call mtb__file_append,$@_c,$(_MTB_CORE__CDB_c_O_FILES))
	$(call mtb__file_write,$@_cpp,$(call mtb_core__json_escaped_string,$(_MTB_CORE__CDB_BUILD_COMPILE_CPP)))
	$(call mtb__file_append,$@_cpp,$(_MTB_CORE__CDB_cpp_FILES))
	$(call mtb__file_append,$@_cpp,$(_MTB_CORE__CDB_cpp_O_FILES))

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
