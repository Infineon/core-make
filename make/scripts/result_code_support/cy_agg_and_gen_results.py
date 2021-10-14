"""
This module is intended to aggregate all intermediate asset json files
and generate a final report HTML page with all result code/module id info
"""
import os
import json
import argparse

# constants
ID = "ID"
MODULE = "Module"
RESULT_TYPE = "Type"
LOCATION = "Location"
MODULE_IDS = "MODULE_IDS"
DESCRIPTION = "Description"
RESULT_CODE = "Result Code"
RESULT_CODES = "RESULT_CODES"

# String for HTML CSS and table headers

HTML_BEG = """
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Result Codes Reference</title>
    <style type="text/css">
    body {
        font-family: "Source Sans Pro";
        background-color: #f1f1f1;
        margin: 0px;
        overflow-y: scroll;
        font-size: 12pt;
        font-weight: normal;
        margin-top: 4px;
        margin-left: 12px;
        margin-bottom: 5px;
        }

    table {
        background-color: #FFFFFF;
        margin-left: 15px;
        margin-right:30px;
        padding: 10px;
        }

    div {
        margin-left: 15px;
        margin-right: 30px;
        padding: 10px;
        }
    .Header {
        color: black;
        background-color: #dbeae5;
        font-size: 14pt;
        font-weight: bold;
        margin-top: 15px;
        margin-bottom: 0px;
        padding: 5px;
        }

    .Section {
        color: black;
        background-color: #dbeae5;
        font-size: 12pt;
        margin-top: 0px;
        margin-bottom: 5px;
        padding: 5px;
        }

    .DocTitle {
        color: white;
        background-color: #478F7C;
        font-size: 18pt;
        padding: 12px;
        margin-top: 0px;
        margin-bottom: 14px;
        }

    a {
        color: #2e5c50;
        text-decoration: none;
        background-color: transparent;
        }

    a:hover {
        color: #478f7c;
        text-decoration: underline;
        }

    a:not([href]):not([tabindex]) {
        color: inherit;
        text-decoration: none;
        }

    a:not([href]):not([tabindex]):hover, a:not([href]):not([tabindex]):focus {
        color: inherit;
        text-decoration: none;
        }

    a:not([href]):not([tabindex]):focus {
        outline: 0;
        }

    </style>

  </head>
  <body>
    <div class="DocTitle">Result Codes Reference</div>
    <div>This page provides information on result codes that are produced by Infineon/Cypress assets as part the ModusToolbox&#153; software.</div>
"""
############################################
# Aggregation and HTML generation functions
############################################

def cy_parse_cli_args():
    """
    Summary:
        Responsible for collecting command line arguments
    Arguments:
        None
    Returns:
        Namespace
    """
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-j",
        "--json",
        required=True,
        nargs="+",
        help="The json file(s) describing asset result codes."
    )
    parser.add_argument(
        "-o",
        "--output-file",
        required=True,
        help="The file path where the result code reference HTML page should be generated."
    )
    args = parser.parse_args()
    return args

def cy_collect_json_data(json_files):
    """
    Summary:
        Loads all json files that document
        all asset result codes into memory
    Arguments:
        json_files: (list) all intermediate json files.
    Returns:
        dict, all json data
    """
    result = {}
    for filename in json_files:
        with open(filename, "r") as file_obj:
            data = json.load(file_obj)
            result = cy_merge_json(result, data)
    return result

def cy_merge_json(result, data):
    """
    Summary:
        Merges two dictionaries. One being the master dictionary
        and the other being another asset json dict.
    Arguments:
        result: dict, master json dict
        data: dict, individual asset dict
    Returns:
        result (master json dict)
    """
    for key in data:
        if key not in result:
            result[key] = {}
        for sub_key in data[key]:
            if sub_key not in result[key]:
                result[key][sub_key] = data[key][sub_key]
    return result

def cy_generate_html(output_file, json_dict):
    """
    Summary:
        Creates the HTML page that documents all result codes.
    Arguments:
        output_file: output file name (absolute file path)
        json_dict: aggregated intermediate json file info
    Returns:
        None
    """
    with open(output_file, "w") as file_obj:
        file_obj.write(HTML_BEG)
        if MODULE_IDS in json_dict:
            module_id_table = cy_generate_module_ids_table(json_dict[MODULE_IDS])
            file_obj.write(module_id_table)
        if RESULT_CODES in json_dict:
            result_code_table = cy_generate_result_code_table(json_dict[RESULT_CODES])
            file_obj.write(result_code_table)
        file_obj.write("</body></html>")

def cy_generate_result_code_table(result_code_dict):
    """
    Summary:
        Creates the table that contains information on all result codes.
    Arguments:
        result_code_dict: dict, of result codes
    Returns:
        string (html table)
    """
    declarations = list(result_code_dict.keys())
    declarations.sort()
    result_code_table_string = """
    <div class="Header">Result Codes</div>
    <div class="Section">This section contains information on result codes found in Infineon/Cypress assets.</div>
    <table>
        <!-- Result Code Table -->
        <tr>
            <th class="Header"> Result Code </th>
            <th class="Header"> Name </th>
            <th class="Header"> Result Type </th>
            <th class="Header"> Module </th>
            <th class="Header"> ID </th>
            <th class="Header"> Description </th>
        </tr>
    """
    for declaration in declarations:
        declaration_dict = result_code_dict[declaration]
        description = declaration_dict[DESCRIPTION]
        result_type = declaration_dict[RESULT_TYPE]
        module = declaration_dict[MODULE]
        id_value = declaration_dict[ID]
        result_code = declaration_dict[RESULT_CODE]
        int_result_code = int(result_code, 16)
        result_code_string = f"{result_code} ({int_result_code})"
        table_row = f"""
        <tr>
            <td>{result_code_string}</td>
            <td>{declaration}</td>
            <td>{result_type}</td>
            <td>{module}</td>
            <td>{id_value}</td>
            <td width="30%">{description}</td>
        </tr>
        """
        result_code_table_string += table_row
    result_code_table_string += "</table>"
    return result_code_table_string

def cy_generate_module_ids_table(module_id_section):
    """
    Summary:
        Creates the HTML table that contains the mappings for
        module id's and their hexadecimal value.
    Arguments:
        module_id_section: dict, MODULE_IDS json section
    Returns:
        string (html table)
    """
    table_string = """
    <div class="Header">Module IDs</div>
    <div class="Section">This section lists modules used in the application and their corresponding IDs used in the result code.</div>
    <table width="30%">
        <!-- Module ID Table -->
        <tr>
            <th class="Header"> Module ID </th>
            <th class="Header"> Value </th>
        </tr>
    """
    module_ids = list(module_id_section.keys())
    module_ids.sort()
    for module_id in module_ids:
        module_id_dict = module_id_section[module_id]
        id_value = module_id_dict[ID]
        table_string += f"""
            <tr>
                <td width="20%">{module_id}</td>
                <td>{id_value}</td>
            </tr>
            """
    table_string += "</table>"
    return table_string

def main():
    """
    Summary:
        Serves as the main program
    Arguments:
        None
    Returns:
        None
    """
    args = cy_parse_cli_args()
    # aggregate all intermediate json files
    aggregated_json = cy_collect_json_data(args.json)
    # generate HTML report page
    cy_generate_html(args.output_file, aggregated_json)

if __name__ == "__main__":
    main()
