#!/bin/bash


# automatically deriving number ranges from patterns: 
# mappar SSS_180x360_P*_*_ST_360_400_N50_OSL.png
# manually set ranges 
# mappar SSS_180x360_P*_*_ST_360_400_N50_OSL.png 4 144 4 144


# paths do not need to include final "/"

# Add missing final "/" or remove final "/"
#[[ "${STR}" != */ ]] && STR="${STR}/"
#[[ "${STR}" == */ ]] && STR="${STR: : -1}"

echo $#

if [[ $# != 1 && $# != 5 ]] ; then
	echo "1 or 5 arguments required" 
	exit
fi






files="$1"
#echo $files


# count number of *-patterns
npat=`echo "$1" | awk -F"*" '{print NF-1}'`

echo $npat

if [[ $npat < 1 ]] ; then
	echo "At least one *-pattern must be inside pattern string $1" 
	exit
fi

# replace * with (.*) for BASH_REMATCH
filepat=`echo "$1" | sed -e 's/\*/\(.\*\)/g'`
echo $filepat

filelist=()
parstrlist=()
parlist=()

minlist=()
maxlist=()

i=0
for file in $files
do
	filelist=("${filelist[@]}" $file)

	[[ $file =~ $filepat ]];
	printf "$i: "
	for (( j=0; j<npat; j++))
	do
		parstrlist[${i},${j}]=${BASH_REMATCH[$((j+1))]}
		printf ${parstrlist[${i},${j}]}
		printf " "

		# remove trailing/leading 0 and convert string to number
		parlist[${i},${j}]=$(($(echo ${parstrlist[${i},${j}]} | sed -e 's/^[0]*//')))

		printf ${parlist[${i},${j}]}
		printf " "

		# initialize minlist and maxlist
		if [[ $i == 0 ]] ; then
			minlist[${j}]=${parlist[0,${j}]}
			maxlist[${j}]=${parlist[0,${j}]}
		else
			if [[ ${parlist[${i},${j}]} -gt ${maxlist[${j}]} ]] ; then
				maxlist[${j}]=${parlist[${i},${j}]}
			fi
			if [[ ${parlist[${i},${j}]} -lt ${minlist[${j}]} ]] ; then
				minlist[${j}]=${parlist[${i},${j}]}
			fi			
		fi
	done
	printf "\n"
	((i++))
done

for (( j=0; j<npat; j++))
do
	printf "$j: ${minlist[${j}]} ${maxlist[${j}]}\n"
done



#echo ${filelist[@]}


echo ${#filelist[@]}


exit

mydir=$(pwd)
[[ "${mydir}" != */ ]] && mydir="${mydir}/"
#echo $mydir

if [[ $# -gt 0 && "$1" != "." ]] ; then
	
        mydir="$mydir$1"
	[[ "${mydir}" != */ ]] && mydir="${mydir}/"
fi



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
