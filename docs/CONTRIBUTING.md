# Contributing to ServerHub Marketplace

Thank you for your interest in contributing a widget to the ServerHub marketplace! This guide will walk you through the submission process.

## Prerequisites

1. **GitHub Account** - Widgets must be hosted on GitHub
2. **Widget Script** - A working ServerHub widget script
3. **Testing** - Your widget should be tested locally with ServerHub

## Submission Process

### Step 1: Prepare Your Widget

1. Create a GitHub repository for your widget
2. Test your widget thoroughly with ServerHub
3. Create a GitHub release with your widget script as an artifact
4. Calculate the SHA256 checksum of your widget file

```bash
# Calculate SHA256 on Linux/macOS
sha256sum your-widget.sh

# On macOS you can also use
shasum -a 256 your-widget.sh
```

### Step 2: Create Widget Manifest

Create a YAML manifest file following this structure:

```yaml
schema_version: "1.0"
metadata:
  id: "username/widget-name"           # Format: your-github-username/widget-name
  name: "Descriptive Widget Name"
  author: "your-github-username"
  homepage: "https://github.com/username/widget-repo"
  description: "Brief description of what your widget does"
  category: "monitoring"               # See categories below
  tags: ["tag1", "tag2", "tag3"]
  license: "MIT"                       # SPDX license identifier
  verification_level: "unverified"     # Start as unverified

versions:
  - version: "1.0.0"
    released: "2024-01-27T12:00:00Z"
    min_serverhub_version: "0.1.0"
    changelog: "Initial release"
    artifacts:
      - name: "widget-name.sh"
        url: "https://github.com/username/widget-repo/releases/download/v1.0.0/widget-name.sh"
        sha256: "your-calculated-sha256-checksum-here"

dependencies:
  system_commands: ["curl", "jq"]      # Required commands
  optional: ["systemctl"]              # Nice-to-have commands

config:
  example: |
    widgets:
      widget-name:
        path: widget-name.sh
        refresh: 10
        sha256: "your-sha256-here"
  default_refresh: 10
```

### Step 3: Submit Pull Request

1. Fork this repository
2. Create a new branch: `git checkout -b add-username-widget-name`
3. Add your manifest file to the appropriate category directory:
   ```
   widgets/<category>/username-widget-name.yaml
   ```
4. Commit your changes:
   ```bash
   git add widgets/<category>/username-widget-name.yaml
   git commit -m "Add username/widget-name to marketplace"
   git push origin add-username-widget-name
   ```
5. Create a Pull Request with:
   - Clear title: "Add username/widget-name widget"
   - Description of what your widget does
   - Screenshots (if applicable)
   - Any special installation notes

### Step 4: Review Process

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

Choose the most appropriate category for your widget:

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

1. Create a new GitHub release with updated widget file
2. Calculate new SHA256 checksum
3. Submit PR updating your manifest with new version entry:

```yaml
versions:
  - version: "1.1.0"              # New version
    released: "2024-02-01T10:00:00Z"
    min_serverhub_version: "0.1.0"
    changelog: "Added feature X, fixed bug Y"
    artifacts:
      - name: "widget-name.sh"
        url: "https://github.com/username/widget-repo/releases/download/v1.1.0/widget-name.sh"
        sha256: "new-sha256-checksum"

  - version: "1.0.0"              # Keep old version
    released: "2024-01-27T12:00:00Z"
    min_serverhub_version: "0.1.0"
    changelog: "Initial release"
    artifacts:
      - name: "widget-name.sh"
        url: "https://github.com/username/widget-repo/releases/download/v1.0.0/widget-name.sh"
        sha256: "old-sha256-checksum"
```

## Need Help?

- Questions? Open a [Discussion](https://github.com/serverhub/serverhub/discussions)
- Found a bug? Report an [Issue](https://github.com/serverhub/serverhub/issues)
- Want to chat? Join our community

## Code of Conduct

Please be respectful and constructive. We're all here to build great tools together.

---

Thank you for contributing to ServerHub! 🚀
