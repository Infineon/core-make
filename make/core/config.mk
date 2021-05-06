################################################################################
# \file config.mk
#
# \brief
# Configurator-related routines
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

#
# Default file extension
#
CY_CONFIG_FILE_EXT?=modus


################################################################################
# Search
################################################################################

CY_CONFIG_FILES_SEARCHES=$(call CY_MACRO_SEARCH,.$(1),$(CY_INTERNAL_APP_PATH))\
					$(if $(CY_INTERNAL_EXTAPP_PATH),$(call CY_MACRO_SEARCH,.$(1),$(CY_INTERNAL_EXTAPP_PATH)))\
					$(if $(SEARCH_LIBS_AND_INCLUDES),$(foreach d,$(SEARCH_LIBS_AND_INCLUDES),$(call CY_MACRO_SEARCH,.$(1),$(d))))\
					$(if $(SEARCH),$(foreach d,$(SEARCH),$(call CY_MACRO_SEARCH,.$(1),$(d))))

CY_CONFIG_MODUS_EXT=modus
CY_CONFIG_CYBT_EXT=cybt
CY_CONFIG_CYUSBDEV_EXT=cyusbdev
CY_CONFIG_MTBEZPD_EXT=mtbezpd
CY_CONFIG_MTBLIN_EXT=mtblin

#
# Search for configuration files and filter
#
CY_CONFIG_MODUS_FILES:=$(call CY_CONFIG_FILES_SEARCHES,$(CY_CONFIG_MODUS_EXT))
CY_CONFIG_CYBT_FILES:=$(call CY_CONFIG_FILES_SEARCHES,$(CY_CONFIG_CYBT_EXT))
CY_CONFIG_CYUSBDEV_FILES:=$(call CY_CONFIG_FILES_SEARCHES,$(CY_CONFIG_CYUSBDEV_EXT))
CY_CONFIG_MTBEZPD_FILES:=$(call CY_CONFIG_FILES_SEARCHES,$(CY_CONFIG_MTBEZPD_EXT))
CY_CONFIG_MTBLIN_FILES:=$(call CY_CONFIG_FILES_SEARCHES,$(CY_CONFIG_MTBLIN_EXT))

CY_SEARCH_PRUNED_MODUS_FILES:=$(filter-out $(foreach d,$(CY_IGNORE_DIRS),$(filter $(d)%,$(CY_CONFIG_MODUS_FILES))),$(CY_CONFIG_MODUS_FILES))
CY_SEARCH_PRUNED_CYBT_FILES:=$(filter-out $(foreach d,$(CY_IGNORE_DIRS),$(filter $(d)%,$(CY_CONFIG_CYBT_FILES))),$(CY_CONFIG_CYBT_FILES))
CY_SEARCH_PRUNED_CYUSBDEV_FILES:=$(filter-out $(foreach d,$(CY_IGNORE_DIRS),$(filter $(d)%,$(CY_CONFIG_CYUSBDEV_FILES))),$(CY_CONFIG_CYUSBDEV_FILES))
CY_SEARCH_PRUNED_MTBEZPD_FILES:=$(filter-out $(foreach d,$(CY_IGNORE_DIRS),$(filter $(d)%,$(CY_CONFIG_MTBEZPD_FILES))),$(CY_CONFIG_MTBEZPD_FILES))
CY_SEARCH_PRUNED_MTBLIN_FILES:=$(filter-out $(foreach d,$(CY_IGNORE_DIRS),$(filter $(d)%,$(CY_CONFIG_MTBLIN_FILES))),$(CY_CONFIG_MTBLIN_FILES))

CY_SEARCH_AVAILABLE_MODUS_SOURCES=$(call CY_MACRO_FILTER_FILES,MODUS)
CY_SEARCH_AVAILABLE_CYBT_SOURCES=$(call CY_MACRO_FILTER_FILES,CYBT)
CY_SEARCH_AVAILABLE_CYUSBDEV_SOURCES=$(call CY_MACRO_FILTER_FILES,CYUSBDEV)
CY_SEARCH_AVAILABLE_MTBEZPD_SOURCES=$(call CY_MACRO_FILTER_FILES,MTBEZPD)
CY_SEARCH_AVAILABLE_MTBLIN_SOURCES=$(call CY_MACRO_FILTER_FILES,MTBLIN)

