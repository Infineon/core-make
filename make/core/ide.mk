################################################################################
# \file ide.mk
#
# \brief
# IDE-specific targets and variables
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
ifeq ($(filter eclipse,$(MAKECMDGOALS)),eclipse)
CY_MESSAGE_prjname=WARNING: No value set for CY_IDE_PRJNAME. APPNAME "$(APPNAME)" will be used instead.\
This may cause launch configurations to not show up if the name Eclipse uses for the project differs.
$(eval $(call CY_MACRO_WARNING,CY_MESSAGE_prjname,$(CY_MESSAGE_prjname)))
endif
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
CY_IDE_HEADERS=$(sort $(call CY_MACRO_FILTER_FILES,H) $(call CY_MACRO_FILTER_FILES,HPP))

# LIBS
CY_IDE_LIBS=$(CY_RECIPE_LIBS)


################################################################################
# Eclipse
################################################################################

ifeq ($(filter eclipse,$(MAKECMDGOALS)),eclipse)

CY_ECLIPSE_OUT_PATH=$(CY_INTERNAL_APP_PATH)/.mtbLaunchConfigs
CY_ECLIPSE_TEMPLATE_PATH=$(CY_INTERNAL_BASELIB_PATH)/make/scripts/eclipse
CY_ECLIPSE_LAUNCH_TEMPFILE=$(CY_CONFIG_DIR)/eclipse_launch.temp
CY_ECLIPSE_PROJECT_TEMPFILE=$(CY_CONFIG_DIR)/eclipse_project.temp
CY_ECLIPSE_TEMPLATES_WILDCARD?=*

ifneq ($(wildcard $(CY_INTERNAL_APP_PATH)/.cproject),)
ifneq ($(wildcard $(CY_INTERNAL_APP_PATH)/.project),)
CY_ECLIPSE_SKIP_PRJ=true
CY_MESSAGE_eclipse_prj=INFO: Eclipse project files ".cproject" and ".project" already exist. \
Skipping project generation...
$(eval $(call CY_MACRO_INFO,CY_MESSAGE_eclipse_prj,$(CY_MESSAGE_eclipse_prj)))
endif
endif
# Project generation should be skipped when called from the IDE
ifeq ($(CY_MAKE_IDE),eclipse)
CY_ECLIPSE_SKIP_PRJ=true
endif

# Avoid project generation code if not needed
ifneq ($(CY_ECLIPSE_SKIP_PRJ),true)

# Source files outside of the project directory
CY_ECLIPSE_SOURCES_INTERNAL=$(filter-out $(CY_INTERNAL_APPLOC)/% $(CY_APP_LOCATION)/%, $(abspath $(SOURCES)))
ifeq ($(OS),Windows_NT)
#prepend an extra '/' on windows because it's a URI.
ifneq ($(CY_WHICH_CYGPATH),)
ifneq ($(CY_ECLIPSE_SOURCES_INTERNAL),)
CY_ECLIPSE_SOURCES=$(patsubst %, /%, $(shell cygpath -m --absolute $(CY_ECLIPSE_SOURCES_INTERNAL)))
endif
else
CY_ECLIPSE_SOURCES=$(patsubst %, /%, $(CY_ECLIPSE_SOURCES_INTERNAL))
endif
else
CY_ECLIPSE_SOURCES=$(CY_ECLIPSE_SOURCES_INTERNAL)
endif

# Include paths outside of the project directory
CY_ECLIPSE_INCLUDES_INTERNAL=$(filter-out $(CY_INTERNAL_APPLOC) $(CY_INTERNAL_APPLOC)/% $(CY_APP_LOCATION) $(CY_APP_LOCATION)/%, $(abspath $(INCLUDES)))
ifeq ($(OS),Windows_NT)
#prepend an extra '/' on windows because it's a URI.
ifneq ($(CY_WHICH_CYGPATH),)
ifneq ($(CY_ECLIPSE_INCLUDES_INTERNAL),)
CY_ECLIPSE_INCLUDES=$(patsubst %, /%, $(shell cygpath -m --absolute $(CY_ECLIPSE_INCLUDES_INTERNAL)))
endif
else
CY_ECLIPSE_INCLUDES=$(patsubst %, /%, $(CY_ECLIPSE_INCLUDES_INTERNAL))
endif
else
CY_ECLIPSE_INCLUDES=$(CY_ECLIPSE_INCLUDES_INTERNAL)
endif

