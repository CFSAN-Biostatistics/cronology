#!/usr/bin/env python3

import argparse
import base64
import csv
import inspect
import json
import logging
import os
import pprint
import secrets
import string

import requests
from requests.packages import urllib3


# Multiple inheritence for pretty printing of help text.
class MultiArgFormatClasses(
    argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter
):
    pass


# Basic checks
def check_file_extension(folder_path) -> os.PathLike:
    if not os.path.isdir(folder_path):
        logging.error(f"The provided path: '{folder_path}' is not a valid directory.")
        exit(1)

    tree_and_metadata_files = [
        file
        for file in os.listdir(folder_path)
        if file.endswith(".nwk") or file.endswith(".csv")
    ]

    if len(tree_and_metadata_files) != 2:
        logging.error(
            "We need exactly one .nwk file and one metadata "
            + "file in CSV (.csv) format."
        )
        exit(1)

    for file in tree_and_metadata_files:
        file_path = os.path.join(folder_path, file)

        if os.path.isfile(file_path):
            extension = os.path.splitext(file)
            if extension[1] not in [".csv", ".nwk"]:
                logging.error(f"{file} is not the correct extension: .nwk or .csv")
                exit(1)

        if file_path.endswith(".nwk"):
            nwk_file = file_path

    return nwk_file


# Checking the CSV file
def uppercase_headers(folder_path) -> list:
    for filename in os.listdir(folder_path):
        if filename.endswith(".csv"):
            filepath = os.path.join(folder_path, filename)
            with open(filepath, "r", newline="") as file:
                reader = csv.reader(file)
                headers = next(reader)
                if all(header.isupper() for header in headers):
                    pass
                else:
                    headers = [header.upper() for header in headers]
                    with open(filepath, "w", newline="") as file:
                        writer = csv.writer(file)
                        writer.writerow(headers)
                        for row in reader:
                            writer.writerow(row)
                    file.close()
            file.close()
    return headers


def check_csv(folder_path) -> os.PathLike:
    for filename in os.listdir(folder_path):
        if filename.endswith(".csv"):
            filepath = os.path.join(folder_path, filename)
            with open(filepath, "r", newline="") as file:
                reader = csv.reader(file)

                # Checking for headers and first column named "ID"
                headers = next(reader, None)
                if headers is None:
                    logging.error("Error: CSV file has no column headers.")
                    exit(1)
                if headers[0] != "ID":
                    logging.error("Error: First column header is not 'ID'.")
                    exit(1)

                # Check if all values in "ID" column are unique
                col_values = set()
                for row in reader:
                    id_value = row[0].strip()
                    if id_value in col_values:
                        logging.error(f"Duplicate ID found: {id_value}")
                        exit(1)
                    col_values.add(id_value)

                # Checking that columns are equal across all rows
                num_columns = None
                for i, row in enumerate(reader):
                    if num_columns is None:
                        num_columns = len(row)
                    elif len(row) != num_columns:
                        logging.error(
                            f"Error: Unequal number of columns in row {i + 1}"
                        )
                        exit(1)
            file.close()
    return filepath


# Encode files to base64 for uploading
def encode_file(file) -> str:
    with open(file, "r") as f:
        file = f.read()
    file_64 = base64.b64encode(file.encode()).decode()
    f.close()
    return file_64


# Creating the .microreact JSON file
def gen_ran_string(length=4) -> str:
    letters = string.ascii_letters
    return "".join(secrets.choice(letters) for i in range(length))


