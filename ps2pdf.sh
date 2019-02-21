#!/bin/bash
# ps2pdf the selected / all ps-files in a directory
# optionally rm ps-files
# ps2pdfbatch
# ps2pdfbatch -r
# ps2pdfbatch -r *0[3-7]*cis.ps
# ps2pdfbatch *0[3-7]*cis.ps

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
	echo "ps2pdf" $inpf ${inpf/".ps"/".pdf"} 
	ps2pdf $inpf ${inpf/".ps"/".pdf"} 

	if $rmflag ; then
		rm $inpf
	fi
done


