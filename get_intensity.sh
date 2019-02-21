#!/bin/bash -i
#
# use -i flag here to use aliases like fit2d
#
# e.g.
# get_intensity latest_002217[0-8]*.tiff 240 50 280 280 mask.msk
# get_intensity latest_002217[0-8]*.tiff 240 50 280 280 none
# ls latest_002217[0-8]*.tiff | get_intensity - 240 50 280 280 mask.msk for pipes


# fit2d alias must be set, too
# path to Fit2D macro-files
path_to_mac='/home/msmile/Seafile/MartinS/bash/'


# at least 6 input args are required (file(s) rectangle corners and mask)
if (( "$#" < 6 )); then
    echo "At least 6 input arguments needed!"
    echo ""
    echo "Usage (using wildcards and pipes possible):"
    echo ""
    echo "With mask-file:"
    echo "get_intensity <tiff-file(s)> <xmin> <ymin> <xmax> <ymax> <mask-file>"
    echo ""
    echo "Without mask-file use none:"
    echo "get_intensity <tiff-file(s)> <xmin> <ymin> <xmax> <ymax> none"
    echo ""
    echo "Same with pipes:"
    echo "... | get_intensity - <xmin> <ymin> <xmax> <ymax> <mask-file>"
    echo "... | get_intensity - <xmin> <ymin> <xmax> <ymax> none"

    exit
fi


# read files into filelist
filelist=(" ")
i=0
while test $# -gt 5; do
    filelist[i]=$1
    shift
    i=$(($i + 1))
done

# pipe-option for files when using "-" placeholder
if [ "$filelist" == "-" ]; then
    filelist=()
    while read -r line
    do
       filelist=("${filelist[@]}" "$line")
    done
fi

#echo "${filelist[@]}"


# now all files are in filelist and arguments are shifted such that there only 5 args left
if [ "$5" != "none" ] && [ ! -f $5 ] ; then
    echo "Error: mask-file not found. Exit."
    exit
fi


for file in ${filelist[@]}
do
#    printf "$file: "
    if [ ! -f $file ] ; then
	echo "No file(s) exist matching this expression. Continue."
	continue
    fi
	
    if [ "$5" == "none" ]; then
	output=$(fit2d -key -dim1024x1024 -fvar#XMIN=$1 -fvar#YMIN=$2 -fvar#XMAX=$3 -fvar#YMAX=$4 -svar#FILE=$file -mac${path_to_mac}fit2dsumrect_nomask.mac | grep "Total\ intensity")
    else   
	output=$(fit2d -key -dim1024x1024 -fvar#XMIN=$1 -fvar#YMIN=$2 -fvar#XMAX=$3 -fvar#YMAX=$4 -svar#MASK=$5 -svar#FILE=$file -mac${path_to_mac}fit2dsumrect_withmask.mac | grep "Total\ intensity")
    fi

    # only one line left due to grep
    echo $output | sed -e 's/.*Total intensity =\(.*\)(square root.*/\1/' | tr -d ' '
done