ifneq ($(words $(CY_SEARCH_AVAILABLE_MODUS_SOURCES)),1)
ifneq ($(words $(CY_SEARCH_AVAILABLE_MODUS_SOURCES)),0)
$(call CY_MACRO_ERROR,Multiple device configuration files detected: $(CY_SEARCH_AVAILABLE_MODUS_SOURCES))
endif
endif

ifneq ($(words $(CY_SEARCH_AVAILABLE_CYBT_SOURCES)),1)
ifneq ($(words $(CY_SEARCH_AVAILABLE_CYBT_SOURCES)),0)
$(call CY_MACRO_ERROR,Multiple BT configuration files detected: $(CY_SEARCH_AVAILABLE_CYBT_SOURCES))
endif
endif

ifneq ($(words $(CY_SEARCH_AVAILABLE_CYUSBDEV_SOURCES)),1)
ifneq ($(words $(CY_SEARCH_AVAILABLE_CYUSBDEV_SOURCES)),0)
$(call CY_MACRO_ERROR,Multiple USBDEV configuration files detected: $(CY_SEARCH_AVAILABLE_CYUSBDEV_SOURCES))
endif
endif

ifneq ($(words $(CY_SEARCH_AVAILABLE_MTBEZPD_SOURCES)),1)
ifneq ($(words $(CY_SEARCH_AVAILABLE_MTBEZPD_SOURCES)),0)
$(call CY_MACRO_ERROR,Multiple MTBEZPD configuration files detected: $(CY_SEARCH_AVAILABLE_MTBEZPD_SOURCES))
endif
endif

ifneq ($(words $(CY_SEARCH_AVAILABLE_MTBLIN_SOURCES)),1)
ifneq ($(words $(CY_SEARCH_AVAILABLE_MTBLIN_SOURCES)),0)
$(call CY_MACRO_ERROR,Multiple LIN configuration files detected: $(CY_SEARCH_AVAILABLE_MTBLIN_SOURCES))
endif
endif


################################################################################
# Arguments constructions
################################################################################

##########################
# .modus (HW)
##########################

CY_CONFIG_MODUS_FILE?=$(CY_SEARCH_AVAILABLE_MODUS_SOURCES)
ifeq ($(CY_CONFIG_MODUS_FILE),)
CY_CONFIG_MODUS_OUTPUT=
CY_OPENOCD_QSPI_CFG_PATH_WITH_FLAG=
CY_OPENOCD_SMIF_LOADER=
CY_OPENOCD_SMIF_LOADER_WITH_FLAG=
else
CY_CONFIG_MODUS_OUTPUT=$(call CY_MACRO_DIR,$(CY_CONFIG_MODUS_FILE))/GeneratedSource
CY_OPENOCD_QSPI_CFG_PATH_WITH_FLAG="-s \\\&quot\\\;$(CY_CONFIG_MODUS_OUTPUT)\\\&quot\\\;\\\&\\\#13\\\;\\\&\\\#10\\\;"
CY_OPENOCD_SMIF_LOADER=set SMIF_LOADER $(CY_INTERNAL_APPLOC)/$(CY_CONFIG_MODUS_OUTPUT)/CYW208xx_SMIF.FLM
CY_OPENOCD_SMIF_LOADER_WITH_FLAG="-c \\\&quot\\\;$(CY_OPENOCD_SMIF_LOADER)\\\&quot\\\;\\\&\\\#13\\\;\\\&\\\#10\\\;"
endif

CY_OPENOCD_QSPI_CFG_PATH=$(CY_CONFIG_MODUS_OUTPUT)

