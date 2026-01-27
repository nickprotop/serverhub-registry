#!/bin/bash
# Basic security scanning for widget artifacts

set -e

echo "Running security scans on widget artifacts..."
echo ""

errors=0
warnings=0

# Suspicious patterns to check for
declare -a SUSPICIOUS_PATTERNS=(
    "rm -rf /"
    "dd if="
    "mkfs"
    ":(){:|:&};:"  # Fork bomb
    "eval.*curl"
    "eval.*wget"
    "base64.*eval"
    "chmod 777"
    "/etc/shadow"
    "/etc/passwd"
)

for manifest in widgets/**/*.yaml; do
    if [ ! -f "$manifest" ]; then
        continue
    fi

    echo "Scanning widgets in $manifest..."

    # Extract URLs
    urls=$(grep -A 1 "url:" "$manifest" | grep "https://" | sed 's/.*url: *"//' | sed 's/".*//')
    url_array=($urls)

    for url in "${url_array[@]}"; do
        if [ -z "$url" ]; then
            continue
        fi

        echo "  Downloading: $url"
        temp_file=$(mktemp)

        if ! curl -sL "$url" -o "$temp_file"; then
            echo "  ⚠  Failed to download for scanning"
            warnings=$((warnings + 1))
            rm -f "$temp_file"
            continue
        fi

        # Check if file is a script (text file)
        if file "$temp_file" | grep -q "text"; then
            # Check for suspicious patterns
            for pattern in "${SUSPICIOUS_PATTERNS[@]}"; do
                if grep -q "$pattern" "$temp_file" 2>/dev/null; then
                    echo "  ⚠  Found suspicious pattern: $pattern"
                    warnings=$((warnings + 1))
                fi
            done

            # Check for hardcoded IPs (basic check)
            if grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' "$temp_file" | grep -v "127.0.0.1" | grep -v "0.0.0.0" > /dev/null; then
                echo "  ⚠  Found hardcoded IP addresses"
                warnings=$((warnings + 1))
            fi

            # Check for AWS/GCP/Azure keys patterns
            if grep -iE '(AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35})' "$temp_file" > /dev/null; then
                echo "  ❌ Found potential hardcoded API keys!"
                errors=$((errors + 1))
            fi

            echo "  ✓ Basic security scan complete"
        else
            echo "  ⚠  Binary file - manual review required"
            warnings=$((warnings + 1))
        fi

        rm -f "$temp_file"
    done

    echo ""
done

echo "Security scan complete:"
echo "  Errors: $errors"
echo "  Warnings: $warnings"

if [ $errors -gt 0 ]; then
    echo ""
    echo "❌ Security scan failed with $errors critical issue(s)"
    exit 1
elif [ $warnings -gt 0 ]; then
    echo ""
    echo "⚠  Security scan completed with $warnings warning(s)"
    echo "   Manual review recommended"
    exit 0
else
    echo ""
    echo "✓ No security issues detected"
    exit 0
fi
