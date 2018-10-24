#!/bin/bash
#LI Xue
#Oct. 30th, 2013

atoms='CA,C,N,O'

refe_pdb=$1; #'/data/benchmark/docking-benchmark4/runs-cmrestraints/1A2K/ana_scripts/1A2K_conf1.pdb'
izoneFL=$2; #'/data/benchmark/docking-benchmark4/runs-cmrestraints/1A2K/ana_scripts/1A2K_conf1.izone'
decoy_DIR=$3; #'/data/benchmark/docking-benchmark4/runs-cmrestraints/1A2K/run1/structures/it1'
outputDIR=$4; #'/home/lixue/test'


#refe_pdb='/data/benchmark/docking-benchmark4/runs-cmrestraints/1A2K/ana_scripts/1A2K_conf1.pdb'
#izoneFL='/data/benchmark/docking-benchmark4/runs-cmrestraints/1A2K/ana_scripts/1A2K_conf1.izone'
#decoy_DIR='/data/benchmark/docking-benchmark4/runs-cmrestraints/1A2K/run1/structures/it1'
#outputDIR='/home/lixue/test'


if [ -z $outputDIR ];then
    echo
    echo "Usage: i-rmsd-calc_oneCase refe_pdb izoneFL decoy_DIR output_DIR"
    echo
    exit 1
fi

if [ ! -d $outputDIR ];then
	mkdir -p $outputDIR
fi

if [ ! -e $izoneFL ];then
	echo "$izoneFL does not exist"
	exit 1;
fi

if [ ! -e $refe_pdb ];then
	echo "$refe_pdb does not exist"
fi


#---

irmsd_tmpFL=$outputDIR/i-rmsd.disp
cat /dev/null > $irmsd_tmpFL

for decoy_pdb in `ls $decoy_DIR/*pdb`;do

 	decoyFL_name=`basename $decoy_pdb`
	echo $decoyFL_name >> $irmsd_tmpFL

	echo "decoy: $decoy_pdb"

    #--
    random=$[ 1 + $[ RANDOM % 10 ]]
	decoyPDB_tmp=/tmp/$decoyFL_name.$random.tmp
	#decoyPDB_tmp=$outputDIR/$decoyFL_name.$random.tmp

    #--
    currentDIR=`pwd`
    #cp $decoy_pdb $decoyPDB_tmp
    cd $decoy_DIR
    cp $decoyFL_name $decoyPDB_tmp
	pdb_xsegchain $decoyFL_name > $decoyPDB_tmp
    cd $currentDIR
    #--

	if [ ! -e $decoyPDB_tmp ];then
        echo
		echo "$decoyPDB_tmp does not exist"
		exit 1
	fi



#	profit<< END
    profit<< END | grep 'RMS' |tail -n 1 >>$irmsd_tmpFL
	refe $refe_pdb
	mobi $decoyPDB_tmp
	atom $atoms
	`cat $izoneFL`
	fit
	quit
END

	rm  $decoyPDB_tmp
	#-----

	echo "refe_pdb: $refe_pdb"

	echo "izone: $izoneFL"
	echo "-----------------------"
	echo

done



iRMSDFL=$outputDIR/i-RMSD.dat
if [ -e  $iRMSDFL ];then
	rm $iRMSDFL
fi

awk '{if ($1 == "RMS:") {printf "%8.3f ",$2} else {printf "\n %s ",$1}}' $irmsd_tmpFL |grep pdb |awk '{print $1,$2}' |sort -nk2 >>$iRMSDFL

#rm $decoy_DIR/i-rmsd_xray.disp
echo "$iRMSDFL generated."
#echo  $irmsd_tmpFL
rm $irmsd_tmpFL

