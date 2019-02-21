#!/bin/bash
# convert selected / all pdf-files in a directory to png
# optionally rm pdf-files
# pdf2pngbatch
# pdf2pngbatch -r
# pdf2pngbatch -r *0[3-7]*cis.pdf
# pdf2pngbatch *0[3-7]*cis.pdf


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
	convert -density 300 -quality 100 ${inpf} ${inpf/".pdf"/".png"}

	if $rmflag ; then
		rm $inpf
	fi
done

