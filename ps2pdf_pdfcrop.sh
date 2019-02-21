#!/bin/bash
# ps2pdf for all selected / all ps-files in a directory
# pdfcrop the selected / all pdf-files
# optionally rm ps and temporary pdf-files
# ps2pdfcropbatch
# ps2pdfcropbatch -r
# ps2pdfcropbatch -r *0[3-7]*cis.ps
# ps2pdfcropbatch *0[3-7]*cis.ps

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

	if $rmflag ; then
		rm $inpf ${inpf/".ps"/".pdf"}
	fi
done

