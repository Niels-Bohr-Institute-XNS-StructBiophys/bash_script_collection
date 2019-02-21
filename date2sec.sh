#!/bin/bash

# https://stackoverflow.com/questions/10990949/convert-date-time-string-to-epoch-in-bash
#orig="Tue Sep 11 15:31:25 2018"
#epoch=$(date -d "${orig}" +"%s")
#epoch_to_date=$(date -d @$epoch +%Y%m%d_%H%M%S)    
#
#echo "original = $orig"
#echo "epoch conv = $epoch"
#echo "epoch to human readable time stamp = $epoch_to_date"



conv_date_epoche() {

	epoch=$(date -d "$1" +"%s")
	#epoch_to_date=$(date -d @$epoch +%Y%m%d_%H%M%S)    

	#echo "$1 $epoch"

	# https://stackoverflow.com/questions/17336915/return-value-in-a-bash-function
	# return is only for flags
	#return $epoch
	echo $epoch
}


#replace \n with " "
datearr=("Tue Sep 11 15:31:25 2018" "Tue Sep 11 15:37:10 2018" "Tue Sep 11 15:42:54 2018" "Tue Sep 11 15:48:39 2018" "Tue Sep 11 16:02:12 2018" "Tue Sep 11 16:07:56 2018" "Tue Sep 11 16:13:41 2018" "Tue Sep 11 16:19:25 2018" "Tue Sep 11 16:30:21 2018" "Tue Sep 11 16:36:06 2018" "Tue Sep 11 16:41:51 2018" "Tue Sep 11 16:47:35 2018" "Tue Sep 11 16:53:19 2018" "Tue Sep 11 16:59:04 2018" "Tue Sep 11 17:10:33 2018" "Tue Sep 11 17:18:25 2018")


echo ${datearr[@]}
echo
echo ${#datearr[@]}
echo

for ((i=0; i<${#datearr[@]}; i++)); do
	#echo $i
	printf "${datearr[$i]}"
	#test=$(conv_date_epoche "${datearr[$i]}")
	#echo $test
	datearr[$i]=$(conv_date_epoche "${datearr[$i]}")
	printf "\t${datearr[$i]}\n"
done

echo

for ((i=0; i<${#datearr[@]}; i++)); do
	echo "${datearr[$i]}"
done


echo
echo

datearr=("Tue Sep 11 19:35:45 2018" "Tue Sep 11 19:41:30 2018" "Tue Sep 11 19:47:14 2018" "Tue Sep 11 19:52:58 2018" "Tue Sep 11 19:58:42 2018" "Tue Sep 11 20:04:26 2018" "Tue Sep 11 20:10:11 2018" "Tue Sep 11 20:15:55 2018" "Tue Sep 11 20:21:40 2018" "Tue Sep 11 20:27:24 2018" "Tue Sep 11 20:33:09 2018" "Tue Sep 11 20:38:55 2018" "Tue Sep 11 20:44:40 2018" "Tue Sep 11 20:50:24 2018" "Tue Sep 11 20:56:09 2018" "Tue Sep 11 21:01:53 2018" "Tue Sep 11 21:07:51 2018")

for ((i=0; i<${#datearr[@]}; i++)); do
	#echo $i
	printf "${datearr[$i]}"
	#test=$(conv_date_epoche "${datearr[$i]}")
	#echo $test
	datearr[$i]=$(conv_date_epoche "${datearr[$i]}")
	printf "\t${datearr[$i]}\n"
done

echo

for ((i=0; i<${#datearr[@]}; i++)); do
	echo "${datearr[$i]}"
done




