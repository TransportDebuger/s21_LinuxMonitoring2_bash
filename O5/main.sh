#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Error: Single parameter must be added."
  exit 1
fi

case "$1" in
  1|2|3|4)
    ;;
  *)
    echo "Error: Valid parameter values must be 1, 2, 3 or 4."
    exit 1
    ;;
esac

logfile="../O4/access-log-20250102.log"

# Функция для обработки ошибок
error() {
  echo "Ошибка: файл '$logfile' не найден или недоступен." >&2
  exit 1
}

# Проверим наличие файла логов
[[ ! -f "$logfile" ]] && error

case "$1" in
  1)
    awk '{ print $9 "\t" $0 }' "$logfile" | sort -nk1 | cut -f2-
    ;;
  2)
    awk '{print $1}' "$logfile" | sort -un
    ;;
  3)
    awk '$9 ~ /^[45]/ {print $0}' "$logfile"
    ;;
  4)
    awk '$9 ~ /^[45]/ {print $1}' "$logfile" | sort -un
    ;;
esac