################################################################################
# \file ide.mk
#
# \brief
# IDE-specific targets and variables
#
################################################################################
# \copyright
# Copyright 2018-2023 Cypress Semiconductor Corporation
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

##############################################
# General
##############################################

# directory that contains the ide data_files
$(MTB_TOOLS__OUTPUT_CONFIG_DIR):
	$(MTB__NOISE)mkdir -p $(MTB_TOOLS__OUTPUT_CONFIG_DIR);

vscode_generate eclipse_generate uvision5 ewarm8: $(MTB_TOOLS__OUTPUT_CONFIG_DIR)
	$(MTB__NOISE)$(CY_TOOL_mtbideexport_EXE_ABS) -ide $(_MTB_CORE__IDE_EXPORT_TARGET) -export_interface 3.1 $(MTB_CORE__EXPORT_CMDLINE)

.PHONY:vscode eclipse ewarm8 ewarm uvision5 uvision

##############################################
# VSCode Eclipse
##############################################
_MTB_CORE__IDE_TEMPLATE_META_DATA_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/core_ide_template_meta_data.txt
_MTB_CORE__IDE_TEXT_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/core_ide_text.txt
# core-make templates to copy for eclipse and vscode
_MTB_CORE__IDE_TEMPLATE_DIR=$(MTB_TOOLS__CORE_DIR)/make/scripts/interface_version_2

ifeq ($(strip $(filter 3 2 1,$(MTB__MAKE_MAJOR_VER))),)
# --output-sync argument is only supported on GNU make-4.0 or newer
_MTB_CORE__IDE_OUTPUT_SYNC=--output-sync
endif

# generate the compile_commands.json file.
vscode_generate eclipse_generate: _mtb_build_cdb_postprint

##############################################
# VSCode Eclipse Multi-core
##############################################
_MTB_CORE__PRJ_PATH_NAME:=$(notdir $(realpath $(MTB_TOOLS__PRJ_DIR)))
ifeq ($(MTB_TYPE),PROJECT)
ifneq ($(MTB_APPLICATION_SUBPROJECTS),)
_MTB_CORE__IDE_ROOT_DIR=..
ifeq ($(_MTB_CORE__PRJ_PATH_NAME),$(firstword $(MTB_APPLICATION_SUBPROJECTS)))
_MTB_CORE__IDE_IS_FIRST_CORE=1
endif
endif
else #($(MTB_TYPE),PROJECT)
_MTB_CORE__IDE_ROOT_DIR=.
endif #($(MTB_TYPE),PROJECT)

ifeq ($(MTB_CORE__APPLICATION_BOOTSTRAP),true)
# Need to force the other cores in multi-core to not skip first stage.
eclipse_application_bootstrap:
	$(MTB__NOISE)$(MAKE) -C .. eclipse CY_SECONDSTAGE=
vscode_application_bootstrap:
	$(MTB__NOISE)$(MAKE) -C .. vscode CY_SECONDSTAGE=

eclipse: eclipse_application_bootstrap
vscode: vscode_application_bootstrap
.PHONY:eclipse_application_bootstrap vscode_application_bootstrap
else
eclipse: eclipse_generate
vscode: vscode_generate
.PHONY:eclipse_generate vscode_generate
endif #($(MTB_CORE__APPLICATION_BOOTSTRAP),true)

##############################################
# Eclipse
##############################################
_MTB_CORE__IDE_ECLIPSE_META_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/core_ide_eclipse_meta.txt

