#!/bin/bash -i
#
# use -i flag here to use aliases like fit2d
#
# e.g.
# export_fit2d_image im_002217[0-8]_caz.tiff 40 60 280 197 50 250 log mask.msk im_0022169_caz.tiff
# export_fit2d_image im_002217[0-8]*.tiff 40 60 280 197 50 250 lin none none
# for pipes (e.g. with ls):
# ls im_002217[0-8]*.tiff | export_fit2d_image - 40 60 280 197 50 250 log mask.msk none
# ls *.tiff | export_fit2d_image - 1 1 487 619 auto auto log ../masks/2mm-offcen.msk none

# fit2d alias must be set, too
# path to Fit2D macro-files
path_to_mac='/home/msmile/Seafile/MartinS/bash/'


# at least 10 input args are required (file(s) rectangle corners and mask)
if (( "$#" < 10 )); then
	echo "At least 10 input arguments needed!"
	echo ""
	echo "Usage (using wildcards and pipes possible):"
	echo ""
	echo "With mask-file:"
	echo "export_fit2d_image <tiff-file(s)> <xmin> <ymin> <xmax> <ymax> <Imin> <Imax> <linlog> <mask-file> <background-file>"
	echo ""
	echo "Without mask-file and background-file use none each:"
	echo "export_fit2d_image <tiff-file(s)> <xmin> <ymin> <xmax> <ymax> <Imin> <Imax> <linlog> none none"
	echo ""
	echo "Without mask-file and background-file and fully automatic intensity scale:"
	echo "export_fit2d_image <tiff-file(s)> <xmin> <ymin> <xmax> <ymax> auto auto <linlog> none none"
	echo ""
	echo "Same with pipes:"
	echo "... | export_fit2d_image - <xmin> <ymin> <xmax> <ymax> <Imin> <Imax> <linlog> <mask-file> <background-file>"
	echo "... | export_fit2d_image - <xmin> <ymin> <xmax> <ymax> <Imin> <Imax> <linlog> none none"
	echo "... | export_fit2d_image - <xmin> <ymin> <xmax> <ymax> ... "
	echo ""
	echo "<linlog>: log or lin for logarithmic or linear intensity scale"
	echo ""
	exit
fi


# read files into filelist
filelist=(" ")
i=0
while test $# -gt 9; do
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


# now all files are in filelist and arguments are shifted, we have $1...$9
# list all args
i=1
for j in $*; do
	echo "$i: $j"
	i=$(($i + 1))
done

# intensity scale
if [ "$7" == "lin" ]; then
	scale="LINEAR SCALE"
elif [ "$7" == "log" ]; then
	scale="LOG SCALE"
else
	echo "Error: <linlog> argument is $7. It must be either lin or log. Exit."
	exit
fi

# mask
if [ "$8" != "none" ] && [ ! -f $8 ] ; then
	echo "Error: mask-file not found. Exit."
	exit
fi

# background subtraction
if [ "$9" != "none" ] && [ ! -f $9 ] ; then
	echo "Error: background-file not found. Exit."
	exit
fi

if [ "$9" == "none" ] ; then
	subtr=""
else
	subtr=${9/".tiff"/""}
	subtr="-$subtr"
fi
echo "subtr=$subtr"


