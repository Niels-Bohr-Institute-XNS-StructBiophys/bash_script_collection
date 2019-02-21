#!/bin/bash
#
# grep -l "MM_1" *.tiff | get_meas_descript
# ls latest_002217*_caz.tiff | get_meas_descript
# get_meas_descript latest_002210*.tiff

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
    echo "get_meas_descript <file(s)>"
    echo "get_meas_descript supports pipes from stdin"
    exit
fi


for file in ${filelist[@]}
do
    printf "$file: "
    sed -n '/PILATUS/p' $file | sed -n 's/^.*Meas.Description\">//p' | cut -d "<" -f1
done
