#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "Error: The way of deleting files are not defined"
  exit 1
fi

method=$1

delete_by_logfile () {
  local logfile=$1
  
  if [[ ! -f "$logfile" ]]; then
    echo "Error: Log file'$logfile' not found."
    return 1
  fi
  
  while read -r file; do
    rm -rf "$(echo $file | cut -d ',' -f 1)"
  done < "$logfile"
} #complete

delete_by_date () {
  start_time=$1
  end_time=$2
  
  start_timestamp=$(date -d "$start_time" +%s)
  end_timestamp=$(date -d "$end_time" +%s)

  find . -newermt "@$start_timestamp" ! -newermt "@$end_timestamp" -exec rm -rf {} \+;
}

delete_by_name_mask () {
  mask=$1
  find . -name "$mask" -exec rm -rf {} \+;
} #complete

case $method in
  1)
    if [[ $# -lt 2 ]]; then
      echo "Enter log file name:"
      read filename
      delete_by_logfile "$filename"
    else
      delete_by_logfile "$2"
    fi
    ;;
  2)
    if [[ $# -lt 4 ]]; then
      echo "Enter the begining of the time inteval (example, '2023-10-01 12:00'):"
      read start_time
      
      echo "Enter the end of the time interval (example, '2023-10-02 13:30'):"
      read end_time
      
      delete_by_date "$start_time" "$end_time"
    else
      delete_by_date "$2" "$3"
    fi
    ;;
  3)
    if [[ $# -lt 3 ]]; then
      echo "Enter file name mask (example, 'file_*_2023*'):"
      read mask
      
      delete_by_name_mask "$mask"
    else
      delete_by_name_mask "$2"
    fi
    ;;
  *)
    echo "Error: Defined unknown method of file deleting."
    exit 1
esac