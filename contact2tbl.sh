#!/usr/bin/env bash
# Li Xue
#  6-Jul-2018 14:03
#
# INPUT (the 5th and 10th columns are atom number) :
# GLU A     58     CA      2137   ASP D     26     CA      2137   7.92322586
# GLU A     58     CA      2163   GLY D     28     CA      2163   7.68690607

#
# OUTPUT:
# assign ( resid 7  and segid A and name CZ) (resi 2 and segid P and name CA) 4.377 0.5 0.2

contactFL=$1
UB_relax=$2
LB_relax=$3


echo "! generated by $0"
if [ $LB_relax == 'nan' ];then
   # LB_relax == 'nan' means no lower bound

   awk -v ub_relax=$UB_relax '{print "assign (segid " $2 " and resi " $3 " and name  " $4 ") (segid  " $7 " and resi " $8 " and name  " $9 ") " $11 "  " $11 "  " ub_relax}' $contactFL

else
    awk -v lb_relax=$LB_relax -v ub_relax=$UB_relax '{print "assign (segid " $2 " and resi " $3 " and name  " $4 ") (segid  " $7 " and resi " $8 " and name  " $9 ") " $11 "  " lb_relax "  " ub_relax}' $contactFL
fi


