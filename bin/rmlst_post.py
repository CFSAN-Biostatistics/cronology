#!/usr/bin/env python3

# Kranti Konganti

import argparse
import base64
import gzip
import inspect
import json
import logging
import os
import pprint
import re
from collections import defaultdict

import requests


# Multiple inheritence for pretty printing of help text.
class MultiArgFormatClasses(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


# Main
def main() -> None:
    """
    This script takes as input an assembly .fasta format (gzipped or ungzipped)
    and posts to PubMLST to get the species taxonomy.
    """

    # Set logging.
    logging.basicConfig(
        format="\n" + "=" * 55 + "\n%(asctime)s - %(levelname)s\n" + "=" * 55 + "\n%(message)s\n\n",
        level=logging.DEBUG,
    )

    # Debug print.
    ppp = pprint.PrettyPrinter(width=55)
    prog_name = os.path.basename(inspect.stack()[0].filename)

    parser = argparse.ArgumentParser(
        prog=prog_name, description=main.__doc__, formatter_class=MultiArgFormatClasses
    )

    required = parser.add_argument_group("required arguments")

    required.add_argument(
        "-fasta",
        dest="fasta",
        default=False,
        required=True,
        help="Absolute UNIX path to file no. 1 containing\nnon white space lines.",
    )
    parser.add_argument(
        "-prefix",
        dest="prefix",
        default="response",
        required=False,
        help="The prefix of the file name that will be created in\nthe current working directory.",
    )
    parser.add_argument(
        "-fkey",
        dest="fkey",
        default="fields",
        required=False,
        help="The key name in the JSON response that contains ST results.",
    )
    parser.add_argument(
        "-tkey",
        dest="tkey",
        default="taxon_prediction",
        required=False,
        help="The key name in the JSON response that contains a list of\ntaxonomy predictions.",
    )

    # Define defaults

    args = parser.parse_args()
    fasta = args.fasta
    fkey = args.fkey
    tkey = args.tkey
    outfile = os.path.join(os.getcwd(), args.prefix + "_rmlstd.tsv")
    logfile = os.path.join(os.getcwd(), args.prefix + "_rmlst_req.log.json")
    field_keys = ["rST", "other_designation"]
    tax_pred_keys = ["rank", "support", "taxon", "taxonomy"]
    uri = "http://rest.pubmlst.org/db/pubmlst_rmlst_seqdef_kiosk/schemes/1/sequence"
    # uri = "https://rest.pubmlst.org/db/pubmlst_cronobacter_isolates/loci/atpD/sequence"
    payload = '{"base64":true, "details":true, "sequence":"'
    sample_name = str(args.prefix)
    out = defaultdict(defaultdict)

    # Basic checks

    if not (os.path.exists(fasta) and os.path.getsize(fasta) > 0):
        logging.error(f"File\n{os.path.basename(fasta)}\ndoes not exist or the file is empty.")
        exit(1)

    try:
        with gzip.open(fasta, "rb") as fasta_fh:
            seqs = fasta_fh.read()
    except gzip.BadGzipFile:
        with open(fasta, "r") as fasta_fh:
            seqs = fasta_fh.read()
    payload += base64.b64encode(str(seqs).encode()).decode() + '"}'
    response = requests.post(uri, data=payload)

    if response.status_code == requests.codes.ok:
        res = response.json()
        json.dump(res, open(logfile, "w"), indent=4, sort_keys=True)

        try:
            for count, prediction in enumerate(res[tkey]):
                out.setdefault(tkey, {}).setdefault(count, {})
                for key in tax_pred_keys:
                    out[tkey][count].setdefault(key, prediction[key])
        except (KeyError, AttributeError, TypeError) as e:
            logging.error(
                "Did not get taxonomy prediction from JSON response. Highly unusual?\n"
                + f"KeyError or AttributeError or TypeError:\n{e}"
            )
            exit(1)

        try:
            for key in field_keys:
                out.setdefault(key, res[fkey][key])
        except (KeyError, AttributeError, TypeError) as e:
            for key in field_keys:
                out.setdefault(key, "-")
            logging.info(
                "Did not get rST or other_designation from JSON response. Will skip.\n"
                + f"KeyError or AttributeError or TypeError:\n{e}"
            )

        try:
            with open(outfile, "w") as out_fh:
                # Header
                out_fh.writelines(
                    "\t".join(
                        ["Sample"]
                        + [k for k, _ in out.items() if out[k] and k != tkey]
                        + [k for k in out[tkey][0].keys() if out[tkey][0][k]]
                    )
                )
                for count in out[tkey].keys():
                    out_fh.writelines(
                        "\n"
                        + "\t".join(
                            [sample_name]
                            + [v for k, v in out.items() if out[k] and k != tkey]
                            + [
                                str(re.sub(r"\s*\>\s*", ";", str(v)))
                                for k, v in out[tkey][count].items()
                                if out[tkey][count][k]
                            ],
                        )
                        + "\n"
                    )
            out_fh.close()
        except (KeyError, AttributeError, TypeError) as e:
            logging.error(f"Unable to write final results.\nException: {e}")
            exit(1)


if __name__ == "__main__":
    main()
