#!/bin/bash
#
################################################################################
# \file python.bash
#
# \brief
# The script in this file is a wrapper for Windows python3 calls.
#
################################################################################
# \copyright
# Copyright (c) 2024-2026, Infineon Technologies AG, or an affiliate of
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
#
(set -o igncr) 2>/dev/null && set -o igncr; # this comment is required
set -$-ue${DEBUG+xv}

#######################################################################################################################
# This script calls python3 mapped to python.
#
# usage:
#	python.bash <parameters>
#
#######################################################################################################################

KERNEL="$($(which uname) -s)"
case "$KERNEL" in
    CYGWIN*)
#
# Cygwin
#

#
# Use mixed path for Cygwin.
#
        CYGPATH="cygpath -m "
#
# On Windows, when using windows store python, cygwin or msys are not
# able to run the python executable downloaded from windows store. So,
# we run python from command prompt (in cygwin/msys) by prepending
# cmd /c.
# Do not remove the space at the end of the following variable assignment
#
        PYTHON_FROM_CMD="cmd /c "
        ${PYTHON_FROM_CMD}"$(${CYGPATH}"$(which python)")" "$@"
        ;;

    MINGW*|MSYS*)
#
# MINGW and MSYS
#

#
# On Windows, when using windows store python, cygwin or msys are not
# able to run the python executable downloaded from windows store. So,
# we run python from command prompt (in cygwin/msys) by prepending
# cmd /c.
# Do not remove the space at the end of the following variable assignment
#
        PYTHON_FROM_CMD="cmd /c "
        ${PYTHON_FROM_CMD}"$(which python)" "$@"
        ;;
#
# Other environments
#
    *)
        "$(which python)" "$@"
        ;;
esac
