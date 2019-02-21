#!/bin/bash
# swap or rearrange in an arbitrary way columns for all selected / all *.dat-files in a directory
# copies header lines from input files starting with # to swapped output files (assumes lines starting with # are only in the header)
# !!! -r flag overwrites original files with swapped files !!!
#
# examples:
#
# swap_columns "del" "1243"
# swap_columns "del" "1243" -r
# swap_columns "del" "1243" SAXS*0[2-7]*.dat
# swap_columns "del" "1243" -r SAXS*0[2-7]*.dat
# swap_columns "del" "212433" -r SAXS*0[2-7]*.dat


# default
rmflag=false;
filelist=`ls *.dat`

echo $#
#echo $@

# update with flags and arguments
if (( "$#" > 1 )); then
	del=$1
	pattern=$2
else
	echo "Not enough input. Exit."
	exit
fi


subst="{print "
len_pattern=${#pattern}
len_pattern=$((len_pattern-1))
for ((i=0; i<$len_pattern; i++)); do
	subst+="\$${pattern:$i:1}\"$del\""
done
subst+="\$${pattern:$len_pattern:1}"
subst="$subst}"


echo $subst

if (( "$#" > 2 )); then
	if [ "$3" == "-r" ]; then
		rmflag=true
		shift
	fi

	shift
	shift

	if (( "$#" > 0 )); then
		filelist=$@
	fi
fi


echo $filelist


for inpf in ${filelist[@]}
do
	# calculate how many header lines to skip
	num=`grep -c "^#" $inpf`
	num=$((num+1))
	echo $num

	outpf=${inpf/".dat"/"_swp.dat"}

	echo "tail --lines=+$num $inpf | awk -F \"$del\" \"$subst\" > $outpf"
	
	tail --lines=+$num $inpf | awk -F "$del" "$subst" > $outpf

	# copy all lines from inpf starting with # into header of output file
	lines=`grep -E '^#' $inpf`
	echo -e "$lines\n$(cat $outpf)" > $outpf

	# option to overwrite input with output
	if $rmflag ; then
		mv $outpf $inpf
	fi
done

