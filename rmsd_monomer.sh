# calculate rmsd between monomer and the target

target_pdbFL=$1
monomer_pdbFL=$2
zoneFL=$3

if [ -z $zoneFL ];then

    echo
    echo "Usage: rmsd_monomer.sh target_pdbFL monomer_pdbFL zoneFL"
    echo
    exit
fi


profit<<END
refe $target_pdbFL
mobi $monomer_pdbFL
atoms C,CA,N,O
`cat $zoneFL`
fit
quit
END



