#!/home/lixue/tools/Anaconda3/bin/python
# coding: utf-8

# In[68]:

# prepare mutation files for pdb_mutate.py

"""
OUTPUT format:
  pdbfile chain resi resn_wt resn_mut
  1A22.pdb A 7 SER ALA
"""

import sys
import os
import re
from subprocess import check_call
from subprocess import check_output

"""
wt_seq = 'NLVPMVHTV'
new_seq = 'LLFGYPVYV'
pdbFL = '3mrb_final.pdb'
template_chnID = 'P'
"""
if len(sys.argv) != 5:
    print("Usage: "+ sys.argv[0] + " template_PDBFL chnID_to_mutate wt_seq new_seq ")
    sys.exit()


pdbFL, template_chnID, wt_seq, new_seq = sys.argv[1:]

Three2One = {'CYS': 'C', 'ASP': 'D', 'SER': 'S', 'GLN': 'Q', 'LYS': 'K',
     'ILE': 'I', 'PRO': 'P', 'THR': 'T', 'PHE': 'F', 'ASN': 'N',
     'GLY': 'G', 'HIS': 'H', 'LEU': 'L', 'ARG': 'R', 'TRP': 'W',
     'ALA': 'A', 'VAL':'V', 'GLU': 'E', 'TYR': 'Y', 'MET': 'M'}


One2Three= {'C':'CYS','D':'ASP','S':'SER','Q':'GLN','K':'LYS','I':'ILE',
            'P':'PRO','T':'THR','F':'PHE','N':'ASN','G':'GLY','H':'HIS',
            'L':'LEU','R':'ARG','W':'TRP','A':'ALA','V':'VAL','E':'GLU','Y':'TYR','M':'MET'}

if len(wt_seq) != len(new_seq):
    print("Error: wt_seq and new_seq have different length!")
    sys.exit()



"""for i in range(len(wt_seq)):
    if wt_seq[i] != new_seq[i]:
        print (One2Three[wt_seq[i]],One2Three[new_seq[i]])"""



# In[69]:

# generate atomResNum file
"""
#chainID,seqnum,aa,atomResnum
P,1,N,1
P,2,L,2
P,3,V,3
"""
templateID = re.sub('.pdb','',pdbFL)
template_atomResNumFL = templateID + '.atomResNum'
command = 'PDB2AtomResNum.pl ' + pdbFL + ' ' + template_chnID + ' > ' + template_atomResNumFL
check_call([command], shell=True)


# In[70]:

# maybe need to delete some of the rows of template_atomResNumFL to make it match wt_seq
"""
OUTPUT format:
  pdbfile chain resi resn_wt resn_mut
  1A22.pdb A 7 SER ALA
"""

print("# generated by " + sys.argv[0])

i =0
f = open(template_atomResNumFL,'r')

for line in f:
    line= re.sub('[\n\r]','',line)
    if re.search('^[^\w]',line) or re.search('^\s*$',line):
        continue

    chnID, seqnum, aa, atomResNum = re.split(',',line)

    if One2Three[wt_seq[i]] == One2Three[new_seq[i]]:
        i=i+1
        continue

    print (pdbFL, template_chnID, atomResNum, One2Three[wt_seq[i]],One2Three[new_seq[i]] )
    i=i+1


