#!/bin/bash

get_cpu_usage() {
    read cpu_user cpu_nice cpu_system cpu_idle cpu_iowait cpu_irq cpu_sirq cpu_steal cpu_guest cpu_gnice <<< $(grep 'cpu ' /proc/stat | awk '{print $2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' | head -n 1)
    cpu_total_idle=$(($cpu_idle + $cpu_iowait))
    cpu_total=$(($cpu_user + $cpu_nice + $cpu_system + $cpu_idle + $cpu_iowait + $cpu_irq + $cpu_sirq + $cpu_steal + $cpu_guest + $cpu_gnice))
    echo "$((100 - $cpu_total_idle * 100 / $cpu_total))"
}

get_mem_usage() {
    free_output=$(free -m)
    total_memory=$(echo "$free_output" | grep Mem: | awk '{print $2}')
    used_memory=$(echo "$free_output" | grep Mem: | awk '{print $3}')
    echo "$(($used_memory * 100 / $total_memory))"
}

get_disk_usage() {
    df_output=$(df -h /)
    disk_used=$(echo "$df_output" | tail -n 1 | awk '{print $5}' | sed 's/%//')
    echo "$disk_used"
}

mkdir -p /tmp/system_metrics
metrics_file="/tmp/system_metrics/metrics.html"
echo "# HELP system_cpu_usage_percent CPU usage in percent" > $metrics_file
echo "# TYPE system_cpu_usage_percent gauge" >> $metrics_file
echo "custom_system_cpu_usage_percent $(get_cpu_usage)" >> $metrics_file
echo "# HELP custom_system_mem_usage_percent Memory usage in percent" >> $metrics_file
echo "# TYPE custom_system_mem_usage_percent gauge" >> $metrics_file
echo "custom_system_mem_usage_percent $(get_mem_usage)" >> $metrics_file
echo "# HELP custom_system_disk_usage_percent Disk usage in percent" >> $metrics_file
echo "# TYPE custom_system_disk_usage_percent gauge" >> $metrics_file
echo "custom_system_disk_usage_percent $(get_disk_usage)" >> $metrics_file