# Microreact JSON template
def create_json(
    metadata_csv, tree_path, metadata_64, tree_64, ProjectName, folder_path
) -> os.PathLike:
    file_csv = gen_ran_string()
    file_tree = gen_ran_string()
    csv_size = os.path.getsize(metadata_csv)
    tree_size = os.path.getsize(tree_path)
    headers = uppercase_headers(folder_path)
    columns = [{"field": "ID", "fixed": False}]

    for header in headers[1:]:
        columns.append({"field": header, "fixed": False})

    microreact_data = {
        "charts": {},
        "datasets": {
            "dataset-1": {"id": "dataset-1", "file": file_csv, "idFieldName": "ID"}
        },
        "files": {
            file_csv: {
                "blob": f"data:text/csv;base64,{metadata_64}",
                "format": "text/csv",
                "id": file_csv,
                "name": os.path.basename(metadata_csv),
                "size": csv_size,
                "type": "data",
            },
            file_tree: {
                "blob": f"data:application/octet-stream;base64,{tree_64}",
                "format": "text/x-nh",
                "id": file_tree,
                "name": os.path.basename(tree_path),
                "size": tree_size,
                "type": "tree",
            },
        },
        "filters": {
            "dataFilters": [],
            "chartFilters": [],
            "searchOperator": "includes",
            "searchValue": "",
            "selection": [],
            "selectionBreakdownField": None,
        },
        "maps": {},
        "meta": {"name": ProjectName},
        "trees": {
            "tree-1": {
                "alignLabels": False,
                "blockHeaderFontSize": 13,
                "blockPadding": 0,
                "blocks": ["MLST_SEQUENCE_TYPE", "ISOLATION_SOURCE"],
                "blockSize": 14,
                "branchLengthsDigits": 4,
                "controls": True,
                "fontSize": 16,
                "hideOrphanDataRows": False,
                "ids": None,
                "internalLabelsFilterRange": [0, 100],
                "internalLabelsFontSize": 13,
                "lasso": False,
                "nodeSize": 14,
                "path": None,
                "roundBranchLengths": True,
                "scaleLineAlpha": True,
                "showBlockHeaders": True,
                "showBlockLabels": False,
                "showBranchLengths": False,
                "showEdges": True,
                "showInternalLabels": False,
                "showLabels": True,
                "showLeafLabels": True,
                "showPiecharts": True,
                "showShapeBorders": True,
                "showShapes": True,
                "styleLeafLabels": False,
                "styleNodeEdges": False,
                "subtreeIds": None,
                "type": "rc",
                "title": "Tree",
                "labelField": "ID",
                "file": file_tree,
            }
        },
        "tables": {
            "table-1": {
                "displayMode": "cosy",
                "hideUnselected": False,
                "title": "Metadata",
                "paneId": "table-1",
                "columns": columns,
                "file": file_csv,
            }
        },
        "views": [],
        "schema": "https://microreact.org/schema/v1.json",
    }
    micro_path = os.path.join(os.getcwd(), ProjectName + ".microreact")

    with open(micro_path, "w") as microreact_file:
        json.dump(microreact_data, microreact_file, indent=2)
        microreact_file.close()
    microreact_file.close()

    return micro_path


# Main
def main() -> None:
    """
    Will take as input a folder containing 2 files, a tree file and a metadata CSV file
    and upload it to a new project named "Cronology" and get a publicly shareable link from
    microreact.org once the upload is successful

    """
    # Debug print.
    ppp = pprint.PrettyPrinter(width=55)

    # Set logging.
    logging.basicConfig(
        format="\n"
        + "=" * 55
        + "\n%(asctime)s - %(levelname)s\n"
        + "=" * 55
        + "\n%(message)s\n\n",
        level=logging.DEBUG,
    )

    # Turn off SSL warnings
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    prog_name = os.path.basename(inspect.stack()[0].filename)

    parser = argparse.ArgumentParser(
        prog=prog_name, description=main.__doc__, formatter_class=MultiArgFormatClasses
    )

    # Add required arguments
    required = parser.add_argument_group("required arguments")

    required.add_argument(
        "-dir",
        dest="dir",
        default=False,
        required=True,
        help="UNIX path to diretory containing the tree and all other\ndataset and annotation files."
        + " Your tree file and metadata files must\nhave the extension .nwk and .csv",
    )
    required.add_argument(
        "-atp",
        dest="AccessTokenPath",
        default=False,
        required=True,
        help="The path to your API Access Token needed for uploading.\n"
        + "File must be a .txt file.",
    )
    parser.add_argument(
        "-name",
        dest="ProjectName",
        default="Project",
        required=False,
        help="Name for the project you want to upload",
    )

    # Define defaults
    args = parser.parse_args()
    upload_url = "https://microreact.org/api/projects/create"
    folder_path = args.dir
    ProjectName = args.ProjectName
    micro_url_info_path = os.path.join(os.getcwd(), "microreact_url.txt")

    with open(args.AccessTokenPath, "r") as token:
        atp = token.readline()
    token.close()

    tree_path = check_file_extension(folder_path)
    metadata_csv = check_csv(folder_path)
    metadata_64 = encode_file(metadata_csv)
    tree_64 = encode_file(tree_path)

    # Prepare the data to be sent in the request
    micro_path = create_json(
        metadata_csv, tree_path, metadata_64, tree_64, ProjectName, folder_path
    )

    f = open(micro_path)
    data = json.load(f)
    f.close()

    # Additional parameters, including the MicroReact API key
    headers = {"Content-type": "application/json; charset=UTF-8", "Access-Token": atp}

    # Make the POST request to Microreact
    r = requests.post(upload_url, json=data, headers=headers, verify=False)

    if not r.ok:
        if r.status_code == 400:
            logging.error("Microreact API call failed with response " + r.text + "\n")
        else:
            logging.error(
                "Microreact API call failed with unknown response code "
                + str(r.status_code)
                + "\n"
            )
        exit(1)
    if r.status_code == 200:
        r_json = json.loads(r.text)
        with open(micro_url_info_path, "w") as out_fh:
            out_fh.write(
                f"Uploaded successfully!\n\nYour project URL:\n{r_json['url']}"
            )
        out_fh.close()


if __name__ == "__main__":
    main()
