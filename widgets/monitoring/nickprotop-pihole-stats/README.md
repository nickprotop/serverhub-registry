# Pi-hole Stats

Monitor Pi-hole DNS blocking statistics. Auto-detects Pi-hole running on localhost with zero configuration.

## Features

- **Auto-Detection** - Automatically connects to Pi-hole at 127.0.0.1
- **Query Statistics** - Total queries and blocked queries today
- **Block Percentage** - Visual progress bar of blocked percentage
- **Blocklist Size** - Number of domains on your blocklist
- **Status Indicator** - Shows if Pi-hole is enabled or disabled
- **Extended Mode** - Top blocked domains, client stats, gravity update info

## Installation

### Via Marketplace

```bash
serverhub marketplace install nickprotop/pihole-stats
```

### Manual Installation

```bash
# Download the widget
curl -o ~/.config/serverhub/widgets/pihole-stats.sh \
  https://raw.githubusercontent.com/nickprotop/serverhub-registry/main/widgets/monitoring/nickprotop-pihole-stats/v1.0.0/pihole-stats.sh

chmod +x ~/.config/serverhub/widgets/pihole-stats.sh

# Add to config.yaml
cat >> ~/.config/serverhub/config.yaml << 'EOF'

widgets:
  pihole-stats:
    path: pihole-stats.sh
    refresh: 30
    sha256: "ea8654818503f05d31053ae84ebe89d7bf22d85cf5900a4121198b16aa65ef04"
EOF
```

## Configuration

```yaml
widgets:
  pihole-stats:
    path: pihole-stats.sh
    refresh: 30          # Update every 30 seconds
    expanded_refresh: 10 # Faster refresh when expanded
    sha256: "ea8654818503f05d31053ae84ebe89d7bf22d85cf5900a4121198b16aa65ef04"
```

## Output

**Compact View:**
```
✓ Status: Enabled
Queries today: 12,847
Blocked: 2,156 (16.8%)
▓▓▓▓▓▓▓▓▓░░░░░░░░░░░ 17%
Blocklist: 892,341 domains
```

**Expanded View:**
```
Query Statistics:
Forwarded: 8,234
Cached: 2,457
Unique domains: 1,892

Clients:
Active clients: 12
Total seen: 18

Gravity: Updated 2 days ago

Top Blocked Domains:
ads.google.com (342)
tracking.facebook.com (256)
telemetry.microsoft.com (198)
```

## Requirements

- **Required:** `curl`
- **Optional:** `jq` (for better JSON parsing and extended features)
- **Required:** Pi-hole running on localhost (127.0.0.1)

## How It Works

1. Queries the Pi-hole API at `http://127.0.0.1/admin/api.php?summary`
2. No authentication required for read-only statistics
3. If Pi-hole is not detected, shows a friendly message
4. Extended mode fetches additional data like top blocked domains

## Pi-hole API

This widget uses the Pi-hole built-in API which is available without authentication for basic stats:

- `/admin/api.php?summary` - Basic statistics
- `/admin/api.php?topItems=5` - Top queries/blocked (extended mode)

## Troubleshooting

**"Pi-hole not detected on localhost"**
- Ensure Pi-hole is running: `pihole status`
- Check if the web interface is accessible: `curl http://127.0.0.1/admin/api.php?summary`
- Verify lighttpd/nginx is running for the Pi-hole web interface

**"Could not parse Pi-hole response"**
- Install `jq` for better JSON parsing: `apt install jq`
- Check Pi-hole version compatibility

## License

MIT

## Author

Created by nickprotop for the ServerHub marketplace.
