#!/bin/bash

if [ $# -ne 6 ] ; then
    echo "Error: Wrong parameters count. It must have 6 parameters."
    exit 1
fi

log_file="./file_gen.log"

path=$(readlink -f "$1")
nested_folders_count=$2
folder_chars=$3
num_files_pfldr=$4
fname_and_ext_chars=$5
file_size_kb=$6
date_str=$(date +%d%m%y)


is_enought_dspace () {
    local free_space=$(df --block-size=1G / | tail -n 1 | awk '{print $4}')
    if (( free_space <= 1 )) ; then
        return 1
    else
        return 0
    fi
}

generate_random_name() {
  local sample=$1
  result=""
  for (( i=0; i<${#sample}; i++ )); do
    char=${sample:$i:1}
    repeats=$((RANDOM % 4 + 1))
    result+=$(yes "$char" | head -n $repeats | tr -d '\n')
  done
  echo "$result"
}

if  ! is_enought_dspace ; then
    echo "Error: Not enougth disk space."
    exit 1
fi

if (( file_size_kb > 100 )) ; then
    echo "Error: The size of file that will created must be 100 КB."
    exit 1
fi

if [[ ! $nested_folders_count =~ ^[0-9]*$ ]] ; then
    echo "Error: Parameter 2 contains illegal symbols. It mast have only digits."
    exit 1
fi

if [[ ! $num_files_pfldr =~ ^[0-9]*$ ]] ; then
    echo "Error: Parameter 4 contains illegal symbols. It mast have only digits."
    exit 1
elif [ $num_files_pfldr -eq 0 ] ; then
    echo "Error: Parameter must have value greater 0."
    exit 1
fi

if [[ ! $folder_chars =~ ^[A-Za-z]{1,7}$ ]] ; then
    echo "Error: Parameter 3 must contain only symbols A-Z, a-z and have length 7 symbols"
    exit 1
fi

if [[ ! $fname_and_ext_chars =~ ^[A-Za-z]{1,7}.[A-Za-z]{1,3}$ ]] ; then
    echo "Error: Parameter 5 must contain only symbols A-Z, a-z and have length 1-7 symbols for filename and 1-3 for extention."
    exit 1
fi

if test -f $path ; then
    echo "Error: $path is a file."
    exit 1;
fi

file_name_chars=$(echo $fname_and_ext_chars | cut -d '.' -f 1)
file_ext_chars=$(echo $fname_and_ext_chars | cut -d '.' -f 2)

for (( folder_num=1; folder_num<=nested_folders_count; folder_num++ )); do
  folder_name=$(generate_random_name "$folder_chars")_$date_str
  full_folder_path="$path/$folder_name"
  mkdir -p "$full_folder_path"
  echo "$full_folder_path,$date_str," >> $log_file
  
  for (( file_num=1; file_num<=$num_files_pfldr; file_num++ )); do
    if  ! is_enought_dspace ; then
        echo "Error: Not enougth disk space."
        exit 1
    fi
    file_name=$(generate_random_name "$file_name_chars")_$date_str\.$(generate_random_name "$file_ext_chars")
    full_file_path="$full_folder_path/$file_name"
    dd if=/dev/urandom of="$full_file_path" bs=1024 count=$file_size_kb &>/dev/null
    echo "$full_file_path,$date_str,$file_size_kb" >> $log_file
  done
done