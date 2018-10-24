#!/bin/bash
# 2017-03-20 11:10:45 CunliangGeng
# Extract haddock score and terms from HADDOCK model

[ $# -ne 1 ] && echo "Usage: ./$0 <HADDOCK model file>" && exit

pdb=$1
pdbID=`basename $pdb`

# echo header
echo -e "pdbID\tEvdw\tEelec\tEdesolv\tBSA"

# extract haddock terms from model PDB
Evdw=`grep -w "REMARK energies" ${pdb} | cut -d "," -f 6 | xargs`
Eelec=`grep -w "REMARK energies" ${pdb} | cut -d "," -f 7 | tr -d [:space:]`
Eair=`grep -w "REMARK energies" ${pdb} | cut -d "," -f 8`
Edesolv=`grep -w "REMARK Desolvation energy" ${pdb} | awk '{print $4}'`
BSA=`grep -w "REMARK buried surface area" ${pdb} | awk '{print $5}'`

echo -e "${pdbID}\t$Evdw\t$Eelec\t$Edesolv\t$BSA"
