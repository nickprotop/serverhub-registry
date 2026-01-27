#!/bin/bash
# Pi-hole Stats Widget
# Monitor Pi-hole DNS blocking statistics
# Auto-detects Pi-hole running on localhost

# Check for extended mode
EXTENDED=false
if [[ "$1" == "--extended" ]]; then
    EXTENDED=true
fi

echo "title: Pi-hole"
echo "refresh: 30"

# Pi-hole API endpoint (localhost default)
PIHOLE_API="http://127.0.0.1/admin/api.php"

# Check if curl is available
if ! command -v curl &>/dev/null; then
    echo "row: [status:error] curl not found"
    exit 0
fi

# Check if jq is available for JSON parsing
HAS_JQ=false
if command -v jq &>/dev/null; then
    HAS_JQ=true
fi

# Fetch summary data
response=$(curl -s --connect-timeout 3 --max-time 5 "${PIHOLE_API}?summary" 2>/dev/null)

if [ -z "$response" ]; then
    echo "row: [status:warn] Pi-hole not detected on localhost"
    echo "row: [grey70]Ensure Pi-hole is running at 127.0.0.1[/]"
    exit 0
fi

# Parse JSON response
if [ "$HAS_JQ" = true ]; then
    status=$(echo "$response" | jq -r '.status // empty' 2>/dev/null)
    queries_today=$(echo "$response" | jq -r '.dns_queries_today // empty' 2>/dev/null)
    blocked_today=$(echo "$response" | jq -r '.ads_blocked_today // empty' 2>/dev/null)
    percent_blocked=$(echo "$response" | jq -r '.ads_percentage_today // empty' 2>/dev/null)
    domains_blocked=$(echo "$response" | jq -r '.domains_being_blocked // empty' 2>/dev/null)
    unique_domains=$(echo "$response" | jq -r '.unique_domains // empty' 2>/dev/null)
    queries_forwarded=$(echo "$response" | jq -r '.queries_forwarded // empty' 2>/dev/null)
    queries_cached=$(echo "$response" | jq -r '.queries_cached // empty' 2>/dev/null)
    clients_seen=$(echo "$response" | jq -r '.clients_ever_seen // empty' 2>/dev/null)
    unique_clients=$(echo "$response" | jq -r '.unique_clients // empty' 2>/dev/null)
    gravity_updated=$(echo "$response" | jq -r '.gravity_last_updated.relative.days // empty' 2>/dev/null)
else
    # Fallback: basic grep parsing
    status=$(echo "$response" | grep -oP '"status"\s*:\s*"\K[^"]+' | head -1)
    queries_today=$(echo "$response" | grep -oP '"dns_queries_today"\s*:\s*\K[0-9]+' | head -1)
    blocked_today=$(echo "$response" | grep -oP '"ads_blocked_today"\s*:\s*\K[0-9]+' | head -1)
    percent_blocked=$(echo "$response" | grep -oP '"ads_percentage_today"\s*:\s*\K[0-9.]+' | head -1)
    domains_blocked=$(echo "$response" | grep -oP '"domains_being_blocked"\s*:\s*\K[0-9]+' | head -1)
    unique_domains=""
    queries_forwarded=""
    queries_cached=""
    clients_seen=""
    unique_clients=""
    gravity_updated=""
fi

# Validate we got data
if [ -z "$queries_today" ]; then
    echo "row: [status:warn] Could not parse Pi-hole response"
    echo "row: [grey70]API may have changed or auth required[/]"
    exit 0
fi

# Status indicator
if [ "$status" = "enabled" ]; then
    echo "row: [status:ok] Status: Enabled"
else
    echo "row: [status:error] Status: Disabled"
fi

# Format percentage
percent_int=${percent_blocked%.*}
[ -z "$percent_int" ] && percent_int=0

# Main stats
echo "row: Queries today: ${queries_today}"
echo "row: Blocked: ${blocked_today} (${percent_blocked}%)"
echo "row: [progress:${percent_int}:inline]"

# Blocklist size
if [ -n "$domains_blocked" ]; then
    # Format large numbers with commas
    if [ "$HAS_JQ" = true ]; then
        domains_formatted=$(printf "%'d" "$domains_blocked" 2>/dev/null || echo "$domains_blocked")
    else
        domains_formatted=$domains_blocked
    fi
    echo "row: [grey70]Blocklist: ${domains_formatted} domains[/]"
fi

# Extended mode details
if [ "$EXTENDED" = true ]; then
    echo "row: "
    echo "row: [bold]Query Statistics:[/]"

    if [ -n "$queries_forwarded" ]; then
        echo "row: [grey70]Forwarded: ${queries_forwarded}[/]"
    fi

    if [ -n "$queries_cached" ]; then
        echo "row: [grey70]Cached: ${queries_cached}[/]"
    fi

    if [ -n "$unique_domains" ]; then
        echo "row: [grey70]Unique domains: ${unique_domains}[/]"
    fi

    echo "row: "
    echo "row: [bold]Clients:[/]"

    if [ -n "$unique_clients" ]; then
        echo "row: [grey70]Active clients: ${unique_clients}[/]"
    fi

    if [ -n "$clients_seen" ]; then
        echo "row: [grey70]Total seen: ${clients_seen}[/]"
    fi

    # Gravity update info
    if [ -n "$gravity_updated" ] && [ "$gravity_updated" != "null" ]; then
        echo "row: "
        if [ "$gravity_updated" -eq 0 ]; then
            echo "row: [grey70]Gravity: Updated today[/]"
        elif [ "$gravity_updated" -eq 1 ]; then
            echo "row: [grey70]Gravity: Updated yesterday[/]"
        else
            echo "row: [grey70]Gravity: Updated ${gravity_updated} days ago[/]"
        fi
    fi

    # Try to get top blocked domains (requires separate API call)
    if [ "$HAS_JQ" = true ]; then
        top_ads=$(curl -s --connect-timeout 2 --max-time 3 "${PIHOLE_API}?topItems=5" 2>/dev/null)
        if [ -n "$top_ads" ]; then
            top_blocked=$(echo "$top_ads" | jq -r '.top_ads // empty | to_entries | .[:5][] | "\(.key): \(.value)"' 2>/dev/null)
            if [ -n "$top_blocked" ]; then
                echo "row: "
                echo "row: [bold]Top Blocked Domains:[/]"
                echo "$top_blocked" | head -5 | while read -r line; do
                    domain=$(echo "$line" | cut -d: -f1)
                    count=$(echo "$line" | cut -d: -f2 | tr -d ' ')
                    # Truncate long domains
                    if [ ${#domain} -gt 35 ]; then
                        domain="${domain:0:32}..."
                    fi
                    echo "row: [grey70]${domain} (${count})[/]"
                done
            fi
        fi
    fi
fi