# If a custom name needs to be provided for the IDE environment it can be specified by
# CY_IDE_PRJNAME. If CY_IDE_PRJNAME was not set on the command line, use APPNAME as the
# default. CY_IDE_PRJNAME can be important in some environments like eclipse where the
# name used within the project is not necessarily what the user created. This can happen
# in Eclipse if there is already a project with the desired name. In this case Eclipse
# will create its own name. That name must still be used for launch configurations instead
# of the name the user actually gave. It can also be necessary when there are multiple
# applications that get created for a single design. In either case we allow a custom name
# to be provided. If one is not provided, we will fallback to the default APPNAME.
ifeq ($(CY_IDE_PRJNAME),)
CY_IDE_PRJNAME=$(APPNAME)
_MTB_ECLIPSE_APPLICATION_NAME:=$(patsubst "%",%,$(MTB_APPLICATION_NAME))
else
# in a multi-core application, CY_IDE_PRJNAME is name selected in the project-creator and should only apply to the project
_MTB_ECLIPSE_APPLICATION_NAME:=$(CY_IDE_PRJNAME)
endif
ifeq ($(MTB_TYPE),PROJECT)
ifneq ($(MTB_APPLICATION_SUBPROJECTS),)
_MTB_ECLIPSE_PROJECT_NAME=$(_MTB_ECLIPSE_APPLICATION_NAME).$(APPNAME)
endif
else #($(MTB_TYPE),PROJECT)
_MTB_ECLIPSE_PROJECT_NAME=$(CY_IDE_PRJNAME)
endif #($(MTB_TYPE),PROJECT)

eclipse_generate: core_eclipse_template_meta_data core_eclipe_meta_data core_eclipe_text_data
eclipse_generate: MTB_CORE__EXPORT_CMDLINE += -metadata $(_MTB_CORE__IDE_TEMPLATE_META_DATA_FILE) -metadata $(_MTB_CORE__IDE_ECLIPSE_META_FILE) -textdata $(_MTB_CORE__IDE_TEXT_FILE)
eclipse_generate: _MTB_CORE__IDE_EXPORT_TARGET = eclipse

core_eclipse_template_meta_data:
	$(call mtb__file_write,$(_MTB_CORE__IDE_TEMPLATE_META_DATA_FILE),EXTERNAL_REF=$(SOURCES) $(INCLUDES) $(SEARCH))
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEMPLATE_META_DATA_FILE),EXTERNAL_REF_KEY=&&LINKED_RESOURCES&&)
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEMPLATE_META_DATA_FILE),MTB_SHARED_DIR=$(patsubst %/,%,$(CY_GETLIBS_SHARED_PATH))/$(CY_GETLIBS_SHARED_NAME))
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_CORE__IDE_TEMPLATE_DIR)/eclipse/project=.)
ifneq (,$(_MTB_CORE__IDE_IS_FIRST_CORE)) # Application level .project file
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_CORE__IDE_TEMPLATE_DIR)/eclipse/application=$(_MTB_CORE__IDE_ROOT_DIR))
endif

core_eclipe_meta_data:
ifneq (,$(_MTB_CORE__IDE_IS_FIRST_CORE))
	$(call mtb__file_write,$(_MTB_CORE__IDE_ECLIPSE_META_FILE),UPDATE_APPLICATION_PREF_FILE=true)
else
	$(call mtb__file_write,$(_MTB_CORE__IDE_ECLIPSE_META_FILE),)
endif

core_eclipe_text_data:
	$(call mtb__file_write,$(_MTB_CORE__IDE_TEXT_FILE),&&APP_NAME&&=$(_MTB_ECLIPSE_APPLICATION_NAME))
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEXT_FILE),&&PRJ_NAME&&=$(_MTB_ECLIPSE_PROJECT_NAME))
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEXT_FILE),&&_MTB_CORE__IDE_OUTPUT_SYNC&&=$(_MTB_CORE__IDE_OUTPUT_SYNC))

.PHONY: core_eclipse_template_meta_data core_eclipe_meta_data core_eclipe_text_data

##############################################
# VSCode
##############################################

# make build -j argument. Default value is 2
_MTB_CORE___VSCODE_BUILD_NUM_PROCESSOR:=2
ifeq ($(OS),Windows_NT)
_MTB_CORE___VSCODE_BUILD_NUM_PROCESSOR:=$(strip $(word 1,$(NUMBER_OF_PROCESSORS) 2))
else
_MTB_CORE__VSCODE_UNAME:=$(shell uname -s)
ifeq ($(_MTB_CORE__VSCODE_UNAME),Linux)
_MTB_CORE___VSCODE_BUILD_NUM_PROCESSOR:=$(shell nproc)
else ifeq ($(_MTB_CORE__VSCODE_UNAME),Darwin)
_MTB_CORE___VSCODE_BUILD_NUM_PROCESSOR:=$(shell sysctl -n hw.logicalcpu)
endif
endif

