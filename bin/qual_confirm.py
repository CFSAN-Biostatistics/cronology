#!/usr/bin/env python3

# Kranti Konganti

import argparse
import inspect
import logging
import os
import pprint


# Multiple inheritence for pretty printing of help text.
class MultiArgFormatClasses(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


# Main
def main() -> None:
    """
    This script takes as input two files containing non whitespace lines and will
    output lines if it is present in both files.
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
        "-f1",
        dest="file1",
        default=False,
        required=True,
        help="Absolute UNIX path to file no. 1 containing\nnon white space lines.",
    )
    required.add_argument(
        "-f2",
        dest="file2",
        default=False,
        required=True,
        help="Absolute UNIX path to file no. 2 containing\nnon white space lines.",
    )
    parser.add_argument(
        "-out",
        dest="outfile",
        default="accs_passed.txt",
        help="The following output file will be created in\nthe current working directory.",
    )

    args = parser.parse_args()
    f1 = args.file1
    f2 = args.file2
    out = args.outfile
    f1d = dict()
    f2d = dict()

    # Basic checks

    if not (os.path.exists(f1) and os.path.exists(f2)):
        logging.error(
            f"File {os.path.basename(f1)} or" + f"\nFile {os.path.basename(f2)} does not exist."
        )
        exit(1)
    elif not (os.path.getsize(f1) > 0 and os.path.getsize(f2) > 0):
        logging.error(
            f"File {os.path.basename(f1)} or" + f"\nFile {os.path.basename(f2)} is empty."
        )
        exit(1)

    with open(f1, "r") as f1_fh:
        for line in f1_fh:
            f1d[line.strip()] = 1

    with open(f2, "r") as f2_fh:
        for line in f2_fh:
            f2d[line.strip()] = 1

    big = f1d
    small = f2d

    if len(f1d.keys()) < len(f2d.keys()):
        big = f2d
        small = f1d

    with open(out, "w") as out_fh:
        for line in small.keys():
            if line in big.keys():
                out_fh.write(line + "\n")

    f1_fh.close()
    f2_fh.close()
    out_fh.close()


if __name__ == "__main__":
    main()
