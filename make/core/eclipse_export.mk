################################################################################
# \file eclipse_export.mk
#
# \brief
# IDE-specific targets and variables
#
################################################################################
# \copyright
# Copyright 2022 Cypress Semiconductor Corporation
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

ifeq ($(CY_IDE_PRJNAME),)
CY_MESSAGE_prjname=WARNING: No value set for CY_IDE_PRJNAME. APPNAME "$(APPNAME)" will be used instead.\
This may cause launch configurations to not show up if the name Eclipse uses for the project differs.
$(eval $(call CY_MACRO_WARNING,CY_MESSAGE_prjname,$(CY_MESSAGE_prjname)))
endif

_MTB_ECLIPSE_TEMPLATE_PATH=$(CY_BASELIB_CORE_PATH)/make/scripts/eclipse

_MTB_ECLIPSE_TEMPLATE_RECIPE_SEARCH?=$(CY_INTERNAL_BASELIB_PATH)/make/scripts/eclipse/$(MTB_RECIPE_ECLIPSE_TEMPLATE_SUBDIR)
_MTB_ECLIPSE_TEMPLATE_RECIPE_APP_SEARCH?=$(CY_INTERNAL_BASELIB_PATH)/make/scripts/eclipse/Application

_MTB_ECLIPSE_METADATA_FILE=$(CY_CONFIG_DIR)/eclipse_metadata.temp
MTB_CORE_MAKE_ECLIPSE_TEXTDATA_FILE=$(CY_CONFIG_DIR)/eclipse_textdata.temp

# Source files outside of the project directory
_MTB_ECLIPSE_SOURCES_INTERNAL=$(filter-out $(CY_INTERNAL_APPLOC)/% $(CY_APP_LOCATION)/%, $(abspath $(SOURCES)))
_MTB_ECLIPSE_INCLUDES_INTERNAL=$(filter-out $(CY_INTERNAL_APPLOC)/% $(CY_APP_LOCATION)/%, $(abspath $(INCLUDES)))
ifeq ($(OS),Windows_NT)
#prepend an extra '/' on windows because it's a URI.
ifneq ($(CY_WHICH_CYGPATH),)
ifneq ($(_MTB_ECLIPSE_SOURCES_INTERNAL),)
_MTB_ECLIPSE_SOURCES=$(patsubst %/,%,$(shell cygpath -m --absolute $(_MTB_ECLIPSE_SOURCES_INTERNAL)))
ifneq ($(_MTB_ECLIPSE_INCLUDES_INTERNAL),)
_MTB_ECLIPSE_INCLUDES=$(patsubst %/,%,$(shell cygpath -m --absolute $(_MTB_ECLIPSE_INCLUDES_INTERNAL)))
endif
ifneq ($(_MTB_ECLIPSE_EXTAPP_INTERNAL),)
_MTB_ECLIPSE_EXTAPP=$(patsubst %/,%,$(shell cygpath -m --absolute $(_MTB_ECLIPSE_EXTAPP_INTERNAL)))
endif
endif
else
_MTB_ECLIPSE_SOURCES=$(patsubst %/,%,$(_MTB_ECLIPSE_SOURCES_INTERNAL))
_MTB_ECLIPSE_INCLUDES=$(patsubst %/,%,$(_MTB_ECLIPSE_INCLUDES_INTERNAL))
_MTB_ECLIPSE_EXTAPP=$(patsubst %/,%,$(_MTB_ECLIPSE_EXTAPP_INTERNAL))
endif
else
_MTB_ECLIPSE_SOURCES=$(patsubst %/,%,$(_MTB_ECLIPSE_SOURCES_INTERNAL))
_MTB_ECLIPSE_INCLUDES=$(patsubst %/,%,$(_MTB_ECLIPSE_INCLUDES_INTERNAL))
_MTB_ECLIPSE_EXTAPP=$(patsubst %/,%,$(_MTB_ECLIPSE_EXTAPP_INTERNAL))
endif


_MTB_ECLIPSE_INCLUDES+=$(DEPENDENT_APP_PATHS)
_MTB_ECLIPSE_INCLUDES+=$(CY_EXTAPP_PATH)
# Create eclipse project external sources and includes elements