# Eclipse knows to include everything under the CY_INTERNAL_EXTAPP_PATH
CY_ECLIPSE_EXTAPP_INTERNAL=$(filter-out $(CY_INTERNAL_APPLOC) $(CY_INTERNAL_APPLOC)/% $(CY_APP_LOCATION) $(CY_APP_LOCATION)/%, $(abspath $(CY_INTERNAL_EXTAPP_PATH)))
ifeq ($(OS),Windows_NT)
#prepend an extra '/' on windows because it's a URI.
ifneq ($(CY_WHICH_CYGPATH),)
ifneq ($(CY_ECLIPSE_EXTAPP_INTERNAL),)
CY_ECLIPSE_EXTAPP=$(patsubst %, /%, $(shell cygpath -m --absolute $(CY_ECLIPSE_EXTAPP_INTERNAL)))
endif
else
CY_ECLIPSE_EXTAPP=$(patsubst %, /%, $(CY_ECLIPSE_EXTAPP_INTERNAL))
endif
else
CY_ECLIPSE_EXTAPP=$(CY_ECLIPSE_EXTAPP_INTERNAL)
endif

# Create eclipse project external sources and includes elements
CY_ECLIPSE_PROJECT_SOURCES=$(foreach item,$(CY_ECLIPSE_SOURCES),\"$(item)\",)
CY_ECLIPSE_PROJECT_INCLUDES=$(foreach item,$(CY_ECLIPSE_INCLUDES),\"$(item)\",)
CY_ECLIPSE_PROJECT_EXTAPP=$(foreach item,$(CY_ECLIPSE_EXTAPP),\"$(item)\",)

endif #ifneq ($(CY_ECLIPSE_SKIP_PRJ),true)

# Note: CY_ECLIPSE_ARGS is expected to come from the recipe
eclipse: CY_IDE_preprint
ifeq ($(LIBNAME),)
# Generate launch configurations
	$(CY_NOISE)mkdir -p $(CY_CONFIG_DIR);\
	mkdir -p $(CY_ECLIPSE_OUT_PATH);\
	echo $(CY_ECLIPSE_ARGS) > $(CY_ECLIPSE_LAUNCH_TEMPFILE);\
	for launch in $(CY_ECLIPSE_TEMPLATE_PATH)/$(CY_ECLIPSE_TEMPLATES_WILDCARD); do\
		if [[ $$launch == *"project" ]]; then\
			continue;\
		fi;\
		launchFile="$${launch##*/}";\
		launchFileName="$${launchFile%.*}";\
		sed -f $(CY_ECLIPSE_LAUNCH_TEMPFILE) "$$launch" > "$(CY_ECLIPSE_OUT_PATH)/$(CY_IDE_PRJNAME) $$launchFileName.launch";\
		launchConfigs="$$launchConfigs \"$(CY_IDE_PRJNAME) $$launchFileName.launch"\";\
	done;\
	rm -f $(CY_ECLIPSE_LAUNCH_TEMPFILE);\
	echo;\
	echo Generated Eclipse launch config files: "$$launchConfigs"
ifneq ($(CY_ECLIPSE_SKIP_PRJ),true)
# Generate .project and .cproject files
	$(CY_NOISE)cp -rf $(CY_ECLIPSE_TEMPLATE_PATH)/project/.cproject $(CY_INTERNAL_APP_PATH);\
	echo $(CY_IDE_PRJNAME) > $(CY_ECLIPSE_PROJECT_TEMPFILE);\
	echo $(CY_ECLIPSE_PROJECT_SOURCES) >> $(CY_ECLIPSE_PROJECT_TEMPFILE);\
	echo $(CY_ECLIPSE_PROJECT_INCLUDES) >> $(CY_ECLIPSE_PROJECT_TEMPFILE);\
	echo $(CY_ECLIPSE_PROJECT_EXTAPP) >> $(CY_ECLIPSE_PROJECT_TEMPFILE);\
	echo $(CY_IDE_ALL_SEARCHES_QUOTED) >> $(CY_ECLIPSE_PROJECT_TEMPFILE);\
	echo $(CY_IDE_SHARED) >> $(CY_ECLIPSE_PROJECT_TEMPFILE);\
	echo
	$(CY_NOISE)$(CY_PYTHON_PATH) $(CY_INTERNAL_BASELIB_PATH)/make/scripts/eclipse/eclipse_export.py -i $(CY_ECLIPSE_PROJECT_TEMPFILE) -p $(CY_ECLIPSE_TEMPLATE_PATH)/project/.project -o $(CY_INTERNAL_APP_PATH)/.project;
	$(CY_NOISE)rm -f $(CY_ECLIPSE_PROJECT_TEMPFILE);\
	echo;\
	echo Generated Eclipse project files: ".project .cproject";\
	echo;\
	echo "Instructions:";\
	echo "1. Open Eclipse IDE for ModusToolbox";\
	echo "2. File->Open Projects from File System";\
	echo "3. Import source - Select the directory of the app and click Finish";\
	echo;
endif
else
	@:
endif

endif # ifeq ($(filter eclipse,$(MAKECMDGOALS)),eclipse)

################################################################################
# IAR
################################################################################

ifeq ($(filter ewarm8,$(MAKECMDGOALS)),ewarm8)

CY_IAR_TEMPFILE=$(CY_CONFIG_DIR)/iardata.temp
CY_IAR_OUTFILE=$(CY_IDE_PRJNAME).ipcf
CY_IAR_CYIGNORE_PATH=$(CY_INTERNAL_APP_PATH)/.cyignore

# Note: All paths are expected to be relative of the Makefile(Project Directory)
CY_IAR_DEFINES=$(foreach onedef,$(CY_IDE_DEFINES),\"$(onedef)\",)
CY_IAR_INCLUDES=$(foreach onedef,$(CY_IDE_INCLUDES),\"$(onedef)\",)
CY_IAR_SOURCES_C_CPP=$(foreach onedef,$(CY_IDE_SOURCES_C) $(CY_IDE_SOURCES_CPP),\"$(onedef)\",)
CY_IAR_SOURCES_s_S=$(foreach onedef,$(CY_IDE_SOURCES_s) $(CY_IDE_SOURCES_S),\"$(onedef)\",)
CY_IAR_HEADERS=$(foreach onedef,$(CY_IDE_HEADERS),\"$(onedef)\",)
CY_IAR_LIBS=$(foreach onedef,$(CY_IDE_LIBS),\"$(onedef)\",)

ewarm8: CY_IDE_preprint
ifneq ($(TOOLCHAIN), IAR)
	$(call CY_MACRO_ERROR,Unable to proceed. TOOLCHAIN must be set to IAR. Use TOOLCHAIN=IAR on the command line, or edit the Makefile)
endif
ifeq ($(CY_IAR_DEVICE_NAME),)
	$(call CY_MACRO_ERROR,Unable to proceed. Export not supported for this device)
endif
	$(CY_NOISE)mkdir -p $(CY_CONFIG_DIR);\
	echo $(CY_IDE_PRJNAME) > $(CY_IAR_TEMPFILE);\
	echo $(CY_IAR_DEVICE_NAME) >> $(CY_IAR_TEMPFILE);\
	echo $(CORE) >> $(CY_IAR_TEMPFILE);\
	echo $(LINKER_SCRIPT) >> $(CY_IAR_TEMPFILE);\
	echo $(CY_IAR_DEFINES) >> $(CY_IAR_TEMPFILE);\
	echo $(CY_IAR_INCLUDES) >> $(CY_IAR_TEMPFILE);\
	echo $(CY_IAR_SOURCES_C_CPP) >> $(CY_IAR_TEMPFILE);\
	echo $(CY_IAR_SOURCES_s_S) >> $(CY_IAR_TEMPFILE);\
	echo $(CY_IAR_HEADERS) >> $(CY_IAR_TEMPFILE);\
	echo $(CY_IAR_LIBS) >> $(CY_IAR_TEMPFILE);\
	echo $(CY_IDE_ALL_SEARCHES_QUOTED) >> $(CY_IAR_TEMPFILE);\
	echo $(CY_IDE_SHARED) >> $(CY_IAR_TEMPFILE);\
	echo
	$(CY_NOISE)$(CY_PYTHON_PATH) $(CY_INTERNAL_BASELIB_PATH)/make/scripts/iar/iar_export.py -i $(CY_IAR_TEMPFILE) -o $(CY_IAR_OUTFILE);
	$(CY_NOISE)rm -rf $(CY_IAR_TEMPFILE);\
	echo;\
	echo "Instructions:";\
	echo "1. Open IAR EW for Arm 8.x";\
	echo "2. Project->Create New Project...->Empty project";\
	echo "3. Finish creating the new empty project";\
	echo "4. Project->Add Project Connection...";\
	echo "5. Navigate to the app directory and open the .ipcf";\
	echo;\
	echo "Note: Custom compiler, assembler, and linker flags are not exported.  If you wish to include any flag that is not set by default in the IAR EW project options, it must be added manually.";\
	echo "See Project->Options->C/C++ Compiler->Extra Options, Project->Options->Assembler->Extra Options, and Project->Options->Linker->Extra Options.";\
	echo;\
	echo "The current flags for this project are the following:";\
	echo "C Compiler Flags: $(CY_TOOLCHAIN_CFLAGS)";\
	echo "C++ Compiler Flags: $(CY_TOOLCHAIN_CXXFLAGS)";\
	echo "Assembler Flags: $(CY_TOOLCHAIN_ASFLAGS)";\
	echo "Linker Flags: $(CY_TOOLCHAIN_LDFLAGS)";\
	echo;
ifeq ($(filter FREERTOS,$(COMPONENTS)),FREERTOS)
	# Note: If the FreeRTOS-specific flags set in IAR.mk are modified, this section should be updated to reflect the changes.
	$(CY_NOISE)echo "WARNING: Since FreeRTOS is enabled for this project, the compiler and linker settings must be manually updated in IAR EW.";\
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
	echo "    2. Check the box for \"Use command line options\"";\
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
CY_CMSIS_CPDSC=$(CY_IDE_PRJNAME).cpdsc
CY_CMSIS_GPDSC=$(CY_IDE_PRJNAME).gpdsc
CY_CMSIS_CPRJ=$(CY_IDE_PRJNAME).cprj
CY_CMSIS_CYIGNORE_PATH=$(CY_INTERNAL_APP_PATH)/.cyignore

# All paths are expected to be relative of the Makefile(Project Directory)
CY_CMSIS_DEFINES=$(foreach onedef,$(CY_IDE_DEFINES),\"$(onedef)\",)
CY_CMSIS_INCLUDES=$(foreach onedef,$(CY_IDE_INCLUDES),\"$(onedef)\",)
CY_CMSIS_SOURCES_C_CPP=$(foreach onedef,$(CY_IDE_SOURCES_C) $(CY_IDE_SOURCES_CPP),\"$(onedef)\",)
CY_CMSIS_SOURCES_s_S=$(foreach onedef,$(CY_IDE_SOURCES_s) $(CY_IDE_SOURCES_S),\"$(onedef)\",)
CY_CMSIS_HEADERS=$(foreach onedef,$(CY_IDE_HEADERS),\"$(onedef)\",)
CY_CMSIS_LIBS=$(foreach onedef,$(CY_IDE_LIBS),\"$(onedef)\",)

ifeq ($(TOOLCHAIN), GCC_ARM)
CY_MESSAGE_uvision_gcc=WARNING: GCC support in Keil uVision is experimental. To use ARM Compiler 6, run: make uvision5 TOOLCHAIN=ARM.
$(eval $(call CY_MACRO_WARNING,CY_MESSAGE_uvision_gcc,$(CY_MESSAGE_uvision_gcc)))
else ifneq ($(TOOLCHAIN), ARM)
$(call CY_MACRO_ERROR,Unable to proceed. TOOLCHAIN must be set to ARM. Use TOOLCHAIN=ARM on the command line or edit the Makefile)
endif

uvision5: CY_IDE_preprint
	$(CY_NOISE)mkdir -p $(CY_CONFIG_DIR);\
	echo $(CY_IDE_PRJNAME) > $(CY_CMSIS_TEMPFILE);\
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
	echo
	$(CY_NOISE)$(CY_PYTHON_PATH) $(CY_INTERNAL_BASELIB_PATH)/make/scripts/cmsis/cmsis_export.py -i $(CY_CMSIS_TEMPFILE) -cpdsc $(CY_CMSIS_CPDSC) -gpdsc $(CY_CMSIS_GPDSC) -cprj $(CY_CMSIS_CPRJ);
	$(CY_NOISE)rm -rf $(CY_CMSIS_TEMPFILE);\
	echo Keil uVision version \<\= 5.29: double-click the .cpdsc file. The .gpdsc file is loaded automatically.;\
	echo Keil uVision version \>\= 5.30: double-click the .cprj file. The .gpdsc file is loaded automatically.;
ifeq ($(TOOLCHAIN), GCC_ARM)
	$(CY_NOISE)echo To switch the project to use GCC toolchain, open Project - Manage - Project Items - Folders/Extensions, and set GCC prefix and path.
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

CY_VSCODE_OUT_PATH=$(CY_INTERNAL_APP_PATH)/.vscode
CY_VSCODE_OUT_TEMPLATE_PATH=$(CY_VSCODE_OUT_PATH)/cytemplates
CY_VSCODE_BACKUP_PATH=$(CY_VSCODE_OUT_PATH)/backup
CY_VSCODE_TEMPLATE_PATH=$(CY_INTERNAL_BASELIB_PATH)/make/scripts/vscode
CY_VSCODE_TEMPFILE=$(CY_CONFIG_DIR)/vscode_launch.temp
CY_VSCODE_WORKSPACE_NAME=$(CY_IDE_PRJNAME).code-workspace

ifneq ($(wildcard $(CY_INTERNAL_APP_PATH)/$(CY_VSCODE_WORKSPACE_NAME)),)
CY_VSCODE_BACKUP_WORKSPACE=true
endif

CY_VSCODE_SEARCH=
ifneq ($(CY_IDE_SHARED),)
ifneq ($(wildcard $(CY_IDE_SHARED)),)
CY_VSCODE_SEARCH=\,\\n\\t\\t{\\n\\t\\t\\t\"path\": \"$(CY_IDE_SHARED)\"\\n\\t\\t}
endif
endif

CY_VSCODE_INCLUDES=$(foreach onedef,$(subst -I,,$(CY_IDE_INCLUDES)),\"$(onedef)\",)
CY_VSCODE_INCLUDES_LIST=$(subst $(CY_SPACE),$(CY_NEWLINE_MARKER),$(CY_VSCODE_INCLUDES))

CY_VSCODE_DEFINES=$(foreach onedef,$(subst -D,,$(CY_IDE_DEFINES)),\"$(onedef)\",)
CY_VSCODE_DEFINES_LIST=$(subst $(CY_SPACE),$(CY_NEWLINE_MARKER),$(CY_VSCODE_DEFINES))

# Note: CY_VSCODE_ARGS is expected to come from the recipe
# Note: CDB generation happens in build.mk
# Note: Series of sed substitutions are intentional as macOs default BSD sed does not understand \t and \n
vscode: CY_IDE_preprint CY_BUILD_cdb_postprint
ifeq ($(LIBNAME),)
	$(CY_NOISE)mkdir -p $(CY_CONFIG_DIR);\
	mkdir -p $(CY_VSCODE_OUT_TEMPLATE_PATH);\
	mkdir -p $(CY_VSCODE_BACKUP_PATH);\
	echo $(CY_VSCODE_ARGS) > $(CY_VSCODE_TEMPFILE);\
	echo "s|&&CY_INCLUDE_LIST&&|$(CY_VSCODE_INCLUDES_LIST)|" >> $(CY_VSCODE_TEMPFILE);\
	echo "s|&&CY_DEFINE_LIST&&|$(CY_VSCODE_DEFINES_LIST)|"   >> $(CY_VSCODE_TEMPFILE);\
	echo "s|&&CY_SEARCH_DIRS&&|$(CY_VSCODE_SEARCH)|" | sed s/'\\t'/'    '/g | sed s/'\\n'/'$(CY_NEWLINE_MARKER)'/g >> $(CY_VSCODE_TEMPFILE);\
	echo;
ifeq ($(CY_VSCODE_BACKUP_WORKSPACE),true)
	$(CY_NOISE) mv -f $(CY_INTERNAL_APP_PATH)/$(CY_VSCODE_WORKSPACE_NAME) $(CY_VSCODE_BACKUP_PATH)/$(CY_VSCODE_WORKSPACE_NAME);
	echo "The existing $(CY_VSCODE_WORKSPACE_NAME) file has been saved to .vscode/backup";
endif
	$(CY_NOISE)sed -f $(CY_VSCODE_TEMPFILE) $(CY_VSCODE_TEMPLATE_PATH)/do_not_copy/wks.code-workspace | \
		sed s/'$(CY_NEWLINE_MARKER)'/$$'\\\n'/g > $(CY_INTERNAL_APP_PATH)/$(CY_VSCODE_WORKSPACE_NAME);
	$(CY_NOISE)for json in $(CY_VSCODE_TEMPLATE_PATH)/*; do\
		jsonFile="$${json##*/}";\
		if [ $$jsonFile == "do_not_copy" ]; then\
			continue;\
		fi;\
		if [[ $$jsonFile == *"c_cpp_properties"* ]] && [[ $$jsonFile != *"c_cpp_properties_$(TOOLCHAIN).json" ]]; then\
			continue;\
		fi;\
		sed -f $(CY_VSCODE_TEMPFILE) $(CY_VSCODE_TEMPLATE_PATH)/$$jsonFile | \
			sed s/'$(CY_NEWLINE_MARKER)'/$$'\\\n            '/g > $(CY_VSCODE_OUT_TEMPLATE_PATH)/$$jsonFile;\
		if [[ $$jsonFile == *"c_cpp_properties_$(TOOLCHAIN).json" ]]; then\
			jsonFile="c_cpp_properties.json";\
			mv $(CY_VSCODE_OUT_TEMPLATE_PATH)/c_cpp_properties_$(TOOLCHAIN).json $(CY_VSCODE_OUT_TEMPLATE_PATH)/c_cpp_properties.json;\
		fi;\
		$(CY_VSCODE_JSON_PROCESSING)\
		jsonFiles="$$jsonFiles $$jsonFile";\
		if [ -f $(CY_VSCODE_OUT_PATH)/$$jsonFile ] && [[ $$jsonFile == *"settings.json" ]]; then\
			echo "Modifying existing settings.json file. Check against the backup copy in .vscode/backup";\
			mv -f $(CY_VSCODE_OUT_PATH)/$$jsonFile $(CY_VSCODE_BACKUP_PATH)/$$jsonFile;\
			sed -e 's/\/bin\/openocd\"/\/bin\/openocd\",/g' $(CY_VSCODE_OUT_TEMPLATE_PATH)/$$jsonFile |\
				grep -v -e "^}" > $(CY_VSCODE_OUT_PATH)/$$jsonFile;\
			sed -e '/^{/d'\
			    -e '/\/\/mtb\/\//d'\
			    -e '/modustoolbox.toolsPath/d'\
			    -e '/cortex-debug.armToolchainPath/d'\
			    -e '/cortex-debug.openocdPath/d'\
			    $(CY_VSCODE_BACKUP_PATH)/$$jsonFile >> $(CY_VSCODE_OUT_PATH)/$$jsonFile;\
		else\
			if [ -f $(CY_VSCODE_OUT_PATH)/$$jsonFile ]; then\
				echo "The existing $$jsonFile file has been saved to .vscode/backup";\
				mv -f $(CY_VSCODE_OUT_PATH)/$$jsonFile $(CY_VSCODE_BACKUP_PATH)/$$jsonFile;\
			fi;\
			cp $(CY_VSCODE_OUT_TEMPLATE_PATH)/$$jsonFile $(CY_VSCODE_OUT_PATH)/$$jsonFile;\
		fi;\
	done;\
	$(CY_VSCODE_OPENOCD_PROCESSING)\
	mv $(CY_VSCODE_OUT_PATH)/openocd.tcl $(CY_INTERNAL_APP_PATH)/openocd.tcl;\
	rm $(CY_VSCODE_TEMPFILE);\
	rm -rf $(CY_VSCODE_OUT_TEMPLATE_PATH);\
	echo;\
	echo Generated Visual Studio Code files: $$jsonFiles;\
	echo;\
	echo "J-Link users, please see the comments at the top of the launch.json";\
	echo "   file about setting the location of the gdb-server.";\
	echo;\
	echo "Instructions:";\
	echo "1. Review the modustoolbox.toolsPath property in .vscode/settings.json";\
	echo "2. Open VSCode";\
	echo "3. Install \"C/C++\" and \"Cortex-Debug\" extensions";\
	echo "4. File->Open Folder (Welcome page->Start->Open folder)";\
	echo "5. Select the app root directory and open";\
	echo "6. Builds: Terminal->Run Task";\
	echo "7. Debugging: \"Bug icon\" on the left-hand pane";\
	echo;
else
	@:
endif

endif # ifeq ($(filter vscode,$(MAKECMDGOALS)),vscode)

#
# Identify the phony targets
#
.PHONY: eclipse ewarm8 uvision5 vscode CY_IDE_preprint
