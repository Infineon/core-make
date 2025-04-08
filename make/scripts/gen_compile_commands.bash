#!/bin/bash
#
# Copyright 2018-2025, Cypress Semiconductor Corporation (an Infineon company) or
# an affiliate of Cypress Semiconductor Corporation.  All rights reserved.
#
# This software, including source code, documentation and related
# materials ("Software") is owned by Cypress Semiconductor Corporation
# or one of its affiliates ("Cypress") and is protected by and subject to
# worldwide patent protection (United States and foreign),
# United States copyright laws and international treaty provisions.
# Therefore, you may use this Software only as provided in the license
# agreement accompanying the software package from which you
# obtained this Software ("EULA").
# If no EULA applies, Cypress hereby grants you a personal, non-exclusive,
# non-transferable license to copy, modify, and compile the Software
# source code solely for use in connection with Cypress's
# integrated circuit products.  Any reproduction, modification, translation,
# compilation, or representation of this Software except as specified
# above is prohibited without the express written permission of Cypress.
#
# Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, NONINFRINGEMENT, IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Cypress
# reserves the right to make changes to the Software without notice. Cypress
# does not assume any liability arising out of the application or use of the
# Software or any product or circuit described in the Software. Cypress does
# not authorize its products for use in any products where a malfunction or
# failure of the Cypress product may reasonably be expected to result in
# significant property damage, injury or death ("High Risk Product"). By
# including Cypress's product in a High Risk Product, the manufacturer
# of such system or application assumes all risk of such use and in doing
# so agrees to indemnify Cypress against all liability.
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
