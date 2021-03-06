
# Li Xue
# April 15th, 2015

# calculate residue pair contacts for all the pdb under a folder

decoyDIR=$1
outputDIR=$2
distThr=$3


if [[ -z $decoyDIR || -z $outputDIR || -z $distThr ]];then
    echo
    echo "USAGE: residuepairContacts.sh pdbFL_DIR outputDIR distThr"
    echo
    exit 1
fi

if [ ! -d $decoyDIR ];then
    echo
    echo "ERROR: decoyDIR $decoyDIR does not exist !!"
    echo
    exit 1
fi

if [ ! -d $outputDIR ];then
    mkdir -p $outputDIR
fi

for i in `ls $decoyDIR/*pdb`;do
#for i in "$decoyDIR/1AKJ_396w.pdb";do
    echo $i
    filename=`basename $i '.pdb'`

    #--add chain ID
    currentDIR=`pwd`
    cd `dirname $i`
    pdbFL_tmp="/tmp/$filename.pdb.tmp"
    pdb_xsegchain $filename.pdb > $pdbFL_tmp
    cd $currentDIR


    #--
    contact-chainID_new $pdbFL_tmp $distThr > $outputDIR/$filename.atom_contacts
    printf "#generated by $0 with pdbFL= $i and distThr = $distThr\n" > $outputDIR/$filename.contacts
    removeAtomFromContactFL $outputDIR/$filename.atom_contacts >> $outputDIR/$filename.contacts

    #-- clean up
    rm $outputDIR/$filename.atom_contacts
    rm $pdbFL_tmp
done

#-- write REAME file
README="$outputDIR/README"
echo "This folder is generated by $0 $1 $2 " > $README


#--
echo "$outputDIR generated."


