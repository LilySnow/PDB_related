#!/usr/bin/env python
# Li Xue
# 27-Sep-2018 10:45
#
# In order for haddock to keep water, change the PDB file to:
#     HETATM OH2 TIP

import sys
import re

pdbFL = sys.argv[1]
f = open(pdbFL,'r')

for line in f:
    line = line.rstrip()
    resiName = line[17:20]
    if (re.search("^(ATOM|HETATM)", line) and resiName == 'HOH'):
        newline = 'HETATM' + line[6:13] + 'OH2 TIP' + line[20:]
        line = newline
    print (line)

f.close()
