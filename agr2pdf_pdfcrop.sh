#!/bin/bash
# agr2pdf for selected / all *.agr files in a directory
# pdfcrop the *.pdf
# conert cropped pdf to png
# optionally rm ps and temporary pdf-files
# agr2pdfcropbatch
# agr2pdfcropbatch -r
# agr2pdfcropbatch -r *0[3-7]*cis.agr
# agr2pdfcropbatch *0[3-7]*cis.agr

# default
rmflag=false;
filelist=`ls *.agr`

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
	gracebat -printfile ${inpf/".agr"/".ps"} $inpf
	# gracebat -hdevice EPS -printfile ${inpf/".agr"/".ps"} $inpf
	# gracebat -hdevice PNG -printfile ${inpf/".agr"/".ps"} $inpf

	# ps -> pdf
	ps2pdf ${inpf/".agr"/".ps"} ${inpf/".agr"/".pdf"}

	# since recent updates requires rotation ...
	#pdf270 ${inpf/".agr"/".pdf"}
	#mv ${inpf/".agr"/"-rotated270.pdf"} ${inpf/".agr"/".pdf"}

	# crop
	pdfcrop ${inpf/".agr"/".pdf"} ${inpf/".agr"/"_cropped.pdf"}

	# pdf -> png
	convert -density 300 -quality 100 ${inpf/".agr"/"_cropped.pdf"} ${inpf/".agr"/"_cropped.png"}

	if $rmflag ; then
		rm  ${inpf/".agr"/".ps"} ${inpf/".agr"/".pdf"}
	fi
done
