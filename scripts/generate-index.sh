#!/bin/bash
# Generate registry.json from widget manifests

set -e

echo "{"
echo '  "schema_version": "1.0",'
echo "  \"updated_at\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\","
echo '  "widgets": ['

first=true

for manifest in widgets/*/*/manifest.yaml; do
    if [ ! -f "$manifest" ]; then
        continue
    fi

    # Extract fields using grep/sed (simple approach)
    id=$(grep "id:" "$manifest" | head -1 | sed 's/.*id: *"//' | sed 's/".*//')
    name=$(grep "name:" "$manifest" | head -1 | sed 's/.*name: *"//' | sed 's/".*//')
    author=$(grep "author:" "$manifest" | head -1 | sed 's/.*author: *"//' | sed 's/".*//')
    category=$(grep "category:" "$manifest" | head -1 | sed 's/.*category: *"//' | sed 's/".*//')
    description=$(grep "description:" "$manifest" | head -1 | sed 's/.*description: *"//' | sed 's/".*//')
    verification=$(grep "verification_level:" "$manifest" | head -1 | sed 's/.*verification_level: *"//' | sed 's/".*//')
    version=$(grep "  - version:" "$manifest" | head -1 | sed 's/.*version: *"//' | sed 's/".*//')

    # Get relative path to manifest (from widgets/)
    manifest_url="${manifest}"

    # Skip if required fields are missing
    if [ -z "$id" ] || [ -z "$name" ]; then
        continue
    fi

    # Add comma separator for all but first entry
    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi

    # Output JSON for this widget
    cat <<EOF
    {
      "id": "$id",
      "name": "$name",
      "author": "$author",
      "category": "$category",
      "description": "$description",
      "verification_level": "$verification",
      "latest_version": "$version",
      "manifest_url": "$manifest_url"
    }
EOF
done

echo ""
echo "  ]"
echo "}"