# Generate the compilation database (cdb) file that is used by the .vscode/c_cpp_properties.json file
ifneq ($(CY_BUILD_LOCATION),)
_MTB_CORE__VSCODE_CDB_FILE:=$(_MTB_CORE__CDB_FILE)
else
_MTB_CORE__VSCODE_CDB_FILE:=$${workspaceFolder}/$(notdir $(MTB_TOOLS__OUTPUT_BASE_DIR))/compile_commands.json
endif

# JLink path
ifneq (,$(MTB_JLINK_DIR))
ifneq (,$(MTB_CORE__JLINK_EXE))
_MTB_RECIPE__VSCODE_JLINK_EXE:=$(MTB_CORE__JLINK_EXE)
endif
endif

vscode_generate: core_vscode_template_meta_data core_vscode_text_data
vscode_generate: MTB_CORE__EXPORT_CMDLINE += -metadata $(_MTB_CORE__IDE_TEMPLATE_META_DATA_FILE) -textdata $(_MTB_CORE__IDE_TEXT_FILE)
vscode_generate: _MTB_CORE__IDE_EXPORT_TARGET = vscode

core_vscode_text_data:
	$(call mtb__file_write,$(_MTB_CORE__IDE_TEXT_FILE),&&_MTB_CORE___VSCODE_BUILD_NUM_PROCESSOR&&=$(_MTB_CORE___VSCODE_BUILD_NUM_PROCESSOR))
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEXT_FILE),&&_MTB_CORE__VSCODE_CDB_FILE&&=$(_MTB_CORE__VSCODE_CDB_FILE))
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEXT_FILE),&&_MTB_RECIPE__VSCODE_JLINK_EXE&&=$(_MTB_RECIPE__VSCODE_JLINK_EXE))
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEXT_FILE),&&_MTB_CORE__VSCODE_COMPILER_PATH&&=$(MTB_TOOLCHAIN_$(TOOLCHAIN)__CC))
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEXT_FILE),&&_MTB_CORE__IDE_OUTPUT_SYNC&&=$(_MTB_CORE__IDE_OUTPUT_SYNC))

core_vscode_template_meta_data:
	$(call mtb__file_write,$(_MTB_CORE__IDE_TEMPLATE_META_DATA_FILE),EXTERNAL_REF=$(SOURCES) $(INCLUDES) $(SEARCH))
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEMPLATE_META_DATA_FILE),EXTERNAL_REF_KEY=&&LINKED_RESOURCES&&)
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEMPLATE_META_DATA_FILE),MTB_SHARED_DIR=$(patsubst %/,%,$(CY_GETLIBS_SHARED_PATH))/$(CY_GETLIBS_SHARED_NAME))
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_CORE__IDE_TEMPLATE_DIR)/vscode/json=.vscode)
ifneq (,$(MTB_APPLICATION_SUBPROJECTS))
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_CORE__IDE_TEMPLATE_DIR)/vscode/json/settings.json=.vscode/settings.json)
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_CORE__IDE_TEMPLATE_DIR)/vscode/json/extensions.json=.vscode/extensions.json)
ifneq (,$(_MTB_CORE__IDE_IS_FIRST_CORE)) # Application level vscode files
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_CORE__IDE_TEMPLATE_DIR)/vscode/json/settings.json=$(_MTB_CORE__IDE_ROOT_DIR)/.vscode/settings.json)
	$(call mtb__file_append,$(_MTB_CORE__IDE_TEMPLATE_META_DATA_FILE),TEMPLATE_REPLACE=$(_MTB_CORE__IDE_TEMPLATE_DIR)/vscode/json/extensions.json=$(_MTB_CORE__IDE_ROOT_DIR)/.vscode/extensions.json)
endif #(,$(_MTB_CORE__IDE_IS_FIRST_CORE))
endif #(,$(MTB_APPLICATION_SUBPROJECTS))

.PHONY: core_vscode_template_meta_data core_vscode_text_data

