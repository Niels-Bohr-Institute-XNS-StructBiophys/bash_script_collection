#!/bin/bash
# pdf2ps the selected / all pdf-files in a directory
# optionally rm pdf-files
# pdf2psbatch
# pdf2psbatch -r
# pdf2psbatch -r *0[3-7]*cis.pdf
# pdf2psbatch *0[3-7]*cis.pdf

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
	echo "pdf2ps" $inpf ${inpf/".pdf"/".ps"} 
	pdf2ps $inpf ${inpf/".pdf"/".ps"} 

	if $rmflag ; then
		rm $inpf
	fi
done

