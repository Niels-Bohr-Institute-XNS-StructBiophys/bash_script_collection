#!/bin/bash -i
#
# use -i flag here to use aliases like fit2dcorr
#
# e.g. extract_fit2dcorr_call x im_0049386_caz.chi_bkp im_0049388_caz.chi_bkp im_0049391_caz.chi_bkp im_0049401_caz.chi_bkp im_0049407_caz.chi_bkp
# e.g. extract_fit2dcorr_call p im_0049386_caz.chi_bkp im_0049388_caz.chi_bkp

print_help()
{
    echo "Usage (using wildcards possible):"
    echo ""
    echo "Extract and print call:"
    echo "extract_fit2dcorr_call p <file(s)>"
    echo ""
    echo "Extract and execute call:"
    echo "extract_fit2dcorr_call x <file(s)>"

    exit

}



# at least 6 input args are required (file(s) rectangle corners and mask)
if (( "$#" < 2 )); then
	print_help 
fi

if [ $1 != 'p' ] && [ $1 != 'x' ] ; then
	print_help
fi


for ((i=2; i<=$#; i++)); do

	file=${!i}

	if [ ! -f $file ]; then
		echo "Warning: File $file does not exist."
		continue
	fi

	call=$(cat $file | grep "Program called with" | sed -n 's/^.*fit2dcorr /fit2dcorr /p')

	if [ $1 == 'p' ]; then
		echo "$call"
		# printing on next command prompt not yet possible, quite difficult to implement
		#read -e -i "$call" input
	else
		eval "$call"
	fi
done



