#!/bin/bash -i
#
# use -i flag here to use aliases like fit2d
#
# e.g.
# export_fit2d_image latest_002217[0-8]*.tiff 40 60 280 197 50 250 mask.msk
# export_fit2d_image latest_002217[0-8]*.tiff 40 60 280 197 50 250 none
# ls latest_002217[0-8]*.tiff | export_fit2d_image - 40 60 280 197 50 250 mask.msk for pipes


# fit2d alias must be set, too
# path to Fit2D macro-files
path_to_mac='/home/msmile/Seafile/MartinS/bash/'


# at least 6 input args are required (file(s) rectangle corners and mask)
if (( "$#" < 8 )); then
	echo "At least 8 input arguments needed!"
	echo ""
	echo "Usage (using wildcards and pipes possible):"
	echo ""
	echo "With mask-file:"
	echo "export_fit2d_image <tiff-file(s)> <xmin> <ymin> <xmax> <ymax> <Imin> <Imax> <mask-file>"
	echo ""
	echo "Without mask-file use none:"
	echo "export_fit2d_image <tiff-file(s)> <xmin> <ymin> <xmax> <ymax> <Imin> <Imax> none"
	echo ""
	echo "Without mask-file and fully automatic intensity scale:"
	echo "export_fit2d_image <tiff-file(s)> <xmin> <ymin> <xmax> <ymax> auto auto none"
	echo ""
	echo "Same with pipes:"
	echo "... | export_fit2d_image - <xmin> <ymin> <xmax> <ymax> <Imin> <Imax> <mask-file>"
	echo "... | export_fit2d_image - <xmin> <ymin> <xmax> <ymax> <Imin> <Imax> none"

	exit
fi


# read files into filelist
filelist=(" ")
i=0
while test $# -gt 7; do
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


# now all files are in filelist and arguments are shifted such that there only 7 args left
if [ "$7" != "none" ] && [ ! -f $7 ] ; then
	echo "Error: mask-file not found. Exit."
	exit
fi


for file in ${filelist[@]}
do
#	printf "$file: "
	if [ ! -f $file ] ; then
	echo "No file(s) exist matching this expression. Continue."
	continue
	fi

	image=${file/".tiff"/".ps"}

	# call fit2d macro

	if [ "$5" == "auto" ]; then
		if [ "$7" == "none" ]; then
		$(fit2d -key -dim1024x1024 -fvar#XMIN=$1 -fvar#YMIN=$2 -fvar#XMAX=$3 -fvar#YMAX=$4 -svar#FILE_IN=$file -svar#FILE_OUT=$image -mac${path_to_mac}fit2d_image_nomask_autoscale.mac)
		else
		$(fit2d -key -dim1024x1024 -fvar#XMIN=$1 -fvar#YMIN=$2 -fvar#XMAX=$3 -fvar#YMAX=$4 -svar#FILE_IN=$file -svar#FILE_OUT=$image -svar#MASK=$7 -mac${path_to_mac}fit2d_image_withmask_autoscale.mac)
		fi
	else
		if [ "$7" == "none" ]; then
		$(fit2d -key -dim1024x1024 -fvar#XMIN=$1 -fvar#YMIN=$2 -fvar#XMAX=$3 -fvar#YMAX=$4 -fvar#MIN=$5 -fvar#MAX=$6 -svar#FILE_IN=$file -svar#FILE_OUT=$image -mac${path_to_mac}fit2d_image_nomask.mac)
		else
		$(fit2d -key -dim1024x1024 -fvar#XMIN=$1 -fvar#YMIN=$2 -fvar#XMAX=$3 -fvar#YMAX=$4 -fvar#MIN=$5 -fvar#MAX=$6 -svar#FILE_IN=$file -svar#FILE_OUT=$image -svar#MASK=$7 -mac${path_to_mac}fit2d_image_withmask.mac)
		fi
	fi



	# use ps2pdf + pdfcrop + convert to png  
	ps2pdfcrop2pngbatch -r $image
done
