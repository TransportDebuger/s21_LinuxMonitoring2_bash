#!/bin/bash

start_time=$SECONDS
start_time=`date +"%Y-%m-%d %H:%M:%S"`

if [ $# -ne 3 ] ; then
    echo "Error: Wrong parameters count. It must have 3 parameters."
    exit 1
fi

log_file="./file_gen_$(date +"%Y%m%d_%H%M%S").log"
path=$(pwd)
folder_chars=$1
folder_count=$((RANDOM % 100 + 1))
file_name_ext_chars=$2
file_size_mb=$3
date_stamp=`date +"%d%m%y"`

if [[ ! $folder_chars =~ ^[A-Za-z]{1,7}$ ]] ; then
    echo "Error: Foldername chars must contains only symbols A-Z, a-z and have length 7 symbols"
    exit 1
fi

if [[ ! $file_name_ext_chars =~ ^[A-Za-z]{1,7}.[A-Za-z]{1,3}$ ]] ; then
    echo "Error: File name chars must contain only symbols A-Z, a-z and have length 1-7 symbols for filename and 1-3 for extention."
    exit 1
fi

if ! [[ "$file_size_mb" =~ ^[0-9]+$ && $file_size_mb -le 100 ]]; then
  echo "Error: File size parameter must be natural number and not be greater than 100 MB!"
  exit 1
fi

if [[ "$path" == *"bin"* ]] ; then
    echo "Error: Script can't be running in this folder"
    exit 1
fi

file_name_chars=$(echo $file_name_ext_chars | cut -d '.' -f 1)
file_ext_chars=$(echo $file_name_ext_chars | cut -d '.' -f 2)

is_enought_dspace () {
    local free_space=$(df -h / | tail -n 1 | awk '{print $4}')
    if [[ $free_space == *"G"* ]]; then
        free_space_gb=${free_space::-1}
        if (( $free_space_gb <= 1 )); then
            return 1
        fi
    elif [[ $free_space == *"M"* ]]; then
        free_space_mb=${free_space::-1}
        if (( $free_space_mb <= 1024 )); then
            return 1
        fi
    fi
    return 0
}

if  ! is_enought_dspace ; then
    echo "Error: Not enougth disk space."
    exit 1
fi

generate_random_name () {
  local sample=$1
  local result=""
  for (( i=0; i<${#sample}; i++ )); do
    char=${sample:$i:1}
    repeats=$((RANDOM % 5 + 1))
    result+=$(yes "$char" | head -n $repeats | tr -d '\n')
  done
  echo "$result"
}

echo "Script starts execution at ${start_time}" >> $log_file

for (( folder_num=1; folder_num<=folder_count; folder_num++ )); do
  folder_name=$(generate_random_name "$folder_chars")_$date_stamp
  full_folder_path="$path/$folder_name"
  mkdir -p "$full_folder_path"
  echo "$full_folder_path,$date_stamp," >> $log_file
  files_count=$((RANDOM + 1))

  for (( file_num=1; file_num<=files_count; file_num++ )) ; do
    if  ! is_enought_dspace ; then
        echo "Error: Not enougth disk space."
        exit 1
    fi

    file_name=$(generate_random_name "$file_name_chars")_$date_str\.$(generate_random_name "$file_ext_chars")
    full_file_path="$full_folder_path/$file_name"
    dd if=/dev/urandom of="$full_file_path" bs=1M count=$file_size_mb &>/dev/null
    echo "$full_file_path,$date_str,$file_size_mb" >> $log_file
  done
done 

end_time=`date +"%Y-%m-%d %H:%M:%S"`
total_time=$(($(date +"%s" -d "$end_time") - $(date +"%s" -d "$start_time")))
echo "Script execution ended at ${end_time}" >> $log_file
echo "Script execution time (in seconds) = ${total_time}" >> $log_file