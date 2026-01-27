# ServerHub Widget Registry

Official marketplace for ServerHub community widgets.

## What is ServerHub?

[ServerHub](https://github.com/nickprotop/ServerHub) is an extensible terminal dashboard for Linux servers and homelabs. It provides real-time monitoring and interactive control through customizable widgets.

Unlike traditional monitoring tools that just display data, ServerHub widgets can export context-aware actions—restart services, upgrade packages, manage containers, and more—directly from your dashboard.

**Key features:**
- 14 bundled widgets (CPU, memory, Docker, systemd, updates, etc.)
- Write custom widgets in any language (bash, Python, Node.js, Go, Rust, etc.)
- Security-first design with SHA256 validation
- Responsive terminal UI with keyboard navigation

## 🔍 Browse Widgets

Visit the [ServerHub Marketplace](https://nickprotop.github.io/serverhub-registry/) to browse available widgets.

Or use the CLI:
```bash
serverhub marketplace list
serverhub marketplace search <query>
```

## 📦 Install Widgets

```bash
# Search for widgets
serverhub marketplace search monitoring

# Get detailed information
serverhub marketplace info username/widget-name

# Install a widget
serverhub marketplace install username/widget-name
```

## 🚀 Submit a Widget

Want to share your widget with the community? See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for submission guidelines.

## 🔒 Security

This registry uses a security-first approach:
- **SHA256 checksums** - All widgets have mandatory checksums
- **Code review** - Verified widgets are manually reviewed by maintainers
- **Verification tiers** - Clear badges indicate review status
- **GitHub-only** - Widgets must be hosted on GitHub releases

See [SECURITY.md](docs/SECURITY.md) for our security policy.

## 📋 Widget Categories

- **monitoring** - System and application monitoring widgets
- **infrastructure** - Infrastructure management and status
- **development** - Development tools and workflows
- **databases** - Database monitoring and management
- **networking** - Network status and diagnostics
- **security** - Security monitoring and alerts
- **cloud** - Cloud provider integrations
- **utilities** - General purpose utilities

## 📚 Documentation

- [Contributing Guide](docs/CONTRIBUTING.md) - How to submit widgets
- [Manifest Specification](docs/MANIFEST_SPEC.md) - Widget manifest format
- [Security Policy](docs/SECURITY.md) - Security guidelines

## 📊 Registry Statistics

Total widgets: 0 (marketplace launching soon!)

## 🤝 Community

- Report issues: [ServerHub Issues](https://github.com/nickprotop/serverhub/issues)
- Discussions: [ServerHub Discussions](https://github.com/nickprotop/serverhub/discussions)

---

Built with ❤️ by the ServerHub community
