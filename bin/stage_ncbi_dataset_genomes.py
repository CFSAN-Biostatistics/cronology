#!/usr/bin/env python3

# Kranti Konganti

import argparse
import glob
import inspect
import logging
import os
import pprint
import shutil

# Set logging.
logging.basicConfig(
    format="\n" + "=" * 55 + "\n%(asctime)s - %(levelname)s\n" + "=" * 55 + "\n%(message)s\n\n",
    level=logging.DEBUG,
)

# Debug print.
ppp = pprint.PrettyPrinter(width=50, indent=4)


# Multiple inheritence for pretty printing of help text.
class MultiArgFormatClasses(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


def main() -> None:
    """
    This simple script will take as input a directory and scan for all files matching the
    suffix and will place them in a new directory. Using a script instead of CLI calls for
    predictability and reproducibility on all platforms.
    """

    prog_name = os.path.basename(inspect.stack()[0].filename)

    parser = argparse.ArgumentParser(
        prog=prog_name, description=main.__doc__, formatter_class=MultiArgFormatClasses
    )

    required = parser.add_argument_group("required arguments")

    required.add_argument(
        "-in",
        dest="indir",
        default=False,
        required=True,
        help="Absolute UNIX path to a directory containing the\nfiles to be moved.",
    )
    parser.add_argument(
        "-suffix",
        dest="suffix",
        required=False,
        default="_genomic.fna.gz",
        help="Find files that match the following\nsuffix.",
    )
    parser.add_argument(
        "-out",
        dest="outdir",
        required=False,
        default="unscaffolded",
        help="A new directory will be created and the files matching\n"
        + "the suffix will be moved here",
    )

    args = parser.parse_args()
    indir = os.path.join(os.getcwd(), args.indir)
    outdir = os.path.join(os.getcwd(), args.outdir)
    suffix = args.suffix

    if indir and not os.path.exists(indir):
        logging.error(
            f"The directory,\n{os.path.basename(indir)}\ndoes not exists or is of size zero."
        )
        exit(0)

    genome_files = glob.glob(os.path.join(indir, f"**", f"*{suffix}"), recursive=True)

    if len(genome_files) == 0:
        logging.error(
            f"The directory\n{os.path.basename(indir)}"
            + "\ndoes not contain any files matching the following"
            + f"\nsuffix: {suffix}."
        )
        exit(1)

    if not os.path.exists(outdir):
        os.makedirs(outdir)

    for genome_file in genome_files:
        new_out = os.path.join(outdir, os.path.basename(genome_file))
        try:
            shutil.move(genome_file, new_out)
        except:
            logging.error(f"Moving file failed from\n{genome_file}\nto\n{new_out}")
            exit(1)


if __name__ == "__main__":
    main()
