#!/bin/bash
#
# grep -l "MM_1" *.tiff | get_transmission
# ls latest_002217*_caz.tiff | get_transmission
# get_transmission latest_002210*.tiff

if (( "$#" == 0 )); then
    filelist=()
    while read -r line
    do
       filelist=("${filelist[@]}" "$line")
    done
else
    filelist=$@
fi

#echo "${filelist[@]}"

if [ ${#filelist[@]} -eq 0 ]; then
    echo "get_transmission <file(s)>"
    echo "get_transmission supports pipes from stdin"
    exit
fi


for file in ${filelist[@]}
do
    printf "$file: "
    # sed -n 16p $file | sed -n 's/^.*transfact\">//p' | cut -d "<" -f1
    sed -n '/PILATUS/p' $file | sed -n 's/^.*transfact\">//p' | cut -d "<" -f1
done
