#!/bin/env python
# -*- coding: utf-8 -*-
#
# Rsync Recent Files
#
# Copyright (C) 2013, Alex Bennée <alex@bennee.com>
# License: GPLv3
#
# This is a wrapper for rsync to sync a certain amount of files sorted
# by various critera. Think of it a sortable filter for rsync.
#

# for Python3 cleanliness
from __future__ import print_function

from argparse import ArgumentParser
from stat import S_ISREG, ST_CTIME, ST_MTIME, ST_SIZE, ST_MODE
import os, sys, time
import tempfile
import logging
import subprocess
import itertools

logger = logging.getLogger("rsync-recent")

LIMIT_4G=(4 * 1024 ** 3)

#
# Command line options
#
def human_to_size(in_string):
    """
    Convert size prefixed strings to something more usabale

    > human_to_size("10")
    10
    > human_to_size("2k)
    2048
    """

    size_map = { "K" : 1024,
                 "M" : (1024 ** 2),
                 "G" : (1024 ** 3) }

    value = int("".join(itertools.takewhile(str.isdigit, in_string)))

    for suffix, scale in zip(size_map.keys(), size_map.values()):
        if in_string.upper().endswith(suffix):
            value *= scale

    return value

def parse_arguments():
    """
    Read the arguments and return them to main.
    """
    parser = ArgumentParser(description="rsync wrapper script.")

    # Short options
    parser.add_argument('-v', '--verbose', action='count', default=None, help='Be verbose in output')
    parser.add_argument('-q', '--quiet', action='store_false', dest='verbose', help="Supress output")
    parser.add_argument('-l', '--log', default=None, help="output to a log file")
    parser.add_argument('-p', '--dry-run', default=False, action="store_true", help="dry run")

    parser.add_argument('--total-size', default=10000000000, type=human_to_size,
                        help="Maximum total size (default 10Gb)")

    parser.add_argument('--skip-4g', default=False, action="store_true",
                        help="Skip files larger than 4gb (vfat limit)")

    # Positional
    parser.add_argument('source', metavar='SOURCE', type=str, nargs='?',
                        help='source directory')
    parser.add_argument('destination', metavar='DEST', type=str, nargs='?',
                        help='destination directory')

    return parser.parse_args()

def setup_logging(args):
    # setup logging
    if args.verbose:
        if args.verbose == 1: logger.setLevel(logging.INFO)
        if args.verbose >= 2: logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.WARNING)

    if args.log:
        handler = logging.FileHandler(args.log)
    else:
        handler = logging.StreamHandler()

    lfmt = logging.Formatter('%(asctime)s:%(levelname)s - %(name)s - %(message)s')
    handler.setFormatter(lfmt)
    logger.addHandler(handler)

    logger.info("running with level %s" % (logger.getEffectiveLevel()))


if __name__ == "__main__":
    args = parse_arguments()

    #
    setup_logging(args)

    # get sorted list of filenames
    logger.info("%s", args.source)
    src = os.path.abspath(args.source)

    entries = (os.path.join(src, fn) for fn in os.listdir(src))
    entries = ((os.stat(path), path) for path in entries)

    # get regular files with mtime and size
    entries = ((stat[ST_MTIME], stat[ST_SIZE], path)
               for stat, path in entries if S_ISREG(stat[ST_MODE]))

    if args.verbose and args.verbose > 2:
        flist = tempfile.NamedTemporaryFile(mode="w", delete=false)
        logger.info("Saved flist: %s", flist.name)
    else:
        flist = tempfile.NamedTemporaryFile(mode="w")

    total_size = 0

    for mtime, size, path in sorted(entries, reverse=True):
        if args.skip_4g and size > LIMIT_4G:
            continue

        if (total_size + size) < args.total_size:
            total_size += size
            filename = path[len(src)+1:]
            flist.write("%s\n" % (filename))
            logger.debug("added %s as %s, %d, %s" % (path, filename, size, mtime))

    logger.info("Total size: %d bytes", total_size)

    flist.flush()

    cmd = ["rsync" ]
    if args.dry_run:
        cmd.extend(["--dry-run", "--log-file=dryrun.log"])

    cmd.extend(["-av", "--size-only", "--no-relative", "--exclude=*"
                "--delete", "--delete-excluded", "--delete-before"])
    cmd.extend(["--files-from", flist.name])
    cmd.extend([src, args.destination])

    logger.info("cmd: %s", cmd)

    result = subprocess.call(cmd)

    logger.info("Result: %s", result)
