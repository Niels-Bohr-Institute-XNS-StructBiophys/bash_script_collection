#!/bin/bash


# automatically deriving number ranges from patterns, providing only dx and dy: 
# mappar "SSS_180x360_P*_*_ST_360_400_N50_OSL.png" 4 4
# manually set ranges xmin:dx:xmax and ymin:dy:ymax and use an extra pattern (#, ignored for mapping)
# mappar "SSS_180x360_P*_*_ST_#_N50_OSL.png" 4 4 144 4 4 144


# troubleshooting
verbose=0
#verbose=1


# paths do not need to include final "/"

# Add missing final "/" or remove final "/"
#[[ "${STR}" != */ ]] && STR="${STR}/"
#[[ "${STR}" == */ ]] && STR="${STR: : -1}"



# input args check
if [[ $# != 3 && $# != 7 ]] ; then
	echo "No. of argumnet is $#. 3 or 7 arguments are required." 
	exit
fi




#################
# pattern stuff #
#################

# count number of *-patterns
npat=`echo "$1" | awk -F"*" '{print NF-1}'`
if [[ $verbose -eq 1 ]] ; then
	echo "npat = $npat"
	echo ""
fi

if [[ $npat != 2 ]] ; then
	echo "Two *-pattern must be inside pattern string $1" 
	exit
fi

# get a string withy only * and # as ordered in $1
patstr=`echo "$1" | sed "s/[a-zA-Z0-9_.]//g"`
if [[ $verbose -eq 1 ]] ; then
	echo "patstr = $patstr"
	echo ""
fi

# get positions of * in $patstr, save in ${pos[@]} array
pos1=0
while [[ "${patstr:pos1:1}" != "*" &&  pos1 < ${#patstr} ]]
do
	(( $pos1++ ))
done

pos2=$((pos1+1))
while [[ "${patstr:pos2:1}" != "*" &&  pos2 < ${#patstr} ]]
do
	(( $pos2++ ))
done

pos=($pos1 $pos2)
if [[ $verbose -eq 1 ]] ; then
	echo "pos = ${pos[@]}"
	echo ""
fi


# replace # with * and get all files matching pattern
files=`echo "$1" | sed -e 's/\#/\\*/g'`
if [[ $verbose -eq 1 ]] ; then
	echo "files = $files"
	echo ""
fi

# replace * with (.*) for BASH_REMATCH
filepat=`echo "$1" | sed -e 's/\*/\(.\*\)/g ; s/\#/\(.\*\)/g'`
if [[ $verbose -eq 1 ]] ; then
	echo "filepat = $filepat"
	echo ""
fi





#####################################################
# generate ranges of x and y from filepat and files #
#####################################################

filelist=()
declare -A parstrlist
declare -A parlist

minlist=()
maxlist=()

i=0
for file in $files
do
	filelist=("${filelist[@]}" $file)

	# following cmd will generate ${BASH_REMATCH[@]} array from that comparison
	[[ $file =~ $filepat ]];

	if [[ $verbose -eq 1 ]] ; then
		printf "$i: ${BASH_REMATCH} "
	fi

	# loop over all *-patterns with the help of pos and BASH_REMATCH
	for (( j=0; j<npat; j++ ))
	do
		
		parstrlist[${i},${j}]=${BASH_REMATCH[$((pos[$j]+1))]}

		# remove trailing/leading 0 and convert string to number
		parlist[${i},${j}]=$(($(echo ${parstrlist[${i},${j}]} | sed -e 's/^[0]*//')))

		if [[ $verbose -eq 1 ]] ; then
			printf ${parstrlist[${i},${j}]}
			printf " "

			printf ${parlist[${i},${j}]}
			printf " "
		fi


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

	if [[ $verbose -eq 1 ]] ; then
		printf "\n"
	fi

	((i++))
done

if [[ $verbose -eq 1 ]] ; then
	echo ""

	for (( j=0; j<npat; j++))
	do
		printf "j minlist[j] maxlist[j] = $j ${minlist[${j}]} ${maxlist[${j}]}\n"
	done
	echo ""

	echo "Length of filelist = ${#filelisLentgt[@]}"
	echo ""
	#i=0
	#for file in $files
	#do
	#	echo "${i} ${parlist[${i},0]} ${parlist[${i},1]}"
	#	((i++))
	#done

	echo "file ext in file pat = ${filepat:(-4)}"
	echo ""
fi



##################################
# find minimum of Tmin for *.png #
##################################

BMFmode=0;
# applied some changes as to code for Tmin script, here Tminarray is an arry of floats instead of strings
if [[ "${filepat:(-4)}" == ".png" ]] ; then

	BMFmode=1;
	maxselTminfac=1.2
	Tminsel="Target function values"

	if [[ "$Tminsel" == "Chi2Red" ]] ; then
		echo "Using Chi2Red function values"
	elif [[ "$Tminsel" == "LogdI" ]] ; then
		echo "Using LogdI function values"
	elif [[ "$Tminsel" == "Target function values" ]] ; then
		echo "Using Target function values"
	else
		echo "Unknown target function option. Exit."
		exit
	fi
	echo ""


	#Tminarray=()
	declare -A Tminarray

	# loop through the files and check which contain the target function pattern
	i=0
	for file in $files
	do
		#echo $file
		file=${file/".png"/".log"}
		if [ ! -f $file ] ; then
			echo "Warning: logfile $file not found! Setting Tmin to 1E+6."
			Tminarray[${i}]=1000000
			continue
		fi
	    
		if [[ "$Tminsel" == "Chi2Red" ]] ; then
			dummy=`sed -n '/Chi2Red function values = /p' $file | sed -n 's/^.*= //p' | cut -d "," -f1`
		elif [[ "$Tminsel" == "LogdI" ]] ; then
			dummy=`sed -n '/LogdI function values = /p' $file | sed -n 's/^.*= //p' | cut -d "," -f1`
		elif [[ "$Tminsel" == "Target function values" ]] ; then
			dummy=`sed -n '/Target function values = /p' $file | sed -n 's/^.*= //p' | cut -d "," -f1`
		fi

		Tminarray[${i}]=$dummy
		((i++))
	done

	Tminlen=${#Tminarray[*]}

	if [[ $verbose -eq 1 ]] ; then
		echo "Tminarray = ${Tminarray[@]}"
		echo ""
		echo "Tminlen = $Tminlen"
		echo ""
	fi


	if [ $Tminlen -eq 0 ]
	then
		echo "No target values found. Exit."
		exit
	else
		posTmin=0
		minTmin=${Tminarray[$posTmin]}

		i=1
		while [ $i -lt $Tminlen ]
		do
			val=${Tminarray[${i}]}
			# comparison of float numbers -> use bc -l
			# don't use -gt, use >
			if [[ $(echo "$minTmin > $val" | bc -l) -eq 1 ]] ; then
				minTmin=$val
				posTmin=$i
			fi
			let i++
		done
	fi

	echo "maxselTminfac = $maxselTminfac"

	maxselTmin=`echo "$maxselTminfac * $minTmin" | bc -l`
	echo "Good fits [minTmin,maxselTmin] = [$minTmin,$maxselTmin]"

	if [[ $verbose -eq 1 ]] ; then
		echo "posTmin = $posTmin"
		echo "filelist[posTmin] = ${filelist[$posTmin]}"
		echo ""
	fi
fi






########################
# prepare map settings #
########################

if [[ $# == 3 ]] ; then
	xmin=${minlist[0]}
	xmax=${maxlist[0]}
	ymin=${minlist[1]}
	ymax=${maxlist[1]}
	dx=$2
	dy=$3
else
	xmin=$2
	dx=$3
	xmax=$4
	ymin=$5
	dy=$6
	ymax=$7
fi


printf "x=$xmin:$dx:$xmax\n"
printf "y=$ymin:$dy:$ymax\n"
echo ""

# use -lt and not < in [[ ]]
if [[ $ymax -lt 10 ]] ; then
	ylen=1
else
	if [[ $ymax -lt 100 ]] ; then
		ylen=2
	else
		ylen=3
	fi
fi

# use -lt and not < in [[ ]]
if [[ $xmax -lt 10 ]] ; then
	xlen=1
else
	if [[ $xmax -lt 100 ]] ; then
		xlen=2
	else
		xlen=3
	fi
fi

xpat="%${xlen}d"
ypat="%${ylen}d"

if [[ $verbose -eq 1 ]] ; then
	printf "xlen = $xlen\n"
	printf "ylen = $ylen\n"
	echo ""
	printf "xpat = $xpat\n"
	printf "ypat = $ypat\n"
	echo ""
fi



red=$'\033[31;1m'
green=$'\033[32;1m'
white=$'\033[37;1m'
yellow=$'\033[33;1m'
blue=$'\033[34;1m'

#nocolor=$'\033[0m'

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37




############
# plot map #
############

strarr=()

# upper horizontal line -----------
dummypat="%${xlen}s"
printf "$white$dummypat %s%s" " " "-" "-"
for x in $(eval echo {$xmin..$xmax..$dx})
do
	printf "-"
done
printf "%s%s" "-" "-"
printf "\n"

# use $(eval echo {$ymax..$ymin..$dy}) instead of {$ymax..$ymin..$dy}, the latter works not with variables
for y in $(eval echo {$ymax..$ymin..$dy})
do
	dummystr=""
	for x in $(eval echo {$xmin..$xmax..$dx})
	do

		i=0
		found=0	# don't use true/false
		for file in $files
		do
			if [[ $x -eq ${parlist[${i},0]} ]] && [[ $y -eq ${parlist[${i},1]} ]] ; then
				found=1
				#echo "${i} $x ${parlist[${i},0]} $y ${parlist[${i},1]}"
				break # break <n> breaks the n-th (n>0) inner loop
			fi
			((i++))
		done

		# now decide which symbol and color to use for current (x,y) point
		# file existed
		if [[ $found -eq 1 ]] ; then
			# *.png ?
			if [[ $BMFmode -eq 1 ]] ; then
				# is it the best fit?
				if [[ $x -eq ${parlist[${posTmin},0]} ]] && [[ $y -eq ${parlist[${posTmin},1]} ]]
				then # mark minTmin with blue o
					dummystr="${dummystr}${blue}o"
				else # all good and bad fits
					# comparison of float numbers -> use bc -l, don't use -le, use <=
					if [[ $(echo "${Tminarray[${i}]} <= $maxselTmin" | bc -l) -eq 1 ]] 
					then # mark all good fits with yellow +
						dummystr="${dummystr}${yellow}+"
					else # mark all "bad" fits with green x						
						dummystr="${dummystr}${green}x"
					fi
				fi
			else # if not *.png, just mark all existing files with green x
				dummystr="${dummystr}${green}x"
			fi

		else # mark all non-existing files with red o
			dummystr="${dummystr}${red}o"
		fi
	done

	# print current y-axis tick with line of coloured symbols and vertical | separators
	printf "$white$ypat | $dummystr $white|\n" $y

	# save in strarr variable (unused)
	strarr=(${strarr[@]} $dummystr)
done




# lower horizontal line -----------
printf "$white$dummypat %s%s" " " "-" "-"
for x in $(eval echo {$xmin..$xmax..$dx})
do
	printf "-"
done
printf "%s%s" "-" "-"
printf "\n"

# x-axis ticks
for row in $(eval echo {1..$xlen})
do
	printf "$white$dummypat   "
	for x in $(eval echo {$xmin..$xmax..$dx})
	do
		dummystr=$(printf "$xpat" $x)
		#echo $dummystr
		printf "${dummystr:$((row-1)):1}"
	done
	printf "  \n"
done


