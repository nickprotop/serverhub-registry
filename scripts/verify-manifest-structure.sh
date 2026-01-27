#!/bin/bash
# Verify manifest file structure and naming conventions

set -e

echo "Verifying manifest structure..."
echo ""

errors=0

for manifest in widgets/*/*/manifest.yaml; do
    if [ ! -f "$manifest" ]; then
        continue
    fi

    echo "Checking $manifest..."

    # Extract ID from manifest
    id=$(grep "id:" "$manifest" | head -1 | sed 's/.*id: *"//' | sed 's/".*//')

    if [ -z "$id" ]; then
        echo "  ❌ No widget ID found in manifest"
        errors=$((errors + 1))
        continue
    fi

    # Verify ID format (username/widget-name)
    if ! echo "$id" | grep -qE '^[a-z0-9-]+/[a-z0-9-]+$'; then
        echo "  ❌ Invalid ID format: $id (must be username/widget-name)"
        errors=$((errors + 1))
    fi

    # Extract directory name
    widget_dir=$(dirname "$manifest")
    dirname=$(basename "$widget_dir")

    # Expected directory name format: username-widget-name
    expected_dirname=$(echo "$id" | sed 's/\//-/')

    if [ "$dirname" != "$expected_dirname" ]; then
        echo "  ⚠  Directory mismatch: expected ${expected_dirname}/, got ${dirname}/"
        echo "     (ID: $id)"
    fi

    # Check category directory matches manifest category
    category=$(grep "category:" "$manifest" | head -1 | sed 's/.*category: *"//' | sed 's/".*//')
    # Get category from path (widgets/CATEGORY/widget-name/)
    manifest_category=$(echo "$manifest" | cut -d'/' -f2)

    if [ "$category" != "$manifest_category" ]; then
        echo "  ❌ Category mismatch: manifest says '$category' but file is in '$manifest_category/'"
        errors=$((errors + 1))
    fi

    echo "  ✓ Structure OK"
    echo ""
done

if [ $errors -gt 0 ]; then
    echo "❌ Verification failed with $errors error(s)"
    exit 1
else
    echo "✓ All manifests have correct structure"
    exit 0
fi
