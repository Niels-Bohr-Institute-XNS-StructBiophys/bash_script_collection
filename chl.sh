#!/bin/bash
# Comment out lines with #
# Usage
# e.g. chl 1 18 *Zone_0*.txt 
#      chl 897 930 d_00{178..199}.tiff.diff 
#      chl -r 5 9 *Zone_0*.txt 
remflag=0
echo $*
if [[ "$1" == "-r" ]]
then
    remflag=1
    shift
fi
minline=$1
shift
maxline=$1
shift
echo $*
echo $minline
echo $maxline
echo $remflag
# allow white space in filenames by changing the IFS variable
# http://mindspill.net/computing/linux-notes/using-the-bash-ifs-variable-to-make-for-loops-split-with-non-whitespace-characters/

ifs=$IFS
IFS=','

if [ $remflag -eq 0 ]
then
    #sed -i -e ''$minline','$maxline's/^/#/' $*
    sed -i ''$minline','$maxline's/^/#/' $*
    sed -i ''$minline','$maxline's/^#*/#/' $*
else
    sed -i ''$minline','$maxline's/^#*//g' $*
fi

unset IFS
