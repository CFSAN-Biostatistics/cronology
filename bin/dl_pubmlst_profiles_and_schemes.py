#!/usr/bin/env python3

# Kranti Konganti

import argparse
import inspect
import json
import logging
import os
import shutil
import tempfile
from urllib.parse import urlparse
from urllib.request import urlopen

# Set logging format.
logging.basicConfig(
    format="\n" + "=" * 55 + "\n%(asctime)s - %(levelname)s\n" + "=" * 55 + "\n%(message)s\n",
    level=logging.DEBUG,
)


# Multiple inheritence for pretty printing of help text.
class MultiArgFormatClasses(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


def dl_pubmlst(**kwargs) -> None:
    """
    Method to save the Raw Data from a URL.
    """
    outdir, url, suffix, parent, filename, expectjson = [kwargs[k] for k in kwargs.keys()]

    if (outdir or url) == None:
        logging.error("Please provide absolute UNIX path\n" + "to store the result DB flat files.")
        exit(1)

    logging.info(f"Downloading... Please wait...\n{url}")

    with urlopen(url) as response:
        with tempfile.NamedTemporaryFile(delete=False) as tmp_html_file:
            shutil.copyfileobj(response, tmp_html_file)

    if expectjson:
        try:
            jsonresponse = json.load(open(tmp_html_file.name, "r"))
        except json.JSONDecodeError:
            logging.error(f"The response from\n{url}\nwas not valid JSON!")
            exit(1)

        logging.info(f"Got a valid JSON response from:\n{url}")
        return jsonresponse

    if not parent:
        if not filename:
            save_to = os.path.join(outdir, os.path.basename(urlparse(url).path) + suffix)
        else:
            save_to = os.path.join(outdir, filename + suffix)

        logging.info(f"Saving to:\n{os.path.basename(save_to)}")

        with urlopen(url) as url_response:
            with open(save_to, "w") as fout:
                fout.writelines(url_response.read().decode("utf-8"))

        fout.close()
        url_response.close()


def main() -> None:
    """
    This script is part of the `cronology_db` Nextflow workflow and is only
    tested on POSIX sytems.
    It:
        1. Downloads the MLST scheme in JSON format from PubMLST.
            and then,
        2. Downloads the alleles' FASTA and profile table
            suitable to run MLST analysis.
    """

    prog_name = os.path.basename(inspect.stack()[0].filename)

    parser = argparse.ArgumentParser(
        prog=prog_name, description=main.__doc__, formatter_class=MultiArgFormatClasses
    )

    required = parser.add_argument_group("required arguments")

    required.add_argument(
        "-org",
        dest="organism",
        required=True,
        help="The organism name to download the MLST alleles'\nFASTA and profile CSV for."
        + "\nEx: -org cronobacter",
    )
    parser.add_argument(
        "-f",
        dest="overwrite",
        default=False,
        required=False,
        action="store_true",
        help="Force overwrite the results directory\nmentioned with -out.",
    )
    parser.add_argument(
        "-out",
        dest="outdir",
        default=os.getcwd(),
        required=False,
        help="The absolute UNIX path to store the MLST alleles'\nFASTA and profile CSV.\n",
    )
    parser.add_argument(
        "-mlsts",
        dest="schemes",
        default="schemes/1",
        required=False,
        help="The MLST scheme ID to download.",
    )
    parser.add_argument(
        "-profile",
        dest="profile",
        default="profiles_csv",
        required=False,
        help="The MLST profile name in the scheme.",
    )
    parser.add_argument(
        "-loci",
        dest="loci",
        default="loci",
        required=False,
        help="The key name in the JSON response which lists the\nallele URLs to download.",
    )
    parser.add_argument(
        "-suffix",
        dest="asuffix",
        default=".tfa",
        required=False,
        help="What should be the suffix of the downloaded allele\nFASTA.",
    )
    parser.add_argument(
        "-akey",
        dest="allele_fa_key",
        default="alleles_fasta",
        required=False,
        help="What is the key in the JSON response that contains\nthe URL for allele FASTA.",
    )
    parser.add_argument(
        "-id",
        dest="id_key",
        default="id",
        required=False,
        help="What is the key in the JSON response that contains\nthe name of the allele FASTA.",
    )

    args = parser.parse_args()
    org = args.organism
    outdir = os.path.join(args.outdir, org)
    overwrite = args.overwrite
    pubmlst_loc = "_".join(["https://rest.pubmlst.org/db/pubmlst", org, "seqdef"])
    schemes = args.schemes
    profile = args.profile
    loci = args.loci
    suffix = args.asuffix
    allele_fa_key = args.allele_fa_key
    id_key = args.id_key

    if not overwrite and os.path.exists(outdir):
        logging.error(
            f"Output directory\n{os.path.basename(outdir)}\nexists. Please use -f to overwrite."
        )
        exit(1)
    elif overwrite and os.path.exists(outdir):
        shutil.rmtree(outdir, ignore_errors=True)

    # Create required output directory.
    os.makedirs(outdir)

    # Query MLST scheme for an organism.
    pubmlst_json = dl_pubmlst(
        path=outdir,
        url="/".join([pubmlst_loc, schemes]),
        suffix=suffix,
        parent=True,
        filename=False,
        expectjson=True,
    )

    # Save profile_csv as organism.txt.
    if profile in pubmlst_json.keys():
        dl_pubmlst(
            path=outdir,
            url=pubmlst_json[profile],
            suffix=".txt",
            parent=False,
            filename=org,
            expectjson=False,
        )

    # Save MLST alleles' FASTA
    if loci in pubmlst_json.keys():
        for allele in pubmlst_json[loci]:
            allele_fa_json = dl_pubmlst(
                path=outdir,
                url=allele,
                suffix=suffix,
                parent=True,
                filename=False,
                expectJson=True,
            )

            dl_pubmlst(
                path=outdir,
                url=allele_fa_json[allele_fa_key],
                suffix=suffix,
                parent=False,
                filename=allele_fa_json[id_key],
                expectJson=False,
            )

    logging.info(f"Finished downloading MLST scheme and profile for {org}.")


if __name__ == "__main__":
    main()
