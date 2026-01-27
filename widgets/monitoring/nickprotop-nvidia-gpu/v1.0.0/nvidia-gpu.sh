#!/bin/bash
# NVIDIA GPU Monitor Widget
# Monitor NVIDIA GPU temperature, utilization, and memory
# Falls back gracefully if no NVIDIA GPU is detected

# Check for extended mode
EXTENDED=false
if [[ "$1" == "--extended" ]]; then
    EXTENDED=true
fi

echo "title: NVIDIA GPU"
echo "refresh: 3"

# Temperature thresholds (Celsius)
TEMP_WARN=70
TEMP_ERROR=85

# Check if nvidia-smi is available
if ! command -v nvidia-smi &>/dev/null; then
    echo "row: [status:warn] nvidia-smi not found"
    echo "row: [grey70]NVIDIA drivers not installed[/]"
    exit 0
fi

# Check if GPU is accessible
if ! nvidia-smi &>/dev/null; then
    echo "row: [status:error] Cannot access NVIDIA GPU"
    echo "row: [grey70]Check driver installation[/]"
    exit 0
fi

# Function to determine status based on temperature
get_temp_status() {
    local temp=$1
    if [ "$temp" -lt "$TEMP_WARN" ]; then
        echo "ok"
    elif [ "$temp" -lt "$TEMP_ERROR" ]; then
        echo "warn"
    else
        echo "error"
    fi
}

# Query GPU information
# Format: name, temp, gpu_util, mem_used, mem_total, power_draw, power_limit
gpu_query=$(nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total,power.draw,power.limit,fan.speed,pstate --format=csv,noheader,nounits 2>/dev/null)

if [ -z "$gpu_query" ]; then
    echo "row: [status:error] Failed to query GPU"
    exit 0
fi

# Parse first GPU (multi-GPU support could be added later)
IFS=',' read -r gpu_name temp gpu_util mem_used mem_total power_draw power_limit fan_speed pstate <<< "$gpu_query"

# Trim whitespace
gpu_name=$(echo "$gpu_name" | xargs)
temp=$(echo "$temp" | xargs)
gpu_util=$(echo "$gpu_util" | xargs)
mem_used=$(echo "$mem_used" | xargs)
mem_total=$(echo "$mem_total" | xargs)
power_draw=$(echo "$power_draw" | xargs)
power_limit=$(echo "$power_limit" | xargs)
fan_speed=$(echo "$fan_speed" | xargs)
pstate=$(echo "$pstate" | xargs)

# Get temperature status
temp_status=$(get_temp_status "$temp")

# Main display - GPU name
echo "row: [bold]${gpu_name}[/]"

# Temperature with status
echo "row: [status:${temp_status}] Temperature: ${temp}°C"

# Temperature progress bar (0-100°C range)
temp_percent=$temp
[ "$temp_percent" -gt 100 ] && temp_percent=100
echo "row: [progress:${temp_percent}:inline]"

# GPU utilization
if [ "$gpu_util" != "[N/A]" ] && [ -n "$gpu_util" ]; then
    echo "row: [grey70]GPU Utilization: ${gpu_util}%[/]"
fi

# Memory usage
if [ "$mem_used" != "[N/A]" ] && [ "$mem_total" != "[N/A]" ] && [ -n "$mem_used" ] && [ -n "$mem_total" ]; then
    mem_percent=$(awk "BEGIN {printf \"%.0f\", ($mem_used / $mem_total) * 100}")
    echo "row: [grey70]VRAM: ${mem_used}/${mem_total} MiB (${mem_percent}%)[/]"
fi

# Extended mode details
if [ "$EXTENDED" = true ]; then
    echo "row: "
    echo "row: [bold]GPU Details:[/]"

    # Power usage
    if [ "$power_draw" != "[N/A]" ] && [ -n "$power_draw" ]; then
        power_display="${power_draw}W"
        if [ "$power_limit" != "[N/A]" ] && [ -n "$power_limit" ]; then
            power_display="${power_draw}W / ${power_limit}W limit"
        fi
        echo "row: [grey70]Power: ${power_display}[/]"
    fi

    # Fan speed
    if [ "$fan_speed" != "[N/A]" ] && [ -n "$fan_speed" ]; then
        echo "row: [grey70]Fan Speed: ${fan_speed}%[/]"
    fi

    # Performance state
    if [ "$pstate" != "[N/A]" ] && [ -n "$pstate" ]; then
        echo "row: [grey70]Performance State: ${pstate}[/]"
    fi

    # Driver and CUDA version
    driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1 | xargs)
    if [ -n "$driver_version" ]; then
        echo "row: [grey70]Driver: ${driver_version}[/]"
    fi

    cuda_version=$(nvidia-smi --query-gpu=cuda_version --format=csv,noheader 2>/dev/null | head -1 | xargs 2>/dev/null)
    if [ -n "$cuda_version" ] && [ "$cuda_version" != "[N/A]" ]; then
        echo "row: [grey70]CUDA: ${cuda_version}[/]"
    fi

    # Clock speeds
    echo "row: "
    echo "row: [bold]Clock Speeds:[/]"

    clocks=$(nvidia-smi --query-gpu=clocks.gr,clocks.mem,clocks.max.gr,clocks.max.mem --format=csv,noheader,nounits 2>/dev/null | head -1)
    if [ -n "$clocks" ]; then
        IFS=',' read -r clock_gr clock_mem clock_max_gr clock_max_mem <<< "$clocks"
        clock_gr=$(echo "$clock_gr" | xargs)
        clock_mem=$(echo "$clock_mem" | xargs)
        clock_max_gr=$(echo "$clock_max_gr" | xargs)
        clock_max_mem=$(echo "$clock_max_mem" | xargs)

        if [ "$clock_gr" != "[N/A]" ] && [ -n "$clock_gr" ]; then
            if [ "$clock_max_gr" != "[N/A]" ] && [ -n "$clock_max_gr" ]; then
                echo "row: [grey70]Graphics: ${clock_gr} MHz (max ${clock_max_gr})[/]"
            else
                echo "row: [grey70]Graphics: ${clock_gr} MHz[/]"
            fi
        fi

        if [ "$clock_mem" != "[N/A]" ] && [ -n "$clock_mem" ]; then
            if [ "$clock_max_mem" != "[N/A]" ] && [ -n "$clock_max_mem" ]; then
                echo "row: [grey70]Memory: ${clock_mem} MHz (max ${clock_max_mem})[/]"
            else
                echo "row: [grey70]Memory: ${clock_mem} MHz[/]"
            fi
        fi
    fi

    # GPU processes
    echo "row: "
    echo "row: [bold]GPU Processes:[/]"

    processes=$(nvidia-smi --query-compute-apps=pid,used_memory,process_name --format=csv,noheader,nounits 2>/dev/null)
    if [ -n "$processes" ] && [ "$processes" != "[N/A]" ]; then
        count=0
        echo "$processes" | while IFS=',' read -r pid mem_use proc_name; do
            [ $count -ge 5 ] && break
            pid=$(echo "$pid" | xargs)
            mem_use=$(echo "$mem_use" | xargs)
            proc_name=$(echo "$proc_name" | xargs)
            # Get just the process name, not full path
            proc_short=$(basename "$proc_name" 2>/dev/null || echo "$proc_name")
            # Truncate long names
            if [ ${#proc_short} -gt 25 ]; then
                proc_short="${proc_short:0:22}..."
            fi
            echo "row: [grey70]${proc_short} (PID ${pid}): ${mem_use} MiB[/]"
            ((count++))
        done
    else
        echo "row: [grey70]No active GPU processes[/]"
    fi
fi
