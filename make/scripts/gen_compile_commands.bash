#!/bin/bash
#
################################################################################
# \file gen_compile_commands.bash
#
# \brief
# The script generates compilation commands in JSON format.
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
#
(set -o igncr) 2>/dev/null && set -o igncr; # this comment is required
set -$-ue${DEBUG+x}

#######################################################################################################################
# This script generates the compilation data file.
#
# usage:
#	gen_compile_commands.bash <output_file> <working_directory> [input_file]+
#
# input file lines:
#   1: arguments
#   2: source files (space separated entries)
#   3: object files (space separated entries)
#
# Expects 3 inputs files, 1 for .s, 1 for .c, and 1 for .cpp
#
#######################################################################################################################

output_file=$1
shift 1

working_directory=$1
shift 1

buffer="["$'\n'

first_entry=true

for input_file in "$@"
do
    line_number=1
    while IFS= read -r line
    do
        if [ "$line_number" = "1" ]; then
            arguments=$line
        elif [ "$line_number" = "2" ]; then
            src_files=$line
        else
            obj_files=$line
        fi
        ((line_number++))
    done < $input_file

    IFS=' ' read -r -a src_file_array <<< "$src_files"
    IFS=' ' read -r -a obj_file_array <<< "$obj_files"

    array_length=${#src_file_array[@]}
    for (( i=0; i<array_length; i++ ));
    do
        src_file=${src_file_array[$i]}
        obj_file=${obj_file_array[$i]}

        if [ "$first_entry" != "true" ]; then
            buffer+=","$'\n'
        else
            first_entry=false
        fi

        buffer+="    {"$'\n'
        buffer+="        \"directory\": \"$working_directory\","$'\n'
        buffer+="        \"file\": \"$src_file\","$'\n'
        buffer+="        \"command\": \"$arguments $obj_file $src_file\""$'\n'
        buffer+="    }"
    done
done

buffer+=$'\n'"]"
echo "$buffer" >> $output_file
