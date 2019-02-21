#!/bin/bash
# pdfcrop the selected / all pdf-files in a directory
# convert them to png
# optionally rm (temporary) pdf-files
# pdfcrop2pngbatch
# pdfcrop2pngbatch -r
# pdfcrop2pngbatch -r *0[3-7]*cis.pdf
# pdfcrop2pngbatch *0[3-7]*cis.pdf

# default
rmflag=false;
filelist=`ls *.pdf`

echo $#
echo $@

# update with flags and arguments
if (( "$#" > 0 )); then
#	echo "$1"
	if [ "$1" == "-r" ]; then
		rmflag=true
		shift
	fi
	if (( "$#" > 0 )); then
		filelist=$@
	fi
fi

echo $filelist
#echo $rmflag

for inpf in ${filelist[@]}
do
	pdfcrop ${inpf} ${inpf/".pdf"/"_cropped.pdf"}
	convert -density 300 -quality 100 ${inpf/".pdf"/"_cropped.pdf"} ${inpf/".pdf"/"_cropped.png"}

	if $rmflag ; then
		rm $inpf ${inpf/".pdf"/"_cropped.pdf"}
	fi
done

