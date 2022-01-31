#!/bin/sh

Help()
{
	echo "File integrity tool"
	echo "Monitors files with sha512 and notifies and logs when changes occur to fim.log"
	echo "-f [file]    Monitor a single file"
	echo "-d [directory]	Recursively monitor a directory"

}


File_Check()
{
	
	baseline=$(sha512sum $file)
	new_baseline=$baseline
	while [ 1 == 1 ]
	do
		temp_hash=$(sha512sum $file)
		if [ "$temp_hash" != "$new_baseline" ]
		then
			echo "$(date) | File Change: $file" | tee -a fim.log 
			new_baseline=$temp_hash
		fi
	done

}

Recursive()
{
	file_list=$(find $directory -type f)
	echo $file_list
	baseline=$(for i in $file_list; do sha512sum $i | cut -d " " -f 1; done)

	file_list=(${file_list[@]})
	baseline=(${baseline[@]})

	if [ ${#file_list[@]} != ${#baseline[@]} ]
	then
		echo Error
		exit 1	
	fi

	file_list_len=$(expr ${#file_list[@]})
	while [ 1 == 1 ]
	do
		for i in $(seq ${#file_list[@]})
		do
			temp_hash=$(sha512sum ${file_list[$i-1]} | cut -d " " -f 1)
			if [ "$temp_hash" != "${baseline[$i-1]}" ]
			then
				echo "$(date) | File Change: ${file_list[$i-1]}" | tee -a fim.log
				baseline[$i-1]=$temp_hash
			fi
		done
	done
}


if [[ "$!" == "-h" || "$1" == "-help" || "$1" == "--help" || "$1" == "" ]]
then 
	Help
	exit 0
fi

while getopts f:d: flag
do 
	case "$flag" in 
		f) file=${OPTARG}
			File_Check;;
		d) directory=${OPTARG}
			Recursive;;
	       \?) echo "Error: Invalid option"
	       	   exit;;
        esac
done

