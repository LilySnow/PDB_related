outFL=$1

if [ -z $outFL ];then
    echo
    echo "Please enter output file "
    echo

    exit
fi

printf "# " >> $outFL
date >> $outFL
echo "# Li Xue" >> $outFL
echo "$outFL generated"
