#!/bin/bash
# Verify SHA256 checksums for all widget artifacts

set -e

echo "Verifying checksums for all widget artifacts..."
echo ""

errors=0

for manifest in widgets/**/*.yaml; do
    if [ ! -f "$manifest" ]; then
        continue
    fi

    echo "Checking $manifest..."

    # Extract URLs and checksums using grep/awk
    # This is a simple implementation - could be improved with proper YAML parsing
    urls=$(grep -A 1 "url:" "$manifest" | grep "https://" | sed 's/.*url: *"//' | sed 's/".*//')
    checksums=$(grep "sha256:" "$manifest" | sed 's/.*sha256: *"//' | sed 's/".*//')

    # Convert to arrays
    url_array=($urls)
    checksum_array=($checksums)

    # Verify each artifact
    for i in "${!url_array[@]}"; do
        url="${url_array[$i]}"
        expected_checksum="${checksum_array[$i]}"

        if [ -z "$url" ] || [ -z "$expected_checksum" ]; then
            continue
        fi

        echo "  Downloading: $url"

        # Download file
        temp_file=$(mktemp)
        if ! curl -sL "$url" -o "$temp_file"; then
            echo "  ❌ Failed to download $url"
            errors=$((errors + 1))
            rm -f "$temp_file"
            continue
        fi

        # Calculate checksum
        actual_checksum=$(sha256sum "$temp_file" | awk '{print $1}')
        rm -f "$temp_file"

        # Compare
        if [ "$actual_checksum" = "$expected_checksum" ]; then
            echo "  ✓ Checksum verified: $expected_checksum"
        else
            echo "  ❌ Checksum mismatch!"
            echo "     Expected: $expected_checksum"
            echo "     Got:      $actual_checksum"
            errors=$((errors + 1))
        fi
    done

    echo ""
done

if [ $errors -gt 0 ]; then
    echo "❌ Verification failed with $errors error(s)"
    exit 1
else
    echo "✓ All checksums verified successfully"
    exit 0
fi
