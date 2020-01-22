#!/usr/bin/python
"""
(dummy-)Mutates multiple residues on a PDB-formatted structure.
HADDOCK will then reconstruct the residue according to its topology.

Usage:  python pdb_multimutate.py pdbFL <mutation list file>
        The format of mutation list:
        chain resi resn_wt resn_mut

Example: python pdb_multimutate.py 3mrb.pdb list_mutations
        for mutating residue 7 Serine of chain A to Alanine:
        A 7 SER ALA

Author: {0}
Email: {1}
"""
from __future__ import print_function

import os
import sys
import re

__author__ = "Li Xue; Cunliang Geng; Joao Rodrigues"
__email__ = "me.lixue@gmail.com; gengcunliang@gmail.com; j.p.g.l.m.rodrigues@gmail.com"

USAGE = __doc__.format(__author__, __email__)

def check_input(args):
    """Checks whether to read from stdin/file and validates user input/options."""

    if len(args) == 2:
        if not os.path.isfile(args[0]):
            sys.stderr.write('File not found: ' + args[0] + '\n')
            sys.stderr.write(USAGE)
            sys.exit(1)
    else:
        sys.stderr.write(USAGE)
        sys.exit(1)

def mutate(structure_fhandle, chain, resi, resn_wt, resn_mut):

    mutated_structure = []
    flag = 0 # 0: residue-to-be-mutated NOT found in structure; 1 found.
    atom_set = set(["CA", "C", "O", "N", "CB"]) # keep main chain atoms and CB atom of side chain

    for line in structure_fhandle:
        if line[0:4] == 'ATOM' or line[0:6] == 'HETATM' or line[0:6] == 'ANISOU':
            s_chain = line[21].strip()
            s_resi = line[22:26].strip()
            s_resn = line[17:20].strip()
            s_atom = line[12:16].strip()
            if s_chain == chain and s_resi == resi and s_resn == resn_wt:
                flag = 1

                if s_atom in atom_set:
                    line = line[0:17]+resn_mut+line[20:]
                else:
                    continue
        mutated_structure.append(line)

    if flag ==0:
        sys.stderr.write('WARNING: ' + chain + ":" + resi +":" + resn_wt + ' does NOT exist in the strcuture\n')

    return mutated_structure

def _print_mutants(pdbFL, mutationFL):

    # read pdb file into memory
    f_pdb = open(pdbFL, 'r')
    structure = [l for l in f_pdb]
    f_pdb.close()

    new_pdbFL = os.path.splitext(pdbFL)[0] + '_mutated.pdb'

    # mutate pdb file
    print("Generated mutant files:")
    f_mut = open(mutationFL, 'r')
    for line in f_mut:
        line = re.sub('[\n\r]','', line)
        i = line.split()

        if len(i) == 4:
            chain, resi, resn_wt, resn_mut = i
            print (i)
        else:
            sys.stderr.write('WARNING: Unrecognized mutation format in line "{0}"\n'.format(" ".join(i)))
            continue
        structure = mutate(structure, chain, resi, resn_wt, resn_mut)

    if structure:
        m_file = open(new_pdbFL, 'w')
        print(new_pdbFL + ' generated')
        m_file.write(''.join(structure))
        m_file.close()


if __name__ == "__main__":

    check_input(sys.argv[1:])

    pdbFL = sys.argv[1]
    mutationFL = sys.argv[2]

    _print_mutants(pdbFL, mutationFL)

