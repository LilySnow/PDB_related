
pdbID=`echo $1| perl -ne 'print lc($_)'`
wget https://pdb-redo.eu/db/$pdbID/${pdbID}_final.pdb
