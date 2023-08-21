#!/bin/bash

output_file="server_info.csv"

end_time=$((SECONDS + 21600)) # Set end time to six hour (21600 seconds) from now

# Header for the output file
echo "Timestamp,Start Time,CPU Utilization (%),Network In (bytes/s),Network Out (bytes/s),Memory Usage (%),Total Memory (MB),Total Tasks Running,Load Average (1 min),Load Average (5 min),Load Average (15 min)" > "$output_file"

while [ $SECONDS -lt $end_time ]; do
    # Get system start time
    start_time=$(uptime -s)

    # Get CPU utilization
    cpu_utilization=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')

    # Get network in/out
    network_info=$(ifstat -T -q 1 1 | tail -n 1)
    network_in=$(echo "$network_info" | awk '{print $1}')
    network_out=$(echo "$network_info" | awk '{print $2}')

    # Get memory usage
    memory_info=$(free -m | awk '/Mem:/ {print $3,$2}')
    memory_used=$(echo "$memory_info" | awk '{print $1}')
    total_memory=$(echo "$memory_info" | awk '{print $2}')
    memory_usage=$(echo "scale=2; ($memory_used / $total_memory) * 100" | bc)

    # Get total tasks running
    total_tasks_running=$(ps aux | wc -l)

    # Get load average
    load_avg=$(uptime | awk -F "load average:" '{print $2}' | sed 's/^[ \t]*//')

    # Get current timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Append data to the output file in CSV format (row and column)
    echo "$timestamp,$start_time,$cpu_utilization,$network_in,$network_out,$memory_usage,$total_memory,$total_tasks_running,$load_avg" >> "$output_file"

    # Wait for 5 minutes
    sleep 300
done
