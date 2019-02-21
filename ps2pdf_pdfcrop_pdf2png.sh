#!/bin/bash
# ps2pdf for selected / all *.ps files in a directory
# pdfcrop the *.pdf
# convert them to png
# optionally rm ps and temporary pdf-files
# ps2pdfcrop2pngbatch
# ps2pdfcrop2pngbatch -r
# ps2pdfcrop2pngbatch -r *0[3-7]*cis.ps
# ps2pdfcrop2pngbatch *0[3-7]*cis.ps

# default
rmflag=false;
filelist=`ls *.ps` 

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
	ps2pdf $inpf ${inpf/".ps"/".pdf"}
	pdfcrop ${inpf/".ps"/".pdf"} ${inpf/".ps"/"_cropped.pdf"}
	convert -density 300 -quality 100 ${inpf/".ps"/"_cropped.pdf"} ${inpf/".ps"/"_cropped.png"}

	if $rmflag ; then
		rm $inpf ${inpf/".ps"/".pdf"} ${inpf/".ps"/"_cropped.pdf"}
	fi
done
