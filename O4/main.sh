#!/bin/bash

num_ips=$((RANDOM % 20 +10))
echo "Generated IP's - $num_ips"
ips=()
num_logs=5

responses=(
    "200" # OK
    "201" # Created
    "400" # Bad request
    "401" # Unauthorized
    "403" # Forbidden
    "404" # Not found
    "500" # Internal server error
    "501" # Not implemented
    "502" # Bad gateway
    "503" # Service unavailable
)

methods=(
    "GET"
    "POST"
    "PUT"
    "PATCH"
    "DELETE"
)

urls=(
    "/index.html"
    "/about-us/"
    "/contact/"
    "/products/"
    "/services/"
)

agents=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36"
    "Opera/9.80 (X11; Linux i686; Ubuntu/14.10) Presto/2.12.388 Version/12.16"
    "Safari/604.1 CFNetwork/893.14 Darwin/17.0.0 (x86_64)"
    "Internet Explorer 7.0; Windows NT 6.0; Trident/5.0"
    "Microsoft Edge 44.18362.449.0; Windows 10; ARM64"
    "Crawler Bot v1.0 (+https://example.com/bot.html)"
    "Wget/1.19.5 (linux-gnu)"
)

is_valid_octet() {
    octet=$1
    [[ $octet =~ ^[0-9]{1,3}$ ]] && [ $octet -ge 0 ] && [ $octet -le 255 ]
}

generate_valid_ip() {
    local ip=""
    for _ in {1..4}; do
        octet=$(( RANDOM % 256))
        is_valid_octet $octet || continue
        ip+="${octet}."
    done
    echo "${ip::-1}"
}

generate_random_records() {
    local records=$((RANDOM % 901 + 100))
    echo $records
}

for ((i=1; i<=num_ips; i++)); do
    ips+=("$(generate_valid_ip)")
done

generate_date() {
    local day=$1
    local hour="00"
    local minute="00"
    local second="00"
    local timezone="MSK"
    printf '%04d-%02d-%02d %02d:%02d:%02d %s' "$(date +%Y)" "$(date +%m)" "$day"  "$hour" "$minute" "$second" "$timezone"
}

generate_log_line() {
    ct=$1
    local ip=${ips[$RANDOM % ${#ips[@]}]}
    local method=${methods[$RANDOM % ${#methods[@]}]}
    local url=${urls[$RANDOM % ${#urls[@]}]}
    local response=${responses[$RANDOM % ${#responses[@]}]}
    local agent=${agents[$RANDOM % ${#agents[@]}]}
    local size=$(($RANDOM % 65534 + 1024)) # Размер от 1024 до 65535 байт
    local date=$(date -d "$ct" +"%d/%b/%Y:%H:%M:%S %z")
    
    printf '%s - - [%s] "%s %s HTTP/1.1" %s %d "-" "%s"\n' \
           "$ip" "$date" "$method" "$url" "$response" "$size" "$agent"
}
for ((day=1; day<=5; day++)); do
    records=$(generate_random_records)
    cur_time=$(generate_date "$day")
    logfile="access-log-$(date -d "$cur_time" +"%Y%m%d").log"
    time_interval=$((86400 / records))
    echo "Creating $logfile with $records entries..."

    for ((i=0; i<records; i++)); do
        time_step=$((RANDOM % $time_interval + 1))
        cur_time=$(date -d "$cur_time + $time_step seconds") 

        generate_log_line "$cur_time" >> $logfile
    done
done

echo "All logs generated successfully."