ifeq ($(CY_DEVICESUPPORT_PATH),)
CY_CONFIG_LIBFILE=--library $(CY_DEVICESUPPORT_SEARCH_PATH)
else
CY_CONFIG_LIBFILE=--library $(CY_INTERNAL_DEVICESUPPORT_PATH)/devicesupport.xml
endif

CY_CONFIG_MODUS_EXEC=$(CY_INTERNAL_TOOL_cfg-backend-cli_EXE)
ifneq ($(notdir $(CY_TOOLS_DIR)),tools_2.0)
CY_CONFIG_MODUS_EXEC_FLAGS=\
	$(CY_CONFIG_LIBFILE)\
	--build $(CY_CONFIG_MODUS_FILE)\
	--check-mcu=$(DEVICE)\
	--check-coprocessors=$(subst $(CY_SPACE),$(CY_COMMA),$(ADDITIONAL_DEVICES))
else
CY_CONFIG_MODUS_EXEC_FLAGS=\
	$(CY_CONFIG_LIBFILE)\
	--build $(CY_CONFIG_MODUS_FILE)\
	--set-device=$(subst $(CY_SPACE),$(CY_COMMA),$(DEVICE) $(ADDITIONAL_DEVICES))
endif

CY_CONFIG_MODUS_GUI=$(CY_INTERNAL_TOOL_device-configurator_EXE)

ifneq ($(notdir $(CY_TOOLS_DIR)),tools_2.0)
CY_CONFIG_MODUS_GUI_FLAGS=\
	--design $(CY_CONFIG_MODUS_FILE)\
	--check-mcu=$(DEVICE)\
	--check-coprocessors=$(subst $(CY_SPACE),$(CY_COMMA),$(ADDITIONAL_DEVICES))
else
CY_CONFIG_MODUS_GUI_FLAGS=\
	--design $(CY_CONFIG_MODUS_FILE)
endif

CY_CONFIG_MODUS_RUN_CHECK_DEVICE=

##########################
# .cybt (SW)
##########################

CY_CONFIG_CYBT_FILE?=$(CY_SEARCH_AVAILABLE_CYBT_SOURCES)
CY_CONFIG_CYBT_OUTPUT=$(call CY_MACRO_DIR,$(CY_CONFIG_CYBT_FILE))/GeneratedSource

CY_CONFIG_CYBT_EXEC=$(CY_INTERNAL_TOOL_bt-configurator-cli_EXE)
CY_CONFIG_CYBT_EXEC_FLAGS=\
	--config $(CY_CONFIG_CYBT_FILE)

CY_CONFIG_CYBT_GUI=$(CY_INTERNAL_TOOL_bt-configurator_EXE)
CY_CONFIG_CYBT_GUI_FLAGS=\
	--config

##########################
# .cyusbdev (SW)
##########################

CY_CONFIG_CYUSBDEV_FILE?=$(CY_SEARCH_AVAILABLE_CYUSBDEV_SOURCES)
CY_CONFIG_CYUSBDEV_OUTPUT=$(call CY_MACRO_DIR,$(CY_CONFIG_CYUSBDEV_FILE))/GeneratedSource

CY_CONFIG_CYUSBDEV_EXEC=$(CY_INTERNAL_TOOL_usbdev-configurator-cli_EXE)
CY_CONFIG_CYUSBDEV_EXEC_FLAGS=\
	--config $(CY_CONFIG_CYUSBDEV_FILE)

CY_CONFIG_CYUSBDEV_GUI=$(CY_INTERNAL_TOOL_usbdev-configurator_EXE)
CY_CONFIG_CYUSBDEV_GUI_FLAGS=\
	--config


#########################
# .mtbezpd (SW)
#########################

CY_CONFIG_MTBEZPD_FILE?=$(CY_SEARCH_AVAILABLE_MTBEZPD_SOURCES)
CY_CONFIG_MTBEZPD_OUTPUT=$(call CY_MACRO_DIR,$(CY_CONFIG_MTBEZPD_FILE))/GeneratedSource


CY_CONFIG_MTBEZPD_EXEC=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_ez-pd-configurator-cli_EXE)
CY_CONFIG_MTBEZPD_EXEC_FLAGS=\
	--config $(CY_CONFIG_MTBEZPD_FILE)

