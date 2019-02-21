#!/bin/bash
# ./chlbatch

$MYDIR=pwd

DIRS=`ls -l $MYDIR | egrep '^d' | awk '{print $9}'`

# loop through the directories
for DIR in $DIRS
do
    echo ${DIR}
    cd ${DIR}
    NUMFILES=$(ls *Zone*.txt 2> /dev/null | wc -l)
    echo $NUMFILES
    if [ "$NUMFILES" -gt 0 ]
    then
	/home/guest/bash/chl.sh 1 9 *Zone*.txt
    else
	echo "directory has no txt-files"
    fi
    cd ..
done
