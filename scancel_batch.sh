#!/bin/bash
#
for (( i=$1; i<=$2; i++ ))
do
    echo "scancel $i"
    scancel $i
done