CY_CONFIG_MTBEZPD_GUI=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_ez-pd-configurator_EXE)
CY_CONFIG_MTBEZPD_GUI_FLAGS=\
	--config

	
#########################
# .mtblin (SW)
#########################

CY_CONFIG_MTBLIN_FILE?=$(CY_SEARCH_AVAILABLE_MTBLIN_SOURCES)
CY_CONFIG_MTBLIN_OUTPUT=$(call CY_MACRO_DIR,$(CY_CONFIG_MTBLIN_FILE))/GeneratedSource


CY_CONFIG_MTBLIN_EXEC=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_lin-configurator-cli_EXE)
CY_CONFIG_MTBLIN_EXEC_FLAGS=\
	--config $(CY_CONFIG_MTBLIN_FILE)

CY_CONFIG_MTBLIN_GUI=$(CY_INTERNAL_TOOLS)/$(CY_TOOL_lin-configurator_EXE)
CY_CONFIG_MTBLIN_GUI_FLAGS=\
	--config

################################################################################
# Source generation
################################################################################

CY_CONFIG_MODUS_TIMESTAMP=$(CY_CONFIG_MODUS_OUTPUT)/cycfg.timestamp
CY_CONFIG_CYBT_TIMESTAMP=$(CY_CONFIG_CYBT_OUTPUT)/cycfg_bt.timestamp
CY_CONFIG_CYUSBDEV_TIMESTAMP=$(CY_CONFIG_CYUSBDEV_OUTPUT)/cycfg_usbdev.timestamp
CY_CONFIG_MTBEZPD_TIMESTAMP=$(CY_CONFIG_MTBEZPD_OUTPUT)/mtbcfg_ezpd.timestamp
CY_CONFIG_MTBLIN_TIMESTAMP=$(CY_CONFIG_MTBLIN_OUTPUT)/mtbcfg_lin.timestamp

# If design.modus's timestamp is up-to-date run device-configurator with --skip-build to check that
# the device in the design.modus file match the device in makefile
check_device: | $(CY_CONFIG_MODUS_TIMESTAMP)
ifneq ($(notdir $(CY_TOOLS_DIR)),tools_2.0)
ifneq ($(notdir $(CY_TOOLS_DIR)),tools_2.1)
ifneq ($(notdir $(CY_TOOLS_DIR)),tools_2.2)
ifneq ($(CY_CONFIG_MODUS_FILE),)
	$(CY_NOISE)$(CY_CONFIG_MODUS_RUN_CHECK_DEVICE) $(CY_CONFIG_MODUS_EXEC) $(CY_CONFIG_MODUS_EXEC_FLAGS)
endif
endif
endif
endif

gen_config: $(CY_CONFIG_MODUS_TIMESTAMP) $(CY_CONFIG_CYBT_TIMESTAMP) $(CY_CONFIG_CYUSBDEV_TIMESTAMP)\
	$(CY_CONFIG_MTBEZPD_TIMESTAMP) $(CY_CONFIG_MTBLIN_TIMESTAMP) check_device

$(CY_CONFIG_MODUS_TIMESTAMP): $(CY_CONFIG_MODUS_FILE) $(CY_TARGET_MAKEFILE)
ifneq ($(CY_CONFIG_MODUS_FILE),)
	$(info )
	$(info Running device-configurator to update stale files...)
	$(CY_NOISE)$(CY_CONFIG_MODUS_EXEC) $(CY_CONFIG_MODUS_EXEC_FLAGS)
	$(CY_NOISE)echo "-> Generated device configuration file(s) in $(CY_CONFIG_MODUS_OUTPUT)"
	$(eval CY_CONFIG_MODUS_RUN_CHECK_DEVICE=true)
endif

