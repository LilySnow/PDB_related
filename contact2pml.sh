#!/usr/bin/env bash
# Li Xue
#  6-Jul-2018 14:03
#
# INPUT (the 5th and 10th columns are atom number) :
# GLU A     58     CA      2137   ASP D     26     CA      2137   7.92322586
# GLU A     58     CA      2163   GLY D     28     CA      2163   7.68690607
#
# OUTPUT (xxx.pml):
# distance pair1, resid 7  and chain  A and name CZ, resi 2 and chain P and name CA

contactFL=$1

awk '{print "distance pair_" NR ", resi " $3 " and chain  " $2 " and name  " $4 ", resi " $8 " and chain  " $7 " and name  " $9 }' $contactFL


