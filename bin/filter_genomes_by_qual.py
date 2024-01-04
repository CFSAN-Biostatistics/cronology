#!/usr/bin/env python3

# Kranti Konganti

import argparse
import inspect
import logging
import os
import pprint
import re
from collections import defaultdict

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
    This script will take the TSV output of CheckM2 and GUNC and report the genomes or
    bins that pass the specified filters.
    """

    prog_name = os.path.basename(inspect.stack()[0].filename)

    parser = argparse.ArgumentParser(
        prog=prog_name, description=main.__doc__, formatter_class=MultiArgFormatClasses
    )

    required = parser.add_argument_group("required arguments")

    required.add_argument(
        "-tsv",
        dest="tsv",
        default=False,
        required=True,
        help="Absolute UNIX path to TSV file containing output from\n"
        + "`checkm2 predict` or `gunc run`",
    )
    parser.add_argument(
        "-extract",
        dest="extract",
        required=False,
        default="Name",
        help="Extract this column's value which matches the filters.\n"
        + "Controlled by -fcn and -fcv.",
    )
    parser.add_argument(
        "-exr",
        dest="extract_regex",
        required=False,
        default=r"GC[AF]\_\d+\.?\d*",
        help="The regex group matching the the value of the -extract column\n"
        + "will be the output.",
    )
    parser.add_argument(
        "-fcn",
        dest="filter_col_name",
        default="Completeness_General,Contamination,Completeness_Specific",
        required=False,
        help="Comma separated list of column names on whom the filters\nshould be applied.",
    )
    parser.add_argument(
        "-fcv",
        dest="filter_col_val",
        default="97.5,1,99",
        required=False,
        help="Only rows where the column defined by -fcn\nsatisfies this value will be "
        + "considered.\nThis can be numeric or a string value.\nIf multiple"
        + " column names are mentioned with -fcn,\nthen -fcv should correspond to the number\n"
        + "of columns",
    )
    parser.add_argument(
        "-conds",
        dest="conds",
        default=">=,<=,>=",
        required=False,
        help="Apply conditions on numeric values of -fcn column.\nIf multiple"
        + " column names are mentioned with -fcn and -fcv,\nthen -conds should "
        + "correspond to the same number of -fcn and\n-fcv.",
    )
    parser.add_argument(
        "-outprefix",
        dest="outprefix",
        default="",
        required=False,
        help="The prefix of the output file name.",
    )

    args = parser.parse_args()
    tsv = args.tsv
    ex = args.extract
    exr = re.compile(f"{args.extract_regex}")
    fcn = args.filter_col_name
    fcv = args.filter_col_val
    fcv_pat = re.compile(r"\d*\.?\d+|\,|\w+", re.IGNORECASE)
    fcn_pat = re.compile(r"\w+|\,|\-", re.IGNORECASE)
    outprefix = args.outprefix
    user_def_filters = defaultdict()
    hits = defaultdict()
    passed_accs = set()
    empty_lines = 0
    tsv_sep = "\t"
    csv_sep = ","
    conds = args.conds.split(csv_sep)

    if tsv and (not os.path.exists(tsv) or not os.path.getsize(tsv) > 0):
        logging.error(
            f"The TSV file,\n{os.path.basename(tsv)}\ndoes not exists or is of size zero."
        )
        exit(0)

    if not fcn_pat.match(fcn):
        logging.error(
            f"Supplied columns' names should only be"
            + "\nalphanumeric (including _) separated by a comma."
        )
        exit(1)

    if not fcv_pat.match(fcv):
        logging.error(
            f"Supplied column names' values should only be"
            + "\nalphanumeric (including _) or floating point"
            + "\nseparated by a comma."
        )
        exit(1)

    outfile = os.path.join(
        os.path.dirname(tsv),
        outprefix + re.sub(r"(^.*?)(\.tsv)", r"\1.passed\2", os.path.basename(tsv)),
    )

    with open(tsv, "r") as tsv_fh:
        header_cols = dict(
            [(col, ele) for ele, col in enumerate(tsv_fh.readline().strip().split(tsv_sep))]
        )

        user_def_cols = [col for col in fcn.split(csv_sep) if col in header_cols]
        user_def_col_vals = fcv.split(csv_sep)

        if len(user_def_cols) != len(user_def_col_vals):
            logging.error(
                "Did not find the following columns in the TSV file"
                + f"\n[ {os.path.basename(tsv)} ]:"
                + ",".join([col for col in fcn.split(csv_sep) if col not in header_cols])
            )
            exit(1)
        else:
            for i, _ in enumerate(user_def_cols):
                user_def_filters.setdefault(
                    user_def_cols[i], {"val": user_def_col_vals[i], "cond": conds[i]}
                )

        if ex not in header_cols.keys():
            logging.info(
                f"The header row in file\n{os.path.basename(tsv)}\n"
                + "does not have a column whose names are:\n"
                + f"-extract: {ex}"
            )
            exit(1)

        for line in tsv_fh:
            if line in ["\n", "\n\r"]:
                empty_lines += 1
                continue

            cols = [x.strip() for x in line.strip().split(tsv_sep)]
            for col in user_def_filters.keys():
                if not exr.match(cols[0]):
                    continue
                else:
                    acc = exr.search(cols[0]).group(0)
                    investigate = float(cols[header_cols[col]])
                    investigate_val = float(user_def_filters[col]["val"])
                    cond = user_def_filters[col]["cond"]

                    # print(", ".join([str(investigate), str(investigate_val), cond]))

                    if re.match(r"[\d+\.?]", str(investigate)):
                        if re.match(r">", cond) and investigate >= investigate_val:
                            hits.setdefault(acc, []).append(1)
                        elif re.match(r"<", cond) and investigate <= investigate_val:
                            hits.setdefault(acc, []).append(1)
                    elif investigate == investigate_val:
                        hits.setdefault(acc, []).append(1)
            # ppp.pprint(hits)
            # exit(0)

        if len(hits.keys()) >= 1:
            with open(outfile, "w") as outfile_fh:
                for acc in hits.keys():
                    if sum(hits[acc]) == len(user_def_cols):
                        passed_accs.add(acc)
                outfile_fh.writelines("\n".join(passed_accs) + "\n")
            outfile_fh.close()
        else:
            logging.info("There were no genomes or bins that passed the" + "\nrequired filters.")

        if empty_lines > 0:
            empty_lines_msg = f"Skipped {empty_lines} empty line(s).\n"

            logging.info(
                empty_lines_msg
                + f"File {os.path.basename(tsv)}\n"
                + f"written in:\n{os.getcwd()}\nDone! Bye!"
            )
        exit(0)


if __name__ == "__main__":
    main()