$(CY_CONFIG_CYBT_TIMESTAMP): $(CY_CONFIG_CYBT_FILE)
ifneq ($(CY_CONFIG_CYBT_FILE),)
	$(info )
	$(info Running bt-configurator to update stale files...)
	$(CY_NOISE)$(CY_CONFIG_CYBT_EXEC) $(CY_CONFIG_CYBT_EXEC_FLAGS)
	$(CY_NOISE)echo "-> Generated bt configuration file(s) in $(CY_CONFIG_CYBT_OUTPUT)"
endif

$(CY_CONFIG_CYUSBDEV_TIMESTAMP): $(CY_CONFIG_CYUSBDEV_FILE)
ifneq ($(CY_CONFIG_CYUSBDEV_FILE),)
	$(info )
	$(info Running usbdev-configurator to update stale files...)
	$(CY_NOISE)$(CY_CONFIG_CYUSBDEV_EXEC) $(CY_CONFIG_CYUSBDEV_EXEC_FLAGS)
	$(CY_NOISE)echo "-> Generated usbdev configuration file(s) in $(CY_CONFIG_CYUSBDEV_OUTPUT)"
endif

$(CY_CONFIG_MTBEZPD_TIMESTAMP): $(CY_CONFIG_MTBEZPD_FILE)
ifneq ($(CY_CONFIG_MTBEZPD_FILE),)
	$(info )
	$(info Running ez-pd-configurator to update stale files...)
	$(CY_NOISE)$(CY_CONFIG_MTBEZPD_EXEC) $(CY_CONFIG_MTBEZPD_EXEC_FLAGS)
	$(CY_NOISE)echo "-> Generated ez-pd configuration file(s) in $(CY_CONFIG_MTBEZPD_OUTPUT)"
endif

$(CY_CONFIG_MTBLIN_TIMESTAMP): $(CY_CONFIG_MTBLIN_FILE)
ifneq ($(CY_CONFIG_MTBLIN_FILE),)
	$(info )
	$(info Running lin-configurator to update stale files...)
	$(CY_NOISE)$(CY_CONFIG_MTBLIN_EXEC) $(CY_CONFIG_MTBLIN_EXEC_FLAGS)
	$(CY_NOISE)echo "-> Generated lin configuration file(s) in $(CY_CONFIG_MTBLIN_OUTPUT)"
endif


################################################################################
# Configurator launch
################################################################################

# Extract the names for the variable name construction
CY_CONFIG_CONVERT=$(foreach ext,$(CY_CONFIG_FILE_EXT),$(call CY_MACRO_UC,$(ext)))

