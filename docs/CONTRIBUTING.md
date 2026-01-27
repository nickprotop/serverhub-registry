# Contributing to ServerHub Marketplace

Thank you for your interest in contributing a widget to the ServerHub marketplace!

## Submission Process

### Step 1: Prepare Your Widget

1. **Create your widget script** - Any language (bash, Python, Node.js, etc.)
2. **Test thoroughly** - Ensure it works with ServerHub
3. **Follow the widget protocol** - See ServerHub documentation
4. **Write documentation** - README with usage instructions

### Step 2: Calculate SHA256 Checksum

```bash
sha256sum your-widget.sh
```

Keep this checksum - you'll need it for the manifest.

### Step 3: Prepare Repository Submission

Fork the `serverhub-registry` repository and create a new branch:

```bash
git clone https://github.com/YOUR-USERNAME/serverhub-registry.git
cd serverhub-registry
git checkout -b add-username-widget-name
```

### Step 4: Add Your Widget Files

Create the following structure:

```
widgets/<category>/<username-widget-name>/
├── manifest.yaml          # Widget metadata
├── README.md              # Widget documentation
└── v1.0.0/               # Version directory
    └── widget-name.sh     # Your widget script
```

**Example:**

```bash
# Create directories
mkdir -p widgets/monitoring/johndoe-api-monitor/v1.0.0

# Copy your widget script
cp ~/my-api-monitor.sh widgets/monitoring/johndoe-api-monitor/v1.0.0/api-monitor.sh
chmod +x widgets/monitoring/johndoe-api-monitor/v1.0.0/api-monitor.sh

# Calculate checksum
sha256sum widgets/monitoring/johndoe-api-monitor/v1.0.0/api-monitor.sh
```

### Step 5: Create manifest.yaml

Create `widgets/<category>/<username-widget-name>/manifest.yaml`:

```yaml
schema_version: "1.0"

metadata:
  id: "johndoe/api-monitor"
  name: "API Health Monitor"
  author: "johndoe"
  homepage: "https://github.com/nickprotop/serverhub-registry/tree/main/widgets/monitoring/johndoe-api-monitor"
  description: "Monitor API endpoints with status indicators"
  category: "monitoring"
  tags: ["api", "health", "http"]
  license: "MIT"
  verification_level: "unverified"

versions:
  - version: "1.0.0"
    released: "2024-01-27T12:00:00Z"
    min_serverhub_version: "0.1.0"
    changelog: "Initial release"
    artifacts:
      - name: "api-monitor.sh"
        url: "https://raw.githubusercontent.com/nickprotop/serverhub-registry/main/widgets/monitoring/johndoe-api-monitor/v1.0.0/api-monitor.sh"
        sha256: "YOUR_CALCULATED_SHA256_HERE"

dependencies:
  system_commands: ["curl", "jq"]
  optional: []

config:
  example: |
    widgets:
      api-monitor:
        path: api-monitor.sh
        refresh: 30
        sha256: "YOUR_CALCULATED_SHA256_HERE"
  default_refresh: 30
```

**Important:**
- Set `verification_level: "unverified"` for new submissions
- Use the full raw.githubusercontent.com URL for the artifact
- Include the exact SHA256 checksum

### Step 6: Create README.md

Create `widgets/<category>/<username-widget-name>/README.md`:

```markdown
# Your Widget Name

Brief description of what your widget does.

## Features

- Feature 1
- Feature 2

## Installation

### Via Marketplace

\`\`\`bash
serverhub marketplace install yourusername/your-widget
\`\`\`

## Configuration

\`\`\`yaml
widgets:
  your-widget:
    path: your-widget.sh
    refresh: 30
    sha256: "..."
\`\`\`

## Requirements

- Required: curl, jq
- Optional: systemctl

## License

MIT
```

### Step 7: Submit Pull Request

```bash
git add widgets/
git commit -m "Add johndoe/api-monitor widget"
git push origin add-username-widget-name
```

Then create a Pull Request on GitHub with:
- Clear title: "Add johndoe/api-monitor widget"
- Description of what your widget does
- Screenshots if applicable

