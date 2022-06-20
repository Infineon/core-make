################################################################################
# \file ide.mk
#
# \brief
# IDE-specific targets and variables
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
# IDE common
################################################################################

#
# Print information before file generation
#
CY_IDE_preprint:
	$(info )
	$(info ==============================================================================)
	$(info = Generating IDE files =)
	$(info ==============================================================================)

$(CY_CONFIG_DIR):
	$(CY_NOISE)mkdir -p $(CY_CONFIG_DIR);

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
_MTB_ECLIPSE_APPLICATION_NAME=$(MTB_APPLICATION_NAME)
else
# in a multi-core application, CY_IDE_PRJNAME is name selected in the project-creator and should only apply to the project
_MTB_ECLIPSE_APPLICATION_NAME=$(CY_IDE_PRJNAME)
endif

# Shared repo vars
CY_IDE_ALL_SEARCHES_QUOTED=$(foreach onedef,$(SEARCH),\"$(onedef)\",)
CY_IDE_SHARED=$(CY_GETLIBS_SHARED)

# DEFINES
CY_IDE_DEFINES=$(subst -D,,$(CY_RECIPE_DEFINES))

# INCLUDES
CY_IDE_INCLUDES=$(subst -I,,$(CY_RECIPE_INCLUDES))

# SOURCES
CY_IDE_SOURCES=$(CY_RECIPE_SOURCE) $(CY_RECIPE_GENERATED) $(SOURCES)
CY_IDE_SOURCES_C=$(filter %.$(CY_TOOLCHAIN_SUFFIX_C),$(CY_IDE_SOURCES))
CY_IDE_SOURCES_CPP=$(filter %.$(CY_TOOLCHAIN_SUFFIX_CPP),$(CY_IDE_SOURCES))
CY_IDE_SOURCES_s=$(filter %.$(CY_TOOLCHAIN_SUFFIX_s),$(CY_IDE_SOURCES))
CY_IDE_SOURCES_S=$(filter %.$(CY_TOOLCHAIN_SUFFIX_S),$(CY_IDE_SOURCES))

# HEADERS
CY_IDE_HEADERS=$(CY_SEACH_APP_HEADERS)

# LIBS
CY_IDE_LIBS=$(CY_RECIPE_LIBS)

# PREBUILD
CY_IDE_PREBUILD_CMD=$(strip $(if $(CY_BSP_PREBUILD),$(CY_BSP_PREBUILD);)\
							$(if $(PREBUILD),$(PREBUILD);)\
							$(if $(CY_RECIPE_PREBUILD),$(CY_RECIPE_PREBUILD);))
CY_IDE_PREBUILD_MSG=$(if $(CY_IDE_PREBUILD_CMD),\
					echo 'Note: Building the application runs the following prebuild operations.\
					You may want to include them as part of the project prebuild step(s):';\
					echo '  $(CY_IDE_PREBUILD_CMD)';)

# POSTBUILD
CY_IDE_POSTBUILD_CMD=$(strip $(if $(CY_RECIPE_POSTBUILD),$(CY_RECIPE_POSTBUILD);)\
							$(if $(CY_BSP_POSTBUILD),$(CY_BSP_POSTBUILD);)\
							$(if $(POSTBUILD),$(POSTBUILD);))
CY_IDE_POSTBUILD_MSG=$(if $(CY_IDE_POSTBUILD_CMD),\
					echo 'Note: Building the application runs the following postbuild operations.\
						You may want to include them as part of the project postbuild step(s):';\
					echo '  $(CY_IDE_POSTBUILD_CMD)';)

################################################################################
# Eclipse
################################################################################

ifeq ($(filter eclipse,$(MAKECMDGOALS)),eclipse)
include $(CY_BASELIB_CORE_PATH)/make/core/eclipse_export.mk
endif # ifeq ($(filter eclipse,$(MAKECMDGOALS)),eclipse)

################################################################################
# IAR
################################################################################

ifeq ($(filter ewarm8,$(MAKECMDGOALS)),ewarm8)

CY_IAR_TEMPFILE=$(CY_CONFIG_DIR)/iardata.temp
CY_IAR_OUTFILE=$(CY_IDE_PRJNAME).ipcf
CY_IAR_CYIGNORE_PATH=$(CY_INTERNAL_APPLOC)/.cyignore
CY_IAR_TEMPLATE_PATH=$(CY_BASELIB_CORE_PATH)/make/scripts/iar
CY_IAR_LINKER_SCRIPT_PATH=$(call CY_MACRO_GET_RAW_PATH,$(LINKER_SCRIPT))

# Note: All paths are expected to be relative of the Makefile(Project Directory)
CY_IAR_DEFINES=$(foreach onedef,$(CY_IDE_DEFINES),\"$(onedef)\",)
CY_IAR_INCLUDES=$(foreach onedef,$(CY_IDE_INCLUDES),\"$(onedef)\",)
CY_IAR_SOURCES_C_CPP=$(foreach onedef,$(CY_IDE_SOURCES_C) $(CY_IDE_SOURCES_CPP),\"$(onedef)\",)
CY_IAR_SOURCES_s_S=$(foreach onedef,$(CY_IDE_SOURCES_s) $(CY_IDE_SOURCES_S),\"$(onedef)\",)
CY_IAR_HEADERS=$(foreach onedef,$(CY_IDE_HEADERS),\"$(onedef)\",)
CY_IAR_LIBS=$(foreach onedef,$(CY_IDE_LIBS),\"$(onedef)\",)

ewarm8: CY_IDE_preprint $(_CY_QBUILD_MK_FILE) $(CY_CONFIG_DIR)
ifneq ($(TOOLCHAIN), IAR)
	$(call CY_MACRO_ERROR,Unable to proceed. TOOLCHAIN must be set to IAR. Use TOOLCHAIN=IAR on the command line, or edit the Makefile)
endif
ifeq ($(CY_IAR_DEVICE_NAME),)
	$(call CY_MACRO_ERROR,Unable to proceed. Export is not supported for this device)
endif
	$(CY_NOISE)echo $(CY_IDE_PRJNAME) > $(CY_IAR_TEMPFILE);\
	echo $(CY_IAR_DEVICE_NAME) >> $(CY_IAR_TEMPFILE);\
	echo $(CORE) >> $(CY_IAR_TEMPFILE);\
	echo '$(CY_IAR_LINKER_SCRIPT_PATH)' >> $(CY_IAR_TEMPFILE);\
	echo $(CY_IAR_DEFINES) >> $(CY_IAR_TEMPFILE);\
	echo $(CY_IAR_INCLUDES) >> $(CY_IAR_TEMPFILE);\
	echo $(CY_IAR_SOURCES_C_CPP) >> $(CY_IAR_TEMPFILE);\
	echo $(CY_IAR_SOURCES_s_S) >> $(CY_IAR_TEMPFILE);\
	echo $(CY_IAR_HEADERS) >> $(CY_IAR_TEMPFILE);\
	echo $(CY_IAR_LIBS) >> $(CY_IAR_TEMPFILE);\
	echo $(CY_IDE_ALL_SEARCHES_QUOTED) >> $(CY_IAR_TEMPFILE);\
	echo $(CY_IDE_SHARED) >> $(CY_IAR_TEMPFILE);\
	echo
	$(CY_NOISE)$(CY_PYTHON_PATH) $(CY_IAR_TEMPLATE_PATH)/iar_export.py -i $(CY_IAR_TEMPFILE) -o $(CY_INTERNAL_APPLOC)/$(CY_IAR_OUTFILE);
	$(CY_NOISE)rm -rf $(CY_IAR_TEMPFILE);\
	echo;\
	echo "Instructions:";\
	echo "1. Open IAR EW for Arm 8.x";\
	echo "2. Project->Create New Project...->Empty project";\
	echo "3. Finish creating the new empty project";\
	echo "4. Project->Add Project Connection...";\
	echo "5. Navigate to the app directory and open the .ipcf";\
	echo ;\
	echo "The following flags will be automatically added to the IAR ewarm project:";\
	echo "C Compiler Flags: $(CY_TOOLCHAIN_CFLAGS)";\
	echo "C++ Compiler Flags: $(CY_TOOLCHAIN_CXXFLAGS)";\
	echo "Assembler Flags: $(CY_TOOLCHAIN_ASFLAGS)";\
	echo "Linker Flags: $(CY_TOOLCHAIN_LDFLAGS)";\
	echo;\
	echo "To add additional build options: See Project->Options->C/C++ Compiler->Extra Options, Project->Options->Assembler->Extra Options, and Project->Options->Linker->Extra Options.";\
	echo;
ifneq ($(CFLAGS)$(CXXFLAGS)$(ASFLAGS)$(LDFLAGS),)
	$(CY_NOISE)echo -e "\033[31mThe following Flags are not automatically added to the IAR ewarm project and must be added manually:\e[0m";
endif
ifneq ($(CFLAGS),)
	$(CY_NOISE)echo -e "\033[31mC Compiler Flags: $(CFLAGS)\e[0m";
endif
ifneq ($(CXXFLAGS),)
	$(CY_NOISE)echo -e "\033[31mC++ Compiler Flags: $(CXXFLAGS)\e[0m";
endif
ifneq ($(ASFLAGS),)
	$(CY_NOISE)echo -e "\033[31mAssembler Flags: $(ASFLAGS)\e[0m";
endif
ifneq ($(LDFLAGS),)
	$(CY_NOISE)echo -e "\033[31mLinker Flags: $(LDFLAGS)\e[0m";
endif
	$(CY_NOISE)echo;\
	$(CY_IDE_PREBUILD_MSG)\
	$(CY_IDE_POSTBUILD_MSG)
ifeq ($(filter FREERTOS,$(COMPONENTS)),FREERTOS)
# Note: If the FreeRTOS-specific flags set in IAR.mk are modified, this section should be updated to reflect the changes.
	$(CY_NOISE)echo;\
	echo "WARNING: Since FreeRTOS is enabled for this project, the compiler and linker settings must be manually updated in IAR EW.";\
	echo "Option 1: Set the project options";\
	echo "    1. Project->Options->General Options->Library Configuration";\
	echo "    2. Set the \"Library:\" dropdown to \"Full\"";\
	echo "    3. Check the box for \"Enable thread support in library\"";\
	echo "    4. Click \"OK\"";\
	echo "Option 2: Set the compiler and linker flags";\
	echo "    1. Project->Options->C/C++ Compiler->Extra Options";\
	echo "    2. Check the box for \"Use command line options\"";\
	echo "    3. Enter \"--dlib_config=full\" in the text box";\
	echo "    4. Project->Options->Linker->Extra Options";\
	echo "    5. Check the box for \"Use command line options\"";\
	echo "    6. Enter \"--threaded_lib\" in the text box";\
	echo "    7. Click \"OK\"";\
	echo;
endif
	$(CY_NOISE)if  [ ! -f $(CY_IAR_CYIGNORE_PATH) ] || ! grep -q 'Debug' $(CY_IAR_CYIGNORE_PATH) || ! grep -q 'Release' $(CY_IAR_CYIGNORE_PATH);\
	then \
		echo;\
		echo Note: Added default IAR-EW output folders \"Debug\" and \"Release\" to $(CY_IAR_CYIGNORE_PATH) file. \
		For custom IAR output directories, manually add them to the $(CY_IAR_CYIGNORE_PATH) file to exclude them from auto-discovery.; \
		echo >> $(CY_IAR_CYIGNORE_PATH);\
		echo "# Automatically added by ewarm8 make target" >> $(CY_IAR_CYIGNORE_PATH);\
		echo "Debug" >> $(CY_IAR_CYIGNORE_PATH);\
		echo "Release" >> $(CY_IAR_CYIGNORE_PATH);\
		echo;\
	fi;

endif #ifeq ($(filter ewarm8,$(MAKECMDGOALS)),ewarm8)


################################################################################
# CMSIS Project Description files (*.cpdsc and *.gpdsc)
################################################################################

ifeq ($(filter uvision5,$(MAKECMDGOALS)),uvision5)

CY_CMSIS_TEMPFILE=$(CY_CONFIG_DIR)/cmsisdata.temp
CY_CMSIS_CPDSC=$(CY_INTERNAL_APPLOC)/$(CY_IDE_PRJNAME).cpdsc
CY_CMSIS_GPDSC=$(CY_INTERNAL_APPLOC)/$(CY_IDE_PRJNAME).gpdsc
CY_CMSIS_CPRJ=$(CY_INTERNAL_APPLOC)/$(CY_IDE_PRJNAME).cprj
CY_CMSIS_CYIGNORE_PATH=$(CY_INTERNAL_APPLOC)/.cyignore
CY_CMSIS_TEMPLATE_PATH=$(CY_BASELIB_CORE_PATH)/make/scripts/cmsis

# All paths are expected to be relative of the Makefile(Project Directory)
CY_CMSIS_DEFINES=$(foreach onedef,$(CY_IDE_DEFINES),\"$(onedef)\",)
CY_CMSIS_INCLUDES=$(foreach onedef,$(CY_IDE_INCLUDES),\"$(onedef)\",)
CY_CMSIS_SOURCES_C_CPP=$(foreach onedef,$(CY_IDE_SOURCES_C) $(CY_IDE_SOURCES_CPP),\"$(onedef)\",)
CY_CMSIS_SOURCES_s_S=$(foreach onedef,$(CY_IDE_SOURCES_s) $(CY_IDE_SOURCES_S),\"$(onedef)\",)
CY_CMSIS_HEADERS=$(foreach onedef,$(CY_IDE_HEADERS),\"$(onedef)\",)
CY_CMSIS_LIBS=$(foreach onedef,$(CY_IDE_LIBS),\"$(onedef)\",)

# For BWC for Cypress recipe that don't define these values
CY_CMSIS_VENDOR_NAME?=Infineon
CY_CMSIS_VENDOR_ID?=7
CY_CMSIS_SPECIFY_CORE?=1

ifeq ($(TOOLCHAIN), GCC_ARM)
CY_MESSAGE_uvision_gcc=WARNING: GCC support in Keil uVision is experimental. To use ARM Compiler 6, run: make uvision5 TOOLCHAIN=ARM.
$(eval $(call CY_MACRO_WARNING,CY_MESSAGE_uvision_gcc,$(CY_MESSAGE_uvision_gcc)))
else ifneq ($(TOOLCHAIN), ARM)
$(call CY_MACRO_ERROR,Unable to proceed. TOOLCHAIN must be set to ARM. Use TOOLCHAIN=ARM on the command line or edit the Makefile)
endif

uvision5: CY_IDE_preprint $(_CY_QBUILD_MK_FILE) $(CY_CONFIG_DIR)
ifeq ($(CY_CMSIS_ARCH_NAME),)
	$(call CY_MACRO_ERROR,Unable to proceed. Export is not supported for this device)
endif
	$(CY_NOISE)echo $(CY_IDE_PRJNAME) > $(CY_CMSIS_TEMPFILE);\
	echo $(DEVICE) >> $(CY_CMSIS_TEMPFILE);\
	echo $(CORE) >> $(CY_CMSIS_TEMPFILE);\
	echo $(LINKER_SCRIPT) >> $(CY_CMSIS_TEMPFILE);\
	echo $(CY_CMSIS_DEFINES) >> $(CY_CMSIS_TEMPFILE);\
	echo $(CY_CMSIS_INCLUDES) >> $(CY_CMSIS_TEMPFILE);\
	echo $(CY_CMSIS_SOURCES_C_CPP) >> $(CY_CMSIS_TEMPFILE);\
	echo $(CY_CMSIS_SOURCES_s_S) >> $(CY_CMSIS_TEMPFILE);\
	echo $(CY_CMSIS_HEADERS) >> $(CY_CMSIS_TEMPFILE);\
	echo $(CY_CMSIS_LIBS) >> $(CY_CMSIS_TEMPFILE);\
	echo $(CY_IDE_ALL_SEARCHES_QUOTED) >> $(CY_CMSIS_TEMPFILE);\
	echo $(CY_IDE_SHARED) >> $(CY_CMSIS_TEMPFILE);\
	echo $(CY_CMSIS_ARCH_NAME) >> $(CY_CMSIS_TEMPFILE);\
	echo $(CY_CMSIS_VENDOR_NAME) >> $(CY_CMSIS_TEMPFILE);\
	echo $(CY_CMSIS_VENDOR_ID) >> $(CY_CMSIS_TEMPFILE);\
	echo $(CY_CMSIS_SPECIFY_CORE) >> $(CY_CMSIS_TEMPFILE);\
	echo
	$(CY_NOISE)$(CY_PYTHON_PATH) $(CY_CMSIS_TEMPLATE_PATH)/cmsis_export.py -i $(CY_CMSIS_TEMPFILE) -cpdsc $(CY_CMSIS_CPDSC) -gpdsc $(CY_CMSIS_GPDSC) -cprj $(CY_CMSIS_CPRJ);
	$(CY_NOISE)rm -rf $(CY_CMSIS_TEMPFILE);\
	echo Keil uVision version \<\= 5.29: double-click the .cpdsc file. The .gpdsc file is loaded automatically.;\
	echo Keil uVision version \>\= 5.30: double-click the .cprj file. The .gpdsc file is loaded automatically.;\
	echo;\
	$(CY_IDE_PREBUILD_MSG)\
	$(CY_IDE_POSTBUILD_MSG)
ifeq ($(TOOLCHAIN), GCC_ARM)
	$(CY_NOISE)echo;\
	echo To switch the project to use GCC toolchain, open Project - Manage - Project Items - Folders/Extensions, and set GCC prefix and path.
endif
	$(CY_NOISE)if  [ ! -f $(CY_CMSIS_CYIGNORE_PATH) ] || ! grep -q "$(CY_IDE_PRJNAME)_build" $(CY_CMSIS_CYIGNORE_PATH) || ! grep -q "RTE" $(CY_CMSIS_CYIGNORE_PATH);\
	then \
		echo;\
		echo Note: Added Keil uVision5 generated folders \"$(CY_IDE_PRJNAME)_build\", \"$(CY_IDE_PRJNAME)_Listings\", \"$(CY_IDE_PRJNAME)_Object\" and \"RTE\" to $(CY_CMSIS_CYIGNORE_PATH) file. \
		For custom output directories, manually add them to the $(CY_CMSIS_CYIGNORE_PATH) file to exclude them from auto-discovery.; \
		echo >> $(CY_CMSIS_CYIGNORE_PATH);\
		echo "# Automatically added by uvision5 make target" >> $(CY_CMSIS_CYIGNORE_PATH);\
		echo "$(CY_IDE_PRJNAME)_build" >> $(CY_CMSIS_CYIGNORE_PATH);\
		echo "$(CY_IDE_PRJNAME)_Listings" >> $(CY_CMSIS_CYIGNORE_PATH);\
		echo "$(CY_IDE_PRJNAME)_Objects" >> $(CY_CMSIS_CYIGNORE_PATH);\
		echo "RTE" >> $(CY_CMSIS_CYIGNORE_PATH);\
	fi;\
	echo;

endif # ifeq ($(filter uvision5,$(MAKECMDGOALS)),uvision5)


################################################################################
# VSCode
################################################################################

ifeq ($(filter vscode,$(MAKECMDGOALS)),vscode)
include $(CY_BASELIB_CORE_PATH)/make/core/vscode_export.mk
endif

#
# Identify the phony targets
#
.PHONY: ewarm8 uvision5 CY_IDE_preprint $(CY_CONFIG_DIR)
