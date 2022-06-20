################################################################################
# \file bwc.mk
#
# \brief
# Backwards-compatibility variables
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

##########################
# Tool paths
##########################

#
# Special handling for GCC
# 	app makefile - CY_COMPILER_PATH (if selected toolchain is GCC)
# 	startex.mk - CY_COMPILER_DIR
# 	app makefile and again in main.mk if not set - CY_COMPILER_GCC_ARM_DIR
#
ifneq ($(CY_COMPILER_GCC_ARM_DIR),)
CY_INTERNAL_GCC_PATH=$(CY_COMPILER_GCC_ARM_DIR)
CY_USE_CUSTOM_GCC=true
else
CY_INTERNAL_GCC_PATH=$(CY_COMPILER_DIR)
endif

ifeq ($(TOOLCHAIN),GCC_ARM)
ifneq ($(CY_COMPILER_PATH),)
CY_INTERNAL_GCC_PATH=$(CY_COMPILER_PATH)
CY_USE_CUSTOM_GCC=true
endif
endif

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_INTERNAL_TOOL_gcc_BASE:=$(CY_INTERNAL_GCC_PATH)
else
ifneq ($(CY_TOOL_gcc_BASE),)
CY_INTERNAL_TOOL_gcc_BASE:=$(CY_TOOL_gcc_BASE)
else
CY_INTERNAL_TOOL_gcc_BASE:=$(CY_INTERNAL_GCC_PATH)
endif
endif

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_INTERNAL_TOOL_arm-none-eabi-gcc_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-gcc
else
ifneq ($(CY_TOOL_arm-none-eabi-gcc_EXE),)
CY_INTERNAL_TOOL_arm-none-eabi-gcc_EXE:=$(CY_TOOL_arm-none-eabi-gcc_EXE)
else
CY_INTERNAL_TOOL_arm-none-eabi-gcc_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-gcc
endif
endif

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_INTERNAL_TOOL_arm-none-eabi-g++_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-g++
else
ifneq ($(CY_TOOL_arm-none-eabi-g++_EXE),)
CY_INTERNAL_TOOL_arm-none-eabi-g++_EXE:=$(CY_TOOL_arm-none-eabi-g++_EXE)
else
CY_INTERNAL_TOOL_arm-none-eabi-g++_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-g++
endif
endif

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_INTERNAL_TOOL_arm-none-eabi-ar_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-ar
else
ifneq ($(CY_TOOL_arm-none-eabi-ar_EXE),)
CY_INTERNAL_TOOL_arm-none-eabi-ar_EXE:=$(CY_TOOL_arm-none-eabi-ar_EXE)
else
CY_INTERNAL_TOOL_arm-none-eabi-ar_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-ar
endif
endif

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_INTERNAL_TOOL_arm-none-eabi-gdb_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-gdb
else
ifneq ($(CY_TOOL_arm-none-eabi-gdb_EXE),)
CY_INTERNAL_TOOL_arm-none-eabi-gdb_EXE:=$(CY_TOOL_arm-none-eabi-gdb_EXE)
else
CY_INTERNAL_TOOL_arm-none-eabi-gdb_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-gdb
endif
endif

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_INTERNAL_TOOL_arm-none-eabi-objcopy_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-objcopy
else
ifneq ($(CY_TOOL_arm-none-eabi-objcopy_EXE),)
CY_INTERNAL_TOOL_arm-none-eabi-objcopy_EXE:=$(CY_TOOL_arm-none-eabi-objcopy_EXE)
else
CY_INTERNAL_TOOL_arm-none-eabi-objcopy_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-objcopy
endif
endif

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_INTERNAL_TOOL_arm-none-eabi-readelf_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-readelf
else
ifneq ($(CY_TOOL_arm-none-eabi-readelf_EXE),)
CY_INTERNAL_TOOL_arm-none-eabi-readelf_EXE:=$(CY_TOOL_arm-none-eabi-readelf_EXE)
else
CY_INTERNAL_TOOL_arm-none-eabi-readelf_EXE:=$(CY_INTERNAL_GCC_PATH)/bin/arm-none-eabi-readelf
endif
endif

##########################
# Dependent libs
##########################

# Externally use DEPENDENT_LIB_PATHS. Internally use SEARCH_LIBS_AND_INCLUDES to preserve BWC
ifneq ($(DEPENDENT_LIB_PATHS),)
SEARCH_LIBS_AND_INCLUDES+=$(DEPENDENT_LIB_PATHS)
endif

##########################
# Eclipse launch configs
##########################

CY_ECLIPSE_GDB=\$${cy_tools_path:CY_TOOL_arm-none-eabi-gdb_EXE}

# Special case to account for IDE 2.1 + tools 2.2 (or later)
ifeq ($(CY_MAKE_IDE),eclipse)
ifeq ($(CY_MAKE_IDE_VERSION),)
CY_ECLIPSE_GDB=\$${cy_tools_path:gcc\}/bin/arm-none-eabi-gdb
endif
endif

#
# Remove prior to core-make-v3.0.0 release
#
CY_OPEN_device_configurator-cli_TOOL_FLAGS?=--build $(CY_OPEN_device_configurator_FILE) --check-device=$(DEVICE) --check-additional-devices=$(subst $(CY_SPACE),$(CY_COMMA),$(ADDITIONAL_DEVICES)) --readonly
CY_OPEN_device_configurator-cli_TOOL_SKIP_BUILD_FLAGS?=--skip-build
CY_OPEN_device_configurator-cli-TOOL_DEVICE_SUPPORT_FLAGS?=--app-dir $(CY_INTERNAL_APP_PATH)
