#!/bin/bash
#
# grep -l "C12C12IM-BF4" *.tiff | get_temperature
# ls latest_002217*_caz.tiff | get_temperature
# get_temperature latest_002210*.tiff

if (( "$#" == 0 )); then
    filelist=()
    while read -r line
    do
       #printf "do something with $line\n"
       filelist=("${filelist[@]}" "$line")
    done
else
    filelist=$@
fi

#echo "${filelist[@]}"

if [ ${#filelist[@]} -eq 0 ]; then
    echo "get_temperature <file(s)>"
    echo "get_temperature supports pipes from stdin"
    exit
fi


for file in ${filelist[@]}
do
    printf "$file: "
    sed -n '/PILATUS3 300K-500Hz/p' $file | sed -n 's/^.*T=//p' | cut -d "<" -f1
done
