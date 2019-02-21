#!/bin/bash
#
# replaces multiple spaces with one space and replaces these spaces with underscores
#
# Replacing spaces with underscores in the file names
# for file in *; do mv "$file" `echo $file | tr ' ' '_'` ; done
#
# Replacing spaces with underscores in directories and files
# find -maxdepth 9 -depth -name "* *" -type d | rename 's/ /_/g'
# find -maxdepth 9 -depth -name "* *" -type f | rename 's/ /_/g'


# to handle spaces in filenames set IFS
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

if (( "$#" == 0 )); then
    # read files pipe

    filelist=()
    while read -r line
    do
       filelist=("${filelist[@]}" "$line")
    done
else
    # read files from terminal

    # assume list of files including wildcards - use ($@)
    # https://stackoverflow.com/questions/19458104/how-do-i-pass-a-wildcard-parameter-to-a-bash-file
    filelist=($@)
fi

# echo ${filelist[@]}
echo ${#filelist[@]}
#echo ${filelist[0]}

# check if there are no files from pipe or no from terminal input (2nd check is for unmatched wildcards when reading from terminal)
if [ ${#filelist[@]} -eq 0 ] || [ ! -f ${filelist[0]} ] ; then
    echo "No input files found!"
    echo ""
    echo "Usage (using wildcards and pipes possible):"
    echo ""
    echo "   filename_space_filler <file(s)>"
    echo "   e.g."
    echo "   filename_space_filler *.mp3"
    echo ""
    echo "   ... | filename_space_filler"
    echo "   e.g."
    echo "   ls A130_*.pdf | filename_space_filler"
    exit
fi


for file in ${filelist[@]}
do
    filenew=`echo $file | sed -e 's/  */ /g' | tr ' ' '_'`
    printf "moving  $file  --->  $filenew\n"
    mv $file $filenew 
done

# restore $IFS
IFS=$SAVEIFS
