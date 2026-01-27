#!/bin/bash
# Pi Sensors Widget
# Monitor Raspberry Pi temperature, throttling status, and voltages
# Falls back to thermal zones on non-Pi systems

# Check for extended mode
EXTENDED=false
if [[ "$1" == "--extended" ]]; then
    EXTENDED=true
fi

echo "title: Pi Sensors"
echo "refresh: 5"

# Check if vcgencmd is available (Raspberry Pi)
IS_PI=false
if command -v vcgencmd &>/dev/null; then
    IS_PI=true
fi

# Temperature thresholds (Celsius)
TEMP_WARN=70
TEMP_ERROR=80

# Function to determine status based on temperature
get_temp_status() {
    local temp=$1
    if (( $(echo "$temp < $TEMP_WARN" | bc -l) )); then
        echo "ok"
    elif (( $(echo "$temp < $TEMP_ERROR" | bc -l) )); then
        echo "warn"
    else
        echo "error"
    fi
}

# Function to decode throttling flags
decode_throttle() {
    local hex=$1
    local flags=()

    # Current flags (bits 0-3)
    (( hex & 0x1 )) && flags+=("Under-voltage")
    (( hex & 0x2 )) && flags+=("Freq capped")
    (( hex & 0x4 )) && flags+=("Throttled")
    (( hex & 0x8 )) && flags+=("Soft temp limit")

    if [ ${#flags[@]} -eq 0 ]; then
        echo "None"
    else
        echo "${flags[*]}"
    fi
}

# Function to decode historical throttling flags
decode_throttle_history() {
    local hex=$1
    local flags=()

    # Historical flags (bits 16-19)
    (( hex & 0x10000 )) && flags+=("Under-voltage")
    (( hex & 0x20000 )) && flags+=("Freq capped")
    (( hex & 0x40000 )) && flags+=("Throttled")
    (( hex & 0x80000 )) && flags+=("Soft temp limit")

    if [ ${#flags[@]} -eq 0 ]; then
        echo "None"
    else
        echo "${flags[*]}"
    fi
}

if [ "$IS_PI" = true ]; then
    # Raspberry Pi mode - use vcgencmd

    # Get CPU/GPU temperature
    temp_output=$(vcgencmd measure_temp 2>/dev/null)
    if [ -n "$temp_output" ]; then
        # Parse: temp=45.0'C
        temp=$(echo "$temp_output" | grep -oP '\d+\.?\d*' | head -1)
        temp_int=${temp%.*}
        status=$(get_temp_status "$temp")

        # Calculate percentage (0-85°C range for display)
        temp_percent=$(awk "BEGIN {p = ($temp / 85) * 100; if (p > 100) p = 100; printf \"%.0f\", p}")

        echo "row: [status:$status] Temperature: ${temp}°C"
        echo "row: [progress:${temp_percent}:inline]"
    fi

    # Get throttling status
    throttle_output=$(vcgencmd get_throttled 2>/dev/null)
    if [ -n "$throttle_output" ]; then
        # Parse: throttled=0x0
        throttle_hex=$(echo "$throttle_output" | grep -oP '0x[0-9a-fA-F]+')
        throttle_dec=$((throttle_hex))

        current_issues=$(decode_throttle "$throttle_dec")

        if [ "$current_issues" = "None" ]; then
            echo "row: [status:ok] Throttling: None"
        else
            echo "row: [status:error] Throttling: ${current_issues}"
        fi
    fi

    # Extended mode details
    if [ "$EXTENDED" = true ]; then
        echo "row: "
        echo "row: [bold]Raspberry Pi Details:[/]"

        # Model info
        if [ -f /proc/device-tree/model ]; then
            model=$(tr -d '\0' < /proc/device-tree/model)
            echo "row: [grey70]Model: ${model}[/]"
        fi

        # Voltage readings
        echo "row: "
        echo "row: [bold]Voltages:[/]"

        for rail in core sdram_c sdram_i sdram_p; do
            volt_output=$(vcgencmd measure_volts "$rail" 2>/dev/null)
            if [ -n "$volt_output" ]; then
                volt=$(echo "$volt_output" | grep -oP '\d+\.?\d*')
                echo "row: [grey70]${rail}: ${volt}V[/]"
            fi
        done

        # Clock speeds
        echo "row: "
        echo "row: [bold]Clock Speeds:[/]"

        for clock in arm core h264 isp v3d; do
            clock_output=$(vcgencmd measure_clock "$clock" 2>/dev/null)
            if [ -n "$clock_output" ]; then
                # Parse: frequency(45)=600000000
                freq=$(echo "$clock_output" | grep -oP '=\K\d+')
                if [ -n "$freq" ]; then
                    freq_mhz=$((freq / 1000000))
                    echo "row: [grey70]${clock}: ${freq_mhz} MHz[/]"
                fi
            fi
        done

        # Throttling history
        if [ -n "$throttle_output" ]; then
            history_issues=$(decode_throttle_history "$throttle_dec")
            echo "row: "
            echo "row: [bold]Throttling History (since boot):[/]"
            if [ "$history_issues" = "None" ]; then
                echo "row: [status:ok] No issues since boot"
            else
                echo "row: [status:warn] ${history_issues}"
            fi
        fi

        # Memory split
        gpu_mem=$(vcgencmd get_mem gpu 2>/dev/null | grep -oP '\d+')
        if [ -n "$gpu_mem" ]; then
            echo "row: "
            echo "row: [grey70]GPU Memory: ${gpu_mem}MB[/]"
        fi
    fi

else
    # Fallback mode - use thermal zones
    echo "row: [grey70]Non-Pi system - using thermal zones[/]"
    echo "row: "

    found_temp=false

    # Check for thermal zones
    for zone in /sys/class/thermal/thermal_zone*/; do
        if [ -d "$zone" ]; then
            zone_name=$(basename "$zone")
            type_file="${zone}type"
            temp_file="${zone}temp"

            if [ -f "$temp_file" ]; then
                temp_raw=$(cat "$temp_file" 2>/dev/null)
                if [ -n "$temp_raw" ]; then
                    # Temperature is in millidegrees
                    temp=$(awk "BEGIN {printf \"%.1f\", $temp_raw / 1000}")
                    temp_int=${temp%.*}
                    status=$(get_temp_status "$temp")

                    # Get zone type if available
                    zone_type="unknown"
                    if [ -f "$type_file" ]; then
                        zone_type=$(cat "$type_file" 2>/dev/null)
                    fi

                    # Calculate percentage
                    temp_percent=$(awk "BEGIN {p = ($temp / 85) * 100; if (p > 100) p = 100; printf \"%.0f\", p}")

                    echo "row: [status:$status] ${zone_type}: ${temp}°C"
                    echo "row: [progress:${temp_percent}:inline]"
                    found_temp=true
                fi
            fi
        fi
    done

    if [ "$found_temp" = false ]; then
        echo "row: [status:warn] No temperature sensors found"
    fi

    # Extended mode for fallback
    if [ "$EXTENDED" = true ]; then
        echo "row: "
        echo "row: [bold]System Information:[/]"

        # Kernel info
        kernel=$(uname -r)
        echo "row: [grey70]Kernel: ${kernel}[/]"

        # Architecture
        arch=$(uname -m)
        echo "row: [grey70]Architecture: ${arch}[/]"

        # List all thermal zones
        echo "row: "
        echo "row: [bold]Thermal Zones:[/]"
        for zone in /sys/class/thermal/thermal_zone*/; do
            if [ -d "$zone" ]; then
                zone_name=$(basename "$zone")
                type_file="${zone}type"
                zone_type="unknown"
                if [ -f "$type_file" ]; then
                    zone_type=$(cat "$type_file" 2>/dev/null)
                fi
                echo "row: [grey70]${zone_name}: ${zone_type}[/]"
            fi
        done
    fi
fi

# Actions
echo "action: Show all temps:cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | while read t; do echo \"\$((t/1000))°C\"; done"
if [ "$IS_PI" = true ]; then
    echo "action: Full vcgencmd report:vcgencmd measure_temp && vcgencmd get_throttled && vcgencmd measure_volts"
fi
