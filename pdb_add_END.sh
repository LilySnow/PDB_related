#!/usr/bin/env bash
# Li Xue
# 25-Mar-2019 14:58
pdbFL=$1
sed -i '/^END/d' $pdbFL
sed -i -e "\$aEND" $pdbFL
