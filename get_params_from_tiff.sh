#!/bin/bash
#

if [ "$#" -lt 1 ]; then
	echo "Print list of parameters for a list of files (allows wildcards and patterns):"
	echo "     get_params_from_tiff <list of files> -c 4 72 -d '  ' -p <list of params>"
	echo "e.g. get_params_from_tiff im_0049492_caz.tiff im_0049495_caz.tiff -p vp1 vg1 zkstage -c 8 80"
	echo "e.g. get_params_from_tiff im_00494{8[2-4],9[0-3]}_caz.tiff -d '\t' -p vp1 vg1 zkstage"
	echo ""
	echo "Note that the -c, -d and -p options must stand after list of filenames an can be placed in any order"
	echo "     -c min_char_per_col max_char_per_col (min-max number of characters per column, default is 4 72)"
	echo "     -d col_del                           (column delimiter string, e.g. '\t', ',', ';', default is '  ')"
	echo ""
	echo "List all available parameters for one file:"
	echo "     get_params_from_tiff <file>"
	echo "e.g. get_params_from_tiff im_0049492_caz.tiff"
	exit
fi



# min -g 3 2 5 1
# max -g 1.5 5.2 2.5 1.2 5.7
# min -h 25M 13G 99K 1098M
# max -d "Lorem" "ipsum" "dolor" "sit" "amet"
# min -M "OCT" "APR" "SEP" "FEB" "JUL"
min() {
	printf "%s\n" "${@:2}" | sort "$1" | head -n1
}
max() {
	# using sort's -r (reverse) option - using tail instead of head is also possible
	min ${1}r ${@:2}
}



# check and assign input
col_del="  "
min_char_per_col=4
max_char_per_col=72
	
filelist=()
paramlist=()
file_instead_of_param=true
for ((i=1; i<=$#; i++)); do

	# check for -p flag
	if [ "${!i}" == "-p" ]; then
		file_instead_of_param=false
		continue
	fi

	# check for -c flag
	if [ "${!i}" == "-c" ]; then
		i=$((i+1))
		min_char_per_col=${!i}
		i=$((i+1))
		max_char_per_col=${!i}
		continue
	fi

	# check for -d flag
	if [ "${!i}" == "-d" ]; then
		i=$((i+1))
		col_del=${!i}
		continue
	fi

	# read input args either into filelist or paramlist
	if $file_instead_of_param ; then
		if [ ! -f ${!i} ]; then
			echo "File ${!i} does not exist."
			exit
		fi
		filelist=(${filelist[@]} ${!i})
	else
		paramlist=(${paramlist[@]} ${!i})
	fi
done

echo ${filelist[@]}
echo ""
echo ${paramlist[@]}
echo ""
echo "'$col_del'"
echo $min_char_per_col
echo $max_char_per_col


# print output
if [ "$#" -ge 2 ]; then
	# create matrix of filenames and parameters
	colwidthlist=()
	for ((i=0; i<=${#paramlist[@]}; i++)); do
		# colwidthlist=(${colwidthlist[@]} $min_char_per_col)
		colwidthlist[$i]=$min_char_per_col
	done

	# echo ${colwidthlist[@]}

	# find lengths of param cols from lengths of param name
	col_index=0
	for param in ${paramlist[@]}
	do
		col_index=$((col_index+1))
		colwidthlist[$col_index]="$(max -g ${colwidthlist[$col_index]} ${#param})"
	done

	echo ${colwidthlist[@]}

	for file in ${filelist[@]}
	do
		col_index=0
		# find longest file name in 1st col
		colwidthlist[$col_index]="$(max -g ${colwidthlist[$col_index]} ${#file})"

		# update lengths of param cols from lengths of entries in param fields
		for param in ${paramlist[@]}
		do
			col_index=$((col_index+1))

			val=`sed -n '/PILATUS/p' $file | sed -n "s/^.*name=\"$param\">//p" | cut -d "<" -f1`
			val="$val"
			colwidthlist[$col_index]="$(max -g ${colwidthlist[$col_index]} ${#val})"
		done
	done

	echo ${colwidthlist[@]}

	# truncate column lengths if too long
	for ((i=0; i<=${#paramlist[@]}; i++)); do
		colwidthlist[$i]="$(min -g ${colwidthlist[$i]} $max_char_per_col)"
	done

	echo ${colwidthlist[@]}
	printf '\n'

	# print header line
	col_index=0
	printf "%-${colwidthlist[$col_index]}s" "FILE"
	for param in ${paramlist[@]}
	do
		col_index=$((col_index+1))
		dummy=$(printf '%s' $col_del)
		printf $dummy
		
		if [ ${#param} -gt ${colwidthlist[$col_index]} ]; then
				val=${param:0:colwidthlist[$col_index]}
		else
			val=$param
		fi
		printf "%-${colwidthlist[$col_index]}s" "$val"
	done
	printf '\n'
	printf '\n'

	# print file-param matrix
	for file in ${filelist[@]}
	do
		col_index=0
		if [ ${#file} -gt ${colwidthlist[$col_index]} ]; then
				val=${file:0:colwidthlist[$col_index]}
		else
			val=$file
		fi
		printf "%-${colwidthlist[$col_index]}s" "$val"

		for param in ${paramlist[@]}
		do
			col_index=$((col_index+1))

			val=`sed -n '/PILATUS/p' $file | sed -n "s/^.*name=\"$param\">//p" | cut -d "<" -f1`
			val="$val"
			if [ ${#val} -gt ${colwidthlist[$col_index]} ]; then
				val=${val:0:colwidthlist[$col_index]}
			fi
			dummy=$(printf '%s' $col_del)
			printf $dummy
			printf "%-${colwidthlist[$col_index]}s" "$val"
		done
		printf '\n'

	done

	printf '\n'
else
	# print specific line, create newline after each </param>, kill for each line all text until incl <param name=" pattern, replace "> with " = "
	sed -n '/PILATUS/p' ${filelist[0]} | sed 's/<\/param>/\n/g' | sed -n 's/^.*<param name="//p' | sed 's/">/ = /g'
fi
