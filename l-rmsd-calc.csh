#!/bin/tcsh -f

# This script is to be used with ANA_RMSD-Split.csh

# EzgiKaraca, 20092011, 6:19PM

set WDIR = $PWD
set refe = $WDIR/$argv[1].pdb
set lzone = $WDIR/$argv[1].lzone
set atoms = 'CA,C,N,O'

foreach i ($argv[2])
  pdb_xsegchain $i >$i:r.tmp1
  echo $i >>l-rmsd_xray.disp
  profit <<_Eod_ |grep RMS |tail -1 >>l-rmsd_xray.disp
    refe $refe
    mobi $i:r.tmp1
    atom $atoms
    `cat $lzone`
    quit
_Eod_
\rm $i:r.tmp1
end
awk '{if ($1 == "RMS:") {printf "%8.3f ",$2} else {printf "\n %s ",$1}}' l-rmsd_xray.disp |grep pdb |awk '{print $1,$2}' >> l-RMSD.dat
rm -rf l-rmsd_xray.disp
