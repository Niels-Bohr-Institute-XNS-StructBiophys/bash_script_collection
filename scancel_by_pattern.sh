#!/bin/bash
#
# scancel_by_pattern my.*jobname.*patterns

# print squeue with long jobname
# grep those mathcing pattern (grep requires .* !!!)
# replace leading spaces / tabs with scancel or any other command, separate by ";"
# cut out all relevant columns for the composite command
# remove all newlines such that one string is obtained
# remove trailing ";" in string
# assign string to variable cmd
# evaluate cmd
squeue -o "%.18i %.50j" | grep $1

cmd=`squeue -o "%.18i %.50j" | grep $1 | sed -e 's/^[ \t]*/ ; scancel /' | cut -f1,2,3,4 -d" " | tr -d '\n' | sed -e 's/^ ;//'`
eval $cmd
