################################################################################
# \file jlink.mk
#
# \brief
# JLink Path handling
#
################################################################################
# \copyright
# Copyright (c) 2018-2026, Infineon Technologies AG, or an affiliate of
# Infineon Technologies AG. All rights reserved.
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

# only look up jlink when its needed, which is anything that isn't a build
ifeq ($(filter $(MAKECMDGOALS),build build_proj qbuild qbuild_proj app),)

# if the MTB_JLINK_DIR is set, just use it
ifneq (,$(MTB_JLINK_DIR))
# if MTB_JLINK_DIR is set, look for the JLinkGDBServerCL.exe (windows) or JLinkGDBServerCLExe (unix) there
MTB_CORE__JLINK_GDB_EXE:=$(wildcard $(call mtb_core__escaped_path,$(MTB_JLINK_DIR))/JLinkGDBServerCL.exe)
ifeq (,$(MTB_CORE__JLINK_GDB_EXE))
MTB_CORE__JLINK_GDB_EXE:=$(wildcard $(call mtb_core__escaped_path,$(MTB_JLINK_DIR))/JLinkGDBServerCLExe)
endif
MTB_CORE__JLINK_EXE:=$(wildcard $(call mtb_core__escaped_path,$(MTB_JLINK_DIR))/JLink.exe)
ifeq (,$(MTB_CORE__JLINK_EXE))
MTB_CORE__JLINK_EXE:=$(wildcard $(call mtb_core__escaped_path,$(MTB_JLINK_DIR))/JLinkExe)
endif
else #(,$(MTB_JLINK_DIR))
# if MTB_JLINK_DIR is not set, look for it in the user PATH env var.

MTB_CORE__JLINK_GDB_EXE:=$(call mtb_core__search_in_path,JLinkGDBServerCL.exe)
ifeq (,$(MTB_CORE__JLINK_GDB_EXE))
MTB_CORE__JLINK_GDB_EXE:=$(call mtb_core__search_in_path,JLinkGDBServerCLExe)
endif

# if MTB_CORE__JLINK_GDB_EXE still not found from PATH, try default locations

ifeq (,$(MTB_CORE__JLINK_GDB_EXE))

# default install path on windows is C:/Program Files/SEGGER/JLink_V<version>, get them all and chose latest
_MTB_CORE__JLINK_WINDOWS_POSSIBLE:=$(lastword $(sort $(filter Files/%,$(wildcard C:/Program\ Files/SEGGER/JLink*))))

# since the sort splits the list on spaces, we end up with Files/SEGGER/JLink_V844a as the lastword, for example
ifeq (,$(_MTB_CORE__JLINK_WINDOWS_POSSIBLE))
# this would have been found by wildcard, but set it so there is something to report/search for
_MTB_CORE__JLINK_DEFAULT_PATH_WINDOWS:=C:/Program Files/SEGGER/JLink
else
_MTB_CORE__JLINK_DEFAULT_PATH_WINDOWS:=C:/Program $(_MTB_CORE__JLINK_WINDOWS_POSSIBLE)
endif

_MTB_CORE__JLINK_DEFAULT_GDB_WINDOWS:=$(_MTB_CORE__JLINK_DEFAULT_PATH_WINDOWS)/JLinkGDBServerCL.exe
_MTB_CORE__JLINK_EXE_DEFAULT_WINDOWS:=$(_MTB_CORE__JLINK_DEFAULT_PATH_WINDOWS)/JLink.exe

# default install path on macos
_MTB_CORE__JLINK_DEFAULT_GDB_OSX:=/Applications/SEGGER/JLink/JLinkGDBServerCLExe
_MTB_CORE__JLINK_EXE_DEFAULT_OSX:=/Applications/SEGGER/JLink/JLinkExe
# There is no default install path on linux, just tgz archive, so its just the name since it will need to be in the path.
_MTB_CORE__JLINK_DEFAULT_GDB_LINUX:=JLinkGDBServerCLExe
_MTB_CORE__JLINK_EXE_DEFAULT_LINUX:=JLinkExe
endif

ifeq (,$(MTB_CORE__JLINK_GDB_EXE))
MTB_CORE__JLINK_GDB_EXE:=$(wildcard $(call mtb_core__escaped_path,$(_MTB_CORE__JLINK_DEFAULT_GDB_WINDOWS)))
ifeq (,$(MTB_CORE__JLINK_GDB_EXE))
MTB_CORE__JLINK_GDB_EXE:=$(wildcard $(call mtb_core__escaped_path,$(_MTB_CORE__JLINK_DEFAULT_GDB_OSX)))
ifeq (,$(MTB_CORE__JLINK_GDB_EXE))
MTB_CORE__JLINK_GDB_EXE:=$(wildcard $(_MTB_CORE__JLINK_DEFAULT_GDB_LINUX))
endif
endif
endif

MTB_CORE__JLINK_EXE:=$(call mtb_core__search_in_path,JLink.exe)
ifeq (,$(MTB_CORE__JLINK_EXE))
MTB_CORE__JLINK_EXE:=$(call mtb_core__search_in_path,JLinkExe)
endif

# if MTB_CORE__JLINK_EXE still not found, try default locations
ifeq (,$(MTB_CORE__JLINK_EXE))
MTB_CORE__JLINK_EXE:=$(wildcard $(call mtb_core__escaped_path,$(_MTB_CORE__JLINK_EXE_DEFAULT_WINDOWS)))
ifeq (,$(MTB_CORE__JLINK_EXE))
MTB_CORE__JLINK_EXE:=$(wildcard $(call mtb_core__escaped_path,$(_MTB_CORE__JLINK_EXE_DEFAULT_OSX)))
ifeq (,$(MTB_CORE__JLINK_EXE))
MTB_CORE__JLINK_EXE:=$(wildcard $(_MTB_CORE__JLINK_EXE_DEFAULT_LINUX))
endif
endif
endif

endif #(,$(JLINK_DIR))
endif #target check

# If JLink executable is not found, it will be set to empty.
