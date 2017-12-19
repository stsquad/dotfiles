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

    for suffix, scale in size_map.iteritems():
        if in_string.upper().endswith(suffix):
            value *= scale

    return value

def parse_arguments():
    """
    Read the arguments and return them to main.
    """
    parser = ArgumentParser(description="rsync wrapper script.")

    # Short options
    parser.add_argument('-q', '--quiet', default=None, action="store_true",
                        help="Supress all output")

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


if __name__ == "__main__":
    args = parse_arguments()

    # get sorted list of filenames
    print ("%s" % args.source)
    src = os.path.abspath(args.source)

    entries = (os.path.join(src, fn) for fn in os.listdir(src))
    entries = ((os.stat(path), path) for path in entries)

    # get regular files with mtime and size
    entries = ((stat[ST_MTIME], stat[ST_SIZE], path)
               for stat, path in entries if S_ISREG(stat[ST_MODE]))

    flist = tempfile.NamedTemporaryFile()
    total_size = 0

    for mtime, size, path in sorted(entries, reverse=True):
        if args.skip_4g and size > LIMIT_4G:
            continue

        total_size += size
        if total_size < args.total_size:
            flist.write("%s\n" % (path[len(src):]))
            logger.debug("%s, %d, %s" % (path, size, mtime))

    logger.info("Total size: %d bytes", total_size)

    flist.flush()
    result = subprocess.call(["rsync", "-av", "--size-only", "--no-relative",
                              "--files-from",
                              flist.name, src, args.destination])
