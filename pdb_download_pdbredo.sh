#!/usr/bin/env bash

# This script downloads a PDB file from PDB Redo.
URL='https://pdb-redo.eu/db/'$1'/'$1'_final.pdb'
wget $URL