# Gather the files. Find all files that match the extensions in the design.modus location
CY_CONFIG_FILES=$(sort $(foreach ext,$(CY_CONFIG_CONVERT),$(CY_CONFIG_$(ext)_FILE))\
				$(foreach ext,$(CY_CONFIG_FILE_EXT),$(wildcard $(call CY_MACRO_DIR,$(CY_CONFIG_MODUS_FILE))/*.$(ext))))

config:
ifeq ($(CY_CONFIG_MODUS_FILE),)
	$(info $(CY_NEWLINE)Could not find any device configuration files)
	$(info Launching device-configurator for a new configuration)
	$(CY_NOISE) $(CY_CONFIG_MODUS_GUI) $(CY_CONFIG_LIBFILE) $(CY_CONFIG_JOB_CONTROL)
else
	$(info $(CY_NEWLINE)Launching device-configurator on $(CY_CONFIG_MODUS_FILE))
	$(CY_NOISE) $(CY_CONFIG_MODUS_GUI) $(CY_CONFIG_LIBFILE) $(CY_CONFIG_MODUS_GUI_FLAGS) $(CY_CONFIG_JOB_CONTROL)
endif

config_bt:
ifeq ($(CY_CONFIG_CYBT_FILE),)
	$(info $(CY_NEWLINE)Could not find any bt-configuration files)
	$(info Launching bt-configurator for a new configuration)
	$(CY_NOISE) $(CY_CONFIG_CYBT_GUI) $(CY_CONFIG_JOB_CONTROL)
else
	$(info $(CY_NEWLINE)Launching bt-configurator on $(CY_CONFIG_CYBT_FILE))
	$(CY_NOISE) $(CY_CONFIG_CYBT_GUI) $(CY_CONFIG_CYBT_GUI_FLAGS) $(CY_CONFIG_CYBT_FILE) $(CY_CONFIG_JOB_CONTROL)
endif

config_usbdev:
ifeq ($(CY_CONFIG_CYUSBDEV_FILE),)
	$(info $(CY_NEWLINE)Could not find any usbdev-configuration files)
	$(info Launching usbdev-configurator for a new configuration)
	$(CY_NOISE) $(CY_CONFIG_CYUSBDEV_GUI) $(CY_CONFIG_JOB_CONTROL)
else
	$(info $(CY_NEWLINE)Launching usbdev-configurator on $(CY_CONFIG_CYUSBDEV_FILE))
	$(CY_NOISE) $(CY_CONFIG_CYUSBDEV_GUI) $(CY_CONFIG_CYUSBDEV_GUI_FLAGS) $(CY_CONFIG_CYUSBDEV_FILE) $(CY_CONFIG_JOB_CONTROL)
endif

CY_CYSECURETOOLS_TARGET=$(shell echo $(TARGET) | tr A-Z a-z)
config_secure:
	$(info $(CY_NEWLINE)Launching secure-policy-configurator on $(CY_INTERNAL_APP_PATH))
	$(CY_NOISE) $(CY_INTERNAL_TOOLS)/$(CY_TOOL_secure-policy-configurator_EXE) --target=$(CY_CYSECURETOOLS_TARGET) $(CY_CONFIG_JOB_CONTROL)

config_ezpd:
ifeq ($(CY_CONFIG_MTBEZPD_FILE),)
	$(info $(CY_NEWLINE)Could not find any ez-pd-configuration files)
	$(info Launching ez-pd-configurator for a new configuration)
	$(CY_NOISE) $(CY_CONFIG_MTBEZPD_GUI) $(CY_CONFIG_JOB_CONTROL)
else
	$(info $(CY_NEWLINE)Launching ez-pd-configurator on $(CY_CONFIG_MTBEZPD_FILE))
	$(CY_NOISE) $(CY_CONFIG_MTBEZPD_GUI) $(CY_CONFIG_MTBEZPD_GUI_FLAGS) $(CY_CONFIG_MTBEZPD_FILE) $(CY_CONFIG_JOB_CONTROL)
endif

config_lin:
ifeq ($(CY_CONFIG_MTBLIN_FILE),)
	$(info $(CY_NEWLINE)Could not find any lin-configuration files)
	$(info Launching lin-configurator for a new configuration)
	$(CY_NOISE) $(CY_CONFIG_MTBLIN_GUI) $(CY_CONFIG_JOB_CONTROL)
else
	$(info $(CY_NEWLINE)Launching lin-configurator on $(CY_CONFIG_MTBLIN_FILE))
	$(CY_NOISE) $(CY_CONFIG_MTBLIN_GUI) $(CY_CONFIG_MTBLIN_GUI_FLAGS) $(CY_CONFIG_MTBLIN_FILE) $(CY_CONFIG_JOB_CONTROL)
endif

online_simulator:
ifeq ($(CY_OPEN_online_simulator_FILE),)
	$(error $(CY_NEWLINE)Infineon simulator not supported for the current device)
else
	$(if $(wildcard $(CY_OPEN_$@_TOOL)),,$(error $(CY_OPEN_online_simulator_TOOL) not found. The online simulator be accessed through the following URL: $(CY_OPEN_online_simulator_FILE_RAW)))
	$(info $(CY_NEWLINE)Opening the infineon online simulator $(CY_OPEN_$@_FILE))
	$(CY_NOISE) $(CY_OPEN_$@_TOOL) $(CY_OPEN_$@_TOOL_FLAGS) $(CY_OPEN_$@_FILE) $(CY_CONFIG_JOB_CONTROL)
endif


.PHONY: gen_config check_device
.PHONY: config config_bt config_usbdev config_secure config_ezpd config_lin
