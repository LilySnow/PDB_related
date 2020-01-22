PDB_related
====================
Some handy scripts to process PDB files.


Note
------------
This repository is complementary to the pdb-tools: https://github.com/haddocking/pdb-tools

Installation
------------

``` bash
# To download
git clone https://github.com/LilySnow/PDB_related.git

# To update
cd PDB_related && git pull origin master
```

## How to compile the cpp files:
icc -L/usr/lib64/libstdc++.s0.6 -std=c++0x contact-chainID_allAtoms.cpp -o contact-chainID_allAtoms
