#!/bin/bash
# will read target values from *.log not *.mx

# Tmin
# Tmin <mydir>
# Tmin <mydir> -Chi2Red
# Tmin <mydir> -LogdI
# Tmin . -Chi2Red
# Tmin . -LogdI

# paths do not need to include final "/"

# Add missing final "/" or remove final "/"
#[[ "${STR}" != */ ]] && STR="${STR}/"
#[[ "${STR}" == */ ]] && STR="${STR: : -1}"


mydir=$(pwd)
[[ "${mydir}" != */ ]] && mydir="${mydir}/"
#echo $mydir

if [[ $# -gt 0 && "$1" != "." ]] ; then
	
        mydir="$mydir$1"
	[[ "${mydir}" != */ ]] && mydir="${mydir}/"
fi

echo $mydir

filelist="$mydir*.png"
#echo $filelist

array=()
filelistnew=()

# loop through the files and check which contain the pattern
if [[ $# == 2 ]] ; then
	if [[ "$2" == "-Chi2Red" ]] ; then
		echo "Using Chi2Red function values"
	elif [[ "$2" == "-LogdI" ]] ; then
		echo "Using LogdI function values"
	else
		echo "Unknown target function option. Exit."
		exit
	fi
else
	echo "Using Target function values"
fi


for file in $filelist
do
	#echo $file
        file=${file/".png"/".log"}
	if [ ! -f $file ] ; then
		continue
	fi
    
	if [[ $# == 2 ]] ; then
		if [[ "$2" == "-Chi2Red" ]] ; then
			dummy=`sed -n '/Chi2Red function values = /p' $file | sed -n 's/^.*= //p' | cut -d "," -f1`
		elif [[ "$2" == "-LogdI" ]] ; then
			dummy=`sed -n '/LogdI function values = /p' $file | sed -n 's/^.*= //p' | cut -d "," -f1`
		fi
	else
		dummy=`sed -n '/Target function values = /p' $file | sed -n 's/^.*= //p' | cut -d "," -f1`
	fi

	array=("${array[@]}" $dummy)

	# if not empty add file to filelistnew
	if [ -n "$dummy" ] ; then
		filelistnew=("${filelistnew[@]}" $file)
	fi
done

#echo ${array[@]}
#echo ${filelistnew[@]}

len=${#array[*]}
echo $len

# convert filelist string to array of strings


len2=${#filelistnew[*]}
echo $len2


if [ $len -eq 0 ]
then
	echo "No target values found."
else

	echo ${array[@]}

	pos=0
	min=${array[$pos]}

	i=1
	while [ $i -lt $len ]
	do
	#echo "$i: ${array[$i]}"
	val=`echo "${array[$i]}" `
	if [ $(echo "$min > $val"|bc) -eq 1 ]
	then
	min=$val
	pos=$i
	fi
	let i++
	done

	echo "Min. ==> $min"
	echo "Pos. ==> $pos"
	echo "File ==> ${filelistnew[$pos]}"

fi