##############################################
# UV EW
##############################################

_MTB_CORE__IDE_MTB_SHARED=$(patsubst %/,%,$(CY_GETLIBS_SHARED_PATH))/$(patsubst %/,%,$(CY_GETLIBS_SHARED_NAME))
# Generate build data file
_MTB_CORE__IDE_BUILD_DATA_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/core_ide_build_data.txt
_MTB_CORE__CORE_BUILD_DATA_GROUPS:=$(SEARCH) $(foreach d,$(SEARCH_MTB_MK),\
			$(_MTB_CORE__IDE_MTB_SHARED)/$(firstword $(subst /, ,$(patsubst $(_MTB_CORE__IDE_MTB_SHARED)/%,%,$d))))

ewarm8 uvision5: core_ide_build_data
ewarm8 uvision5: MTB_CORE__EXPORT_CMDLINE += -build_data $(_MTB_CORE__IDE_BUILD_DATA_FILE)

# Output INCLUDES and DEFINES using echo so that those will have shell quoting rules.
core_ide_build_data:
	$(call mtb__file_write,$(_MTB_CORE__IDE_BUILD_DATA_FILE),APPNAME=$(CY_IDE_PRJNAME))
	$(call mtb__file_append,$(_MTB_CORE__IDE_BUILD_DATA_FILE),SOURCES=$(MTB_RECIPE__SOURCE) $(SOURCES) $(MTB_RECIPE__LIBS))
	$(call mtb__file_append,$(_MTB_CORE__IDE_BUILD_DATA_FILE),HEADERS=$(_MTB_CORE__SEACH_APP_HEADERS))
	$(shell echo INCLUDES=$(patsubst -I%,%,$(MTB_RECIPE__INCLUDES)) >> $(_MTB_CORE__IDE_BUILD_DATA_FILE))
	$(shell echo DEFINES=$(patsubst -D%,%,$(MTB_RECIPE__DEFINES)) >> $(_MTB_CORE__IDE_BUILD_DATA_FILE))
	$(call mtb__file_append,$(_MTB_CORE__IDE_BUILD_DATA_FILE),CFLAGS=$(CFLAGS))
	$(call mtb__file_append,$(_MTB_CORE__IDE_BUILD_DATA_FILE),CXXFLAGS=$(CXXFLAGS))
	$(call mtb__file_append,$(_MTB_CORE__IDE_BUILD_DATA_FILE),ASFLAGS=$(ASFLAGS))
	$(call mtb__file_append,$(_MTB_CORE__IDE_BUILD_DATA_FILE),LDFLAGS=$(LDFLAGS))
	$(call mtb__file_append,$(_MTB_CORE__IDE_BUILD_DATA_FILE),GROUPS=$(_MTB_CORE__CORE_BUILD_DATA_GROUPS))

.PHONY: core_ide_build_data

##############################################
# UV
##############################################
uvision5: MTB_CORE__EXPORT_CMDLINE += -o $(CY_IDE_PRJNAME).cprj
uvision5: _MTB_CORE__IDE_EXPORT_TARGET = uvision5
uvision5: uvision5_check_toolchain

uvision5_check_toolchain:
ifeq ($(TOOLCHAIN), GCC_ARM)
	$(info WARNING: GCC support in Keil uVision is experimental. To use ARM Compiler 6, run: make uvision5 TOOLCHAIN=ARM.)
else ifneq ($(TOOLCHAIN), ARM)
	$(error Unable to proceed. TOOLCHAIN must be set to ARM. Use TOOLCHAIN=ARM on the command line or edit the Makefile)
endif

##############################################
# EW
##############################################
ewarm8: MTB_CORE__EXPORT_CMDLINE += -o $(CY_IDE_PRJNAME).ipcf
ewarm8: _MTB_CORE__IDE_EXPORT_TARGET = ewarm8

ewarm8: ewarm8_check_toolchain

ewarm8_check_toolchain:
ifneq ($(TOOLCHAIN), IAR)
	$(error Unable to proceed. TOOLCHAIN must be set to IAR. Use TOOLCHAIN=IAR on the command line, or edit the Makefile.)
endif
