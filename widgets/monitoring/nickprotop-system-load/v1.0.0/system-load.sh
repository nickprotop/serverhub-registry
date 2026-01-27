#!/bin/bash
# System Load Monitor Widget
# Displays system load averages with color-coded status indicators

# Check for extended mode
EXTENDED=false
if [[ "$1" == "--extended" ]]; then
    EXTENDED=true
fi

echo "title: System Load"
echo "refresh: 5"

# Get core count
cpu_cores=$(nproc 2>/dev/null || echo "1")

# Get load average
read -r load1 load5 load15 _ _ < /proc/loadavg

# Calculate load percentage (load1 / cores * 100)
load_percent=$(awk "BEGIN {printf \"%.0f\", ($load1 / $cpu_cores) * 100}")

# Cap at 100% for display
[ "$load_percent" -gt 100 ] && load_percent=100

# Determine status based on load
if [ "$load_percent" -lt 70 ]; then
    status="ok"
elif [ "$load_percent" -lt 90 ]; then
    status="warn"
else
    status="error"
fi

# Main display row
echo "row: [status:$status] Load: ${load1} / ${cpu_cores} cores (${load_percent}%)"
echo "row: [progress:${load_percent}:inline]"

# Load averages
echo "row: [grey70]1min: ${load1} | 5min: ${load5} | 15min: ${load15}[/]"

# Extended mode: detailed information
if [ "$EXTENDED" = true ]; then
    echo "row: "
    echo "row: [bold]System Load Details:[/]"

    # CPU model
    if [ -f /proc/cpuinfo ]; then
        cpu_model=$(grep -m1 "model name" /proc/cpuinfo | cut -d':' -f2 | xargs)
        if [ -n "$cpu_model" ]; then
            echo "row: [grey70]CPU: ${cpu_model}[/]"
        fi
    fi

    echo "row: [grey70]Cores: ${cpu_cores}[/]"

    # Uptime
    if [ -f /proc/uptime ]; then
        uptime_seconds=$(cut -d'.' -f1 /proc/uptime)
        uptime_days=$((uptime_seconds / 86400))
        uptime_hours=$(( (uptime_seconds % 86400) / 3600 ))
        uptime_mins=$(( (uptime_seconds % 3600) / 60 ))
        echo "row: [grey70]Uptime: ${uptime_days}d ${uptime_hours}h ${uptime_mins}m[/]"
    fi

    # Process count
    if [ -d /proc ]; then
        process_count=$(ls -d /proc/[0-9]* 2>/dev/null | wc -l)
        echo "row: [grey70]Processes: ${process_count}[/]"
    fi

    # Top CPU processes
    echo "row: "
    echo "row: [bold]Top CPU Processes:[/]"
    ps aux --sort=-%cpu 2>/dev/null | awk 'NR>1 && NR<=6 {
        cmd = $11
        gsub(/.*\//, "", cmd)
        if (length(cmd) > 30) cmd = substr(cmd, 1, 30)
        printf "row: [grey70]%s: %.1f%% (PID %s)[/]\n", cmd, $3, $2
    }'
fi

# Actions
echo "action: View all processes:ps aux --sort=-%cpu | head -20"
if [ "$load_percent" -gt 80 ]; then
    # Get top CPU process for kill action
    top_pid=$(ps aux --sort=-%cpu 2>/dev/null | awk 'NR==2 {print $2}')
    top_cmd=$(ps aux --sort=-%cpu 2>/dev/null | awk 'NR==2 {cmd=$11; gsub(/.*\//, "", cmd); print cmd}')
    if [ -n "$top_pid" ]; then
        echo "action: [sudo,danger,refresh] Kill ${top_cmd}:kill -9 ${top_pid}"
    fi
fi
