#!/bin/bash
# Li Xue
# 16-Jun-2018 21:28

# Determine HIS protonation states using `reduce`
#
# HISD: the imino proton is attached to the ND1 nitrogen
# HISE: the imino proton is attached to the NE2 nitrogen

pdbFL=$1

if [ -z $pdbFL ];then
   echo "Usage: bash HIS_proto.sh pdb_FL"
   exit
fi


/home/software/bin/reduce -FLIP -Quiet $pdbFL > $pdbFL.reduce_flip

perl -nle 'if (/HD1.+(HIS|HID|HIE)+.+new/){print $_}' $pdbFL.reduce_flip |perl -nle '$res_name=substr($_, 17, 3); $chnID = substr($_,21,1); $res_num = substr($_, 22, 5); $res_num =~s/\s+//g; print "$res_name:$chnID:$res_num"' |sort -u > $pdbFL.HISD

perl -nle 'if (/HE2.+(HIS|HID|HIE)+.+new/){print $_}' $pdbFL.reduce_flip |perl -nle '$res_name=substr($_, 17, 3); $chnID = substr($_,21,1); $res_num = substr($_, 22, 5); $res_num =~s/\s+//g; print "$res_name:$chnID:$res_num"' |sort -u > $pdbFL.HISE

echo
echo
echo "$pdbFL.reduce_flip generated"
echo "$pdbFL.HISD generated"
echo "$pdbFL.HISE generated"

