#!/usr/bin/env python

"""
Matches PDB chain ID's from a reference file to a match file.

usage: python pdb_match_chains.py <Reference_PDB_file> <Match_PDB_file> <Min_similarity_value>
example: python pdb_match_chains.py ref.pdb 1k5n_final.pdb 70

Author: {0} ({1})

This program takes two PDB files, and matches the chain ID's from the reference PDB file to chain ID's in the PDB that is matched to it.
A match is based on sequence similarity, in which a minimum value between 0 and 100 acts as initial threshold for creating a match.
If the sequence of another chain in the matched PDB file matches a reference PDB chain better, the previous match is replaced.

"""

import sys, os

__author__ = "Daan Sybrandi"

USAGE = "Usage: " + sys.argv[0] + " <Reference_PDB> " + "<To-match_PDB>\n"

min_identity = 70 # Minimum required identity for the sequences of two chains to be matched (on a scale of 0 - 100).
matched_chains = {} # Dictionary that stores reference file chains as keys and matched file chains as values.

# Get the chain ID's found in the reference PDB file (chainsA) and the PDB file that will be matched to it (chainsB).
def get_chain_list(in_file):
    f = open(in_file, "r")
    chain_ids = []
    for line in f.readlines():
        if line[:4] != "ATOM": continue # Only get keys form atom lines.
        if line[21] == ' ': continue # Don't add 'non-chains' to the list.
        chain_ids.append(line[21])
    chain_ids = list(set(chain_ids))
    f.close()
    return chain_ids

args = sys.argv[1:]
if len(args) != 2:
    sys.stderr.write(USAGE)
    sys.exit(1)

chainsA = get_chain_list(sys.argv[1]) # Reference file.
chainsB = get_chain_list(sys.argv[2]) # Matched PDB file.
#print(chainsA)
#print(chainsB)

# Match the sequences of all chains with all the chains in the matched file based on the similarity defined in "min_identity". Better matches replace previous matches.
for chainA in chainsA:
    min_score = min_identity
    for chainB in chainsB:
        try:
            if matched_chains[chainA]:
                pass
        except:
            matched_chains[chainA] = 'None'
        #print('Comparing chain: ' + chainA + ' and:  ' + chainB)
        similarity_score = float(os.popen("$HADDOCKSCRIPTS/pdb-pdbalignscore " + sys.argv[1] + " " + chainA + " " + sys.argv[2] + " " + chainB).readline())
        #print(similarity_score)
        if similarity_score > min_score:
            min_score = similarity_score # Change the min identity to the new best score.
            matched_chains[chainA] = chainB
            #print(matched_chains)
            #print('A new score has been found.')

# Order the chains.
chain_keys = list(matched_chains.keys())
chain_keys.sort()

# Print the chains of the reference file, and the possible matching chain ID in the matched file.
for key in chain_keys:
    print(key + " " + matched_chains[key])
