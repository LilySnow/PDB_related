#!/usr/bin/env python
"""
# Li Xue  (me.lixue@gmail.com)
# 18-Aug-2018 19:10

Remove water (HOH, WAT) from a PDB file.
Usage: python pdb_rmWat.py pdb_file

"""

import sys
import re

USAGE = __doc__.format()

def check_input(args):
    """Checks whether to read from stdin/file and validates user input/options."""

    if not len(args) :
        sys.stderr.write(USAGE)
        sys.exit(1)

if __name__ == '__main__':
    # check input
    check_input(sys.argv[1:])

    # do the job
    pdbFL = sys.argv[1]

    f=open(pdbFL, 'r')

    for line in f:
        line = line.rstrip('\n')

        if re.search('^HETATM', line):
            resi_name = line[17:20]

            if re.search('(HOH|WAT)', resi_name):
                continue

        print(line)

    f.close()