for file in ${filelist[@]}
do
#	printf "$file: "
	if [ ! -f $file ] ; then
	echo "No file(s) exist matching this expression. Continue."
	continue
	fi

	# get image and mask basename, strip file type endings
	image=`echo $(basename "$file")`
	image=${image/".tiff"/""}
	#echo $image

	mask=`echo $(basename "$8")`
	mask=${mask/".msk"/""}
	#echo $mask

	image="${image}${subtr}_$1_$2_$3_$4_$5_$6_$7_$mask.ps"
	echo "image=$image"

	# call fit2d macro
	if [ "$5" == "auto" ]; then
		if [ "$8" == "none" ]; then
			if [ "$9" == "none" ]; then
				$(fit2d -key -dim1024x1024 -fvar#XMIN=$1 -fvar#YMIN=$2 -fvar#XMAX=$3 -fvar#YMAX=$4 -svar#SCALE=$scale -svar#FILE_IN=$file -svar#FILE_OUT=$image -mac${path_to_mac}fit2d_image_nomask_nosubtr_autoscale.mac)
			else
				$(fit2d -key -dim1024x1024 -fvar#XMIN=$1 -fvar#YMIN=$2 -fvar#XMAX=$3 -fvar#YMAX=$4 -svar#SCALE=$scale -svar#FILE_IN=$file -svar#FILE_OUT=$image -svar#SUBTR=$9 -mac${path_to_mac}fit2d_image_nomask_withsubtr_autoscale.mac)
			fi
		else
			if [ "$9" == "none" ]; then
				$(fit2d -key -dim1024x1024 -fvar#XMIN=$1 -fvar#YMIN=$2 -fvar#XMAX=$3 -fvar#YMAX=$4 -svar#SCALE=$scale -svar#FILE_IN=$file -svar#FILE_OUT=$image -svar#MASK=$8 -mac${path_to_mac}fit2d_image_withmask_nosubtr_autoscale.mac)
			else
				$(fit2d -key -dim1024x1024 -fvar#XMIN=$1 -fvar#YMIN=$2 -fvar#XMAX=$3 -fvar#YMAX=$4 -svar#SCALE=$scale -svar#FILE_IN=$file -svar#FILE_OUT=$image -svar#MASK=$8 -svar#SUBTR=$9 -mac${path_to_mac}fit2d_image_withmask_withsubtr_autoscale.mac)
			fi
		fi
	else
		if [ "$8" == "none" ]; then
			if [ "$9" == "none" ]; then
				$(fit2d -key -dim1024x1024 -fvar#XMIN=$1 -fvar#YMIN=$2 -fvar#XMAX=$3 -fvar#YMAX=$4 -fvar#MIN=$5 -fvar#MAX=$6 -svar#SCALE=$scale -svar#FILE_IN=$file -svar#FILE_OUT=$image -mac${path_to_mac}fit2d_image_nomask_nosubtr.mac)
			else
				$(fit2d -key -dim1024x1024 -fvar#XMIN=$1 -fvar#YMIN=$2 -fvar#XMAX=$3 -fvar#YMAX=$4 -fvar#MIN=$5 -fvar#MAX=$6 -svar#SCALE=$scale -svar#FILE_IN=$file -svar#FILE_OUT=$image -svar#SUBTR=$9 -mac${path_to_mac}fit2d_image_nomask_withsubtr.mac)
			fi
		else
			if [ "$9" == "none" ]; then
				$(fit2d -key -dim1024x1024 -fvar#XMIN=$1 -fvar#YMIN=$2 -fvar#XMAX=$3 -fvar#YMAX=$4 -fvar#MIN=$5 -fvar#MAX=$6 -svar#SCALE=$scale -svar#FILE_IN=$file -svar#FILE_OUT=$image -svar#MASK=$8 -mac${path_to_mac}fit2d_image_withmask_nosubtr.mac)
			else
				$(fit2d -key -dim1024x1024 -fvar#XMIN=$1 -fvar#YMIN=$2 -fvar#XMAX=$3 -fvar#YMAX=$4 -fvar#MIN=$5 -fvar#MAX=$6 -svar#SCALE=$scale -svar#FILE_IN=$file -svar#FILE_OUT=$image -svar#MASK=$8 -svar#SUBTR=$9 -mac${path_to_mac}fit2d_image_withmask_withsubtr.mac)
			fi
		fi
	fi

	ps2pdf $image ${image/".ps"/".pdf"}
	pdfcrop ${image/".ps"/".pdf"} ${image/".ps"/"_cropped.pdf"}
	convert -density 300 -quality 100 ${image/".ps"/"_cropped.pdf"} ${image/".ps"/".png"}
	rm $image ${image/".ps"/".pdf"} ${image/".ps"/"_cropped.pdf"}
done