ifeq ($(MTB_TYPE),PROJECT)
ifeq ($(MTB_APPLICATION_SUBPROJECTS),)
# we are directly calling make eclipse from the project. In this case, make eclipse will just call make eclipse on the parent application.
_MTB_ECLIPSE_CALL_APPLICATION_ECLIPSE=true
else
_MTB_ECLIPSE_PROJECT_NAME=$(_MTB_ECLIPSE_APPLICATION_NAME).$(APPNAME)
endif
else #($(MTB_TYPE),PROJECT)
_MTB_ECLIPSE_PROJECT_NAME=$(CY_IDE_PRJNAME)
endif #($(MTB_TYPE),PROJECT)


################################################################################
# vscode targets
################################################################################

ifeq ($(_MTB_ECLIPSE_CALL_APPLICATION_ECLIPSE),true)
# Need to force the other core in multi-core to not skip first stage.
eclipse_application_bootstrap:
	$(CY_NOISE)$(MAKE) -C .. eclipse CY_SECONDSTAGE= CY_PATH_CONVERSION=

eclipse: eclipse_application_bootstrap
else
# Note: MTB_ECLIPSE_TEXT_FILE_CMD is expected to come from the recipe
eclipse: CY_IDE_preprint $(CY_CONFIG_DIR) eclipse_metadata_file eclipse_textdata_file
ifeq ($(MTB_ECLIPSE_TEXT_FILE_CMD),)
	$(call CY_MACRO_ERROR,Unable to proceed. Export is not supported for this device)
endif
ifeq ($(LIBNAME),)
	$(CY_NOISE)$(CY_ECLIPSE_TEMPLATE_PRE_PROCESSING)\
	$(CY_TOOL_mtbideexport_EXE) -ide eclipse -metadata $(_MTB_ECLIPSE_METADATA_FILE) -textdata $(MTB_CORE_MAKE_ECLIPSE_TEXTDATA_FILE);\
	$(CY_ECLIPSE_CLEAN_UP)
else
	@:
endif

eclipse_metadata_file:
	$(CY_NOISE)rm -f $(_MTB_ECLIPSE_METADATA_FILE);\
	echo "MTB_APPLICATION_SUBPROJECTS=$(MTB_APPLICATION_SUBPROJECTS)" >> $(_MTB_ECLIPSE_METADATA_FILE);\
	echo "APPNAME=$(_MTB_ECLIPSE_PROJECT_NAME)" >> $(_MTB_ECLIPSE_METADATA_FILE);\
	echo "MTB_APPLICATION_NAME=$(_MTB_ECLIPSE_APPLICATION_NAME)" >> $(_MTB_ECLIPSE_METADATA_FILE);\
	echo "EXTERNAL_SOURCES=$(_MTB_ECLIPSE_SOURCES)" >> $(_MTB_ECLIPSE_METADATA_FILE);\
	echo "EXTERNAL_INCLUDES=$(strip $(_MTB_ECLIPSE_INCLUDES))" >> $(_MTB_ECLIPSE_METADATA_FILE);\
	echo "SEARCH_DIRS=$(SEARCH)" >> $(_MTB_ECLIPSE_METADATA_FILE);\
	echo "MTB_SHARED_SEARCH=$(CY_IDE_SHARED)" >> $(_MTB_ECLIPSE_METADATA_FILE);\
	echo "PROJECT_TEMPLATE=$(_MTB_ECLIPSE_TEMPLATE_PATH)" >> $(_MTB_ECLIPSE_METADATA_FILE);\
	echo "RECIPE_TEMPLATE=$(_MTB_ECLIPSE_TEMPLATE_RECIPE_SEARCH)" >> $(_MTB_ECLIPSE_METADATA_FILE);\
	echo "RECIPE_APP_TEMPLATE=$(_MTB_ECLIPSE_TEMPLATE_RECIPE_APP_SEARCH)" >> $(_MTB_ECLIPSE_METADATA_FILE);\
	echo "PROTOCOL_VERSION=1" >> $(_MTB_ECLIPSE_METADATA_FILE);\
	echo "PROJECT_UUID=&&PROJECT_UUID&&" >> $(_MTB_ECLIPSE_METADATA_FILE);\
	echo "APPLICATION_UUID=&&APPLICATION_UUID&&" >> $(_MTB_ECLIPSE_METADATA_FILE)

eclipse_textdata_file:
	$(CY_NOISE)rm -f $(MTB_CORE_MAKE_ECLIPSE_TEXTDATA_FILE)
	$(CY_NOISE)$(MTB_ECLIPSE_TEXT_FILE_CMD)

endif #($(_MTB_ECLIPSE_CALL_APPLICATION_ECLIPSE),true)

.PHONY: eclipse eclipse_metadata_file eclipse_textdata_file eclipse_application_bootstrap
