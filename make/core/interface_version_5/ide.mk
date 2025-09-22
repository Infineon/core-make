################################################################################
# \file ide.mk
#
# \brief
# IDE-specific targets and variables
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

# Interface version 5 added feature to allow export to UVision and EmbeddedWorkbench to also export a postbuild command.
include $(MTB_TOOLS__CORE_DIR)/make/core/interface_version_4/ide.mk

_MTB_CORE__IDE_PREPOST_BUILD_DATA_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/core_ide_prepost_build_data.txt
ewarm8 uvision5: core_ide_prepost_build_data
ewarm8 uvision5: MTB_CORE__EXPORT_CMDLINE += -build_data $(_MTB_CORE__IDE_PREPOST_BUILD_DATA_FILE)
# Output INCLUDES and DEFINES using echo so that those will have shell quoting rules.
core_ide_prepost_build_data:
	$(call mtb__file_write,$(_MTB_CORE__IDE_PREPOST_BUILD_DATA_FILE))
ifeq (,$(COMBINE_SIGN_JSON))
	$(call mtb__file_append,$(_MTB_CORE__IDE_PREPOST_BUILD_DATA_FILE),POSTBUILD=make ide_postbuild TOOLCHAIN=$(TOOLCHAIN))
else
	$(call mtb__file_append,$(_MTB_CORE__IDE_PREPOST_BUILD_DATA_FILE),POSTBUILD=export MTB_SIGN_COMBINE__SKIP_CHECK=1 && make ide_postbuild TOOLCHAIN=$(TOOLCHAIN) && make sign_combine TOOLCHAIN=$(TOOLCHAIN))
endif
	$(call mtb__file_append,$(_MTB_CORE__IDE_PREPOST_BUILD_DATA_FILE),VCORE_ATTRS=$(VCORE_ATTRS))

_MTB_CORE__IDE_PROJECT_STRUCTURE_DATA_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/core_ide_project_structure_data.txt
ewarm8 uvision5: core_ide_project_structure_data
ewarm8 uvision5: MTB_CORE__EXPORT_CMDLINE += -dfp_data $(_MTB_CORE__IDE_PROJECT_STRUCTURE_DATA_FILE)
core_ide_project_structure_data:
	$(call mtb__file_write,$(_MTB_CORE__IDE_PROJECT_STRUCTURE_DATA_FILE),PRJ_DIR=$(call mtb__path_normalize,.))
ifeq (PROJECT,$(MTB_TYPE))
	$(call mtb__file_append,$(_MTB_CORE__IDE_PROJECT_STRUCTURE_DATA_FILE),APP_DIR=$(call mtb__path_normalize,..))
else
	$(call mtb__file_append,$(_MTB_CORE__IDE_PROJECT_STRUCTURE_DATA_FILE),APP_DIR=$(call mtb__path_normalize,.))
endif
	$(call mtb__file_append,$(_MTB_CORE__IDE_PROJECT_STRUCTURE_DATA_FILE),MTB_TYPE=$(MTB_TYPE))
ifeq (PROJECT,$(MTB_TYPE))
	$(call mtb__file_append,$(_MTB_CORE__IDE_PROJECT_STRUCTURE_DATA_FILE),MTB_APPLICATION_SUBPROJECTS=$(MTB_APPLICATION_SUBPROJECTS))
else
	$(call mtb__file_append,$(_MTB_CORE__IDE_PROJECT_STRUCTURE_DATA_FILE),MTB_APPLICATION_SUBPROJECTS=$(_MTB_CORE__PRJ_PATH_NAME))
endif

.PHONY: core_ide_prepost_build_data core_ide_project_structure_data