### Step 8: Review Process

Your submission will be reviewed by ServerHub maintainers:

1. **Automated Checks** - CI validates manifest syntax and checksums
2. **Security Scan** - Basic security checks for suspicious patterns
3. **Manual Review** - Code review for security and quality
4. **Testing** - Maintainers test your widget

**Review Criteria:**
- ✅ Code is readable and well-documented
- ✅ No obvious security issues
- ✅ Widget works as described
- ✅ Follows ServerHub widget protocol
- ✅ Dependencies are reasonable
- ✅ SHA256 checksum matches

**Possible Outcomes:**
- **Verified** - Code reviewed and approved (green badge)
- **Community** - Accepted but needs more testing (yellow badge)
- **Changes Requested** - Issues to fix before merging
- **Rejected** - Does not meet requirements

## Widget Categories

Choose the most appropriate category:

- `monitoring` - System and application monitoring
- `infrastructure` - Infrastructure management and status
- `development` - Development tools and workflows
- `databases` - Database monitoring and management
- `networking` - Network status and diagnostics
- `security` - Security monitoring and alerts
- `cloud` - Cloud provider integrations (AWS, Azure, GCP, etc.)
- `utilities` - General purpose utilities

## Widget Best Practices

### Security
- ❌ Never hardcode credentials or secrets
- ❌ Avoid destructive commands (rm -rf, dd, mkfs)
- ✅ Validate user input
- ✅ Use HTTPS for network requests
- ✅ Handle errors gracefully

### Performance
- ✅ Keep refresh intervals reasonable (≥ 5 seconds recommended)
- ✅ Timeout long-running commands
- ✅ Cache expensive operations
- ✅ Minimize network requests

### User Experience
- ✅ Provide clear output in compact and expanded views
- ✅ Use color coding for status (green/yellow/red)
- ✅ Include helpful actions for common tasks
- ✅ Document configuration options
- ✅ Provide meaningful error messages

### Code Quality
- ✅ Add a shebang line (#!/bin/bash or #!/usr/bin/env python3)
- ✅ Include comments for complex logic
- ✅ Follow shell scripting best practices
- ✅ Handle edge cases
- ✅ Test on multiple systems if possible

## Updating Your Widget

To release a new version:

1. Create a new version directory:

```bash
mkdir -p widgets/monitoring/johndoe-api-monitor/v1.1.0
cp improved-api-monitor.sh widgets/monitoring/johndoe-api-monitor/v1.1.0/api-monitor.sh
chmod +x widgets/monitoring/johndoe-api-monitor/v1.1.0/api-monitor.sh
```

2. Calculate new SHA256:

```bash
sha256sum widgets/monitoring/johndoe-api-monitor/v1.1.0/api-monitor.sh
```

3. Update manifest.yaml (add new version at the top):

```yaml
versions:
  - version: "1.1.0"              # New version
    released: "2024-02-01T10:00:00Z"
    min_serverhub_version: "0.1.0"
    changelog: "Added feature X, fixed bug Y"
    artifacts:
      - name: "api-monitor.sh"
        url: "https://raw.githubusercontent.com/nickprotop/serverhub-registry/main/widgets/monitoring/johndoe-api-monitor/v1.1.0/api-monitor.sh"
        sha256: "new-sha256-checksum"

  - version: "1.0.0"              # Keep old version
    released: "2024-01-27T12:00:00Z"
    min_serverhub_version: "0.1.0"
    changelog: "Initial release"
    artifacts:
      - name: "api-monitor.sh"
        url: "https://raw.githubusercontent.com/nickprotop/serverhub-registry/main/widgets/monitoring/johndoe-api-monitor/v1.0.0/api-monitor.sh"
        sha256: "old-sha256-checksum"
```

4. Submit PR with version update

## Need Help?

- Questions? Open a [Discussion](https://github.com/nickprotop/serverhub-registry/discussions)
- Found a bug? Report an [Issue](https://github.com/nickprotop/serverhub-registry/issues)

## Code of Conduct

Please be respectful and constructive. We're all here to build great tools together.

---

Thank you for contributing to ServerHub! 🚀
