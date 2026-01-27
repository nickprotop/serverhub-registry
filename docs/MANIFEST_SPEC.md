# Widget Manifest Specification

Version: 1.0

## Overview

Widget manifests are YAML files that describe a ServerHub marketplace widget, its versions, dependencies, and metadata.

## File Location

Manifests are stored in the registry repository under:
```
widgets/<category>/<username-widget-name>.yaml
```

## Full Example

```yaml
schema_version: "1.0"

metadata:
  id: "username/widget-name"
  name: "Human-Readable Widget Name"
  author: "github-username"
  homepage: "https://github.com/username/widget-repo"
  description: "Brief description of what the widget does (1-2 sentences)"
  category: "monitoring"
  tags: ["api", "health", "http"]
  license: "MIT"
  verification_level: "verified"

versions:
  - version: "1.0.0"
    released: "2024-01-27T12:00:00Z"
    min_serverhub_version: "0.1.0"
    changelog: "Initial release with basic functionality"
    artifacts:
      - name: "widget-name.sh"
        url: "https://github.com/username/widget-repo/releases/download/v1.0.0/widget-name.sh"
        sha256: "a1b2c3d4e5f6789..."

dependencies:
  system_commands: ["curl", "jq"]
  optional: ["systemctl", "docker"]

config:
  example: |
    widgets:
      widget-name:
        path: widget-name.sh
        refresh: 10
        sha256: "a1b2c3d4e5f6789..."
  default_refresh: 10
```

## Field Reference

### `schema_version` (required)

**Type:** String
**Example:** `"1.0"`

The manifest schema version. Currently always `"1.0"`.

### `metadata` (required)

Container for widget metadata.

#### `metadata.id` (required)

**Type:** String
**Format:** `username/widget-name`
**Pattern:** `^[a-z0-9-]+/[a-z0-9-]+$`
**Example:** `"johndoe/api-monitor"`

Unique identifier for the widget. Format is `github-username/widget-name`.

**Rules:**
- Must be lowercase
- Only letters, numbers, and hyphens
- Must match repository structure

#### `metadata.name` (required)

**Type:** String
**Example:** `"API Health Monitor"`

Human-readable name displayed in the marketplace.

#### `metadata.author` (required)

**Type:** String
**Example:** `"johndoe"`

GitHub username of the widget author.

#### `metadata.homepage` (required)

**Type:** String (URL)
**Example:** `"https://github.com/johndoe/api-health-widget"`

URL to the widget's source repository.

#### `metadata.description` (required)

**Type:** String
**Example:** `"Monitor API endpoints with status indicators and quick restart actions"`

Brief description (1-2 sentences) of what the widget does.

#### `metadata.category` (required)

**Type:** String (enum)
**Allowed values:**
- `monitoring`
- `infrastructure`
- `development`
- `databases`
- `networking`
- `security`
- `cloud`
- `utilities`

Primary category for the widget.

#### `metadata.tags` (optional)

**Type:** Array of strings
**Example:** `["api", "health", "http", "monitoring"]`

Keywords for search and discovery.

#### `metadata.license` (required)

**Type:** String (SPDX identifier)
**Example:** `"MIT"`, `"Apache-2.0"`, `"GPL-3.0"`

[SPDX license identifier](https://spdx.org/licenses/) for the widget.

#### `metadata.verification_level` (required)

**Type:** String (enum)
**Allowed values:**
- `verified` - Reviewed and approved by maintainers
- `community` - Multiple installs, no issues reported
- `unverified` - New or untested

Verification status of the widget.

### `versions` (required)

**Type:** Array of version objects

List of available versions, newest first recommended.

#### `versions[].version` (required)

**Type:** String (semantic version)
**Example:** `"1.0.0"`, `"2.1.3-beta"`

[Semantic version](https://semver.org/) number.

#### `versions[].released` (required)

**Type:** String (ISO 8601 datetime)
**Example:** `"2024-01-27T12:00:00Z"`

Release date and time in ISO 8601 format (UTC).

#### `versions[].min_serverhub_version` (required)

**Type:** String (semantic version)
**Example:** `"0.1.0"`

Minimum ServerHub version required.

#### `versions[].changelog` (required)

**Type:** String
**Example:** `"Added support for custom headers, fixed timeout bug"`

Description of changes in this version.

#### `versions[].artifacts` (required)

**Type:** Array of artifact objects

Files to download for this version.

##### `artifacts[].name` (required)

**Type:** String
**Example:** `"api-health.sh"`

Filename of the artifact.

##### `artifacts[].url` (required)

**Type:** String (URL)
**Example:** `"https://github.com/user/repo/releases/download/v1.0.0/api-health.sh"`

Download URL. Must be:
- HTTPS only
- GitHub releases or raw.githubusercontent.com
- Publicly accessible

##### `artifacts[].sha256` (required)

**Type:** String (hex)
**Format:** 64 lowercase hexadecimal characters
**Example:** `"a1b2c3d4e5f6..."`

SHA256 checksum of the file.

**How to calculate:**
```bash
sha256sum api-health.sh
# or
shasum -a 256 api-health.sh
```

### `dependencies` (optional)

Container for dependency information.

#### `dependencies.system_commands` (optional)

**Type:** Array of strings
**Example:** `["curl", "jq", "grep"]`

List of required system commands. Installation will fail if these are not found.

#### `dependencies.optional` (optional)

**Type:** Array of strings
**Example:** `["systemctl", "docker"]`

List of optional commands. Installation proceeds with warnings if these are missing.

### `config` (optional)

Container for configuration examples and defaults.

#### `config.example` (optional)

**Type:** String (multiline)
**Example:**
```yaml
example: |
  widgets:
    my-widget:
      path: my-widget.sh
      refresh: 10
      sha256: "abc123..."
```

Example ServerHub configuration for the widget.

#### `config.default_refresh` (optional)

**Type:** Integer (seconds)
**Example:** `10`

Recommended refresh interval in seconds.

## Validation

Manifests are validated against [widget-v1.schema.json](../schemas/widget-v1.schema.json) in CI.

## Best Practices

1. **Keep latest version first** in the versions array
2. **Document all dependencies** to help users prepare
3. **Provide good examples** in the config section
4. **Write clear changelogs** for each version
5. **Use semantic versioning** consistently
6. **Keep descriptions concise** - save details for README
7. **Test checksums** before submitting

## Common Mistakes

❌ **Incorrect checksum** - Always verify before submitting:
```bash
sha256sum your-widget.sh
# Copy the EXACT output (lowercase hex)
```

❌ **Wrong URL pattern** - Must be GitHub releases or raw content:
```yaml
# ✅ Good
url: "https://github.com/user/repo/releases/download/v1.0.0/widget.sh"
url: "https://raw.githubusercontent.com/user/repo/main/widget.sh"

# ❌ Bad
url: "https://example.com/widget.sh"
url: "http://github.com/..."  # Must be HTTPS
```

❌ **Mismatched ID and filename** - These should align:
```yaml
# Filename: widgets/monitoring/johndoe-api-health.yaml
metadata:
  id: "johndoe/api-health"  # ✅ Matches
  id: "johndoe/api_health"  # ❌ Underscore doesn't match hyphen
```

❌ **Missing required fields** - All fields marked "required" must be present

❌ **Invalid category** - Must be one of the allowed values

## Version History

- **v1.0** (2024-01-27) - Initial specification

---

Questions? See [CONTRIBUTING.md](CONTRIBUTING.md) or open a discussion.
