#!/usr/bin/python

from Bio.PDB import PDBParser
#from Bio.SCOP.Raf import to_one_letter_code
from Bio.Data.SCOPData import protein_letters_3to1 as to_one_letter_code
import sys
from tempfile import NamedTemporaryFile


if not sys.argv[1:]:
    pdbdata = sys.stdin.readlines()
    tf = NamedTemporaryFile()
    tf.write(''.join(pdbdata))
    pdbf = tf.name
else:
    pdbf = sys.argv[1]


P = PDBParser(QUIET=1)
structure = P.get_structure('s', pdbf)
for chain in structure.get_chains():
    sequence = []
    for res in chain:
      try:
        aa = to_one_letter_code[res.resname]
      except KeyError:
        aa= '.'
      sequence.append(aa)
    print "Chain %s: %s" %(chain.id, ''.join(sequence))
