################################################################################
# \file application_bootstrap.mk
#
# \brief
# bootstrap make target that need to call up to the application
#
################################################################################
# \copyright
# Copyright 2024 Cypress Semiconductor Corporation
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

.SECONDEXPANSION:

build_application_bootstrap:
	$(MTB__NOISE)$(MAKE) -C .. build
	$(MTB__NOISE)echo;\
	echo "Note: Running the \"build_proj\" target in this sub-project will only build this sub-project, and not the entire application."

qbuild_application_bootstrap:
	$(MTB__NOISE)$(MAKE) -C .. qbuild
	$(MTB__NOISE)echo;\
	echo "Note: Running the \"qbuild_proj\" target in this sub-project will only build this sub-project, and not the entire application."

program_application_bootstrap qprogram_application_bootstrap clean_application_bootstrap eclipse_application_bootstrap vscode_application_bootstrap:
	$(MTB__NOISE)$(MAKE) -C .. $(patsubst %_application_bootstrap,%,$@)

ifeq ($(MTB_CORE__APPLICATION_BOOTSTRAP),true)
build qbuild program qprogram clean eclipse vscode: $$@_application_bootstrap
else
build qbuild clean program qprogram: $$@_proj
eclipse vscode: $$@_generate
endif


.PHONY: eclipse_application_bootstrap vscode_application_bootstrap program_application_bootstrap qprogram_application_bootstrap build_application_bootstrap qbuild_application_bootstrap clean_application_bootstrap
.PHONY:eclipse_generate vscode_generate
