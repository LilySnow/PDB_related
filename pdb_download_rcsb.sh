#!/usr/bin/env bash

# This script downloads the first biological unit from RCSB.org.

URL='https://files.rcsb.org/download/'$1'.pdb1'
wget $URL
