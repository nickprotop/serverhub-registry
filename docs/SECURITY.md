# Security Policy

ServerHub takes security seriously. This document outlines our security model for the marketplace.

## Security Philosophy

The ServerHub marketplace is designed with a **security-first, trust-explicit** approach:

1. **No Automatic Trust** - Users must explicitly review and approve widgets
2. **Checksum Verification** - SHA256 checksums are mandatory and verified
3. **Transparency** - All widget code is publicly reviewable
4. **Verification Tiers** - Clear indication of review status

## Verification Levels

### ✓ Verified (Green Badge)

- Code has been **manually reviewed** by ServerHub maintainers
- Security best practices followed
- No obvious vulnerabilities found
- Author identity established
- Recommended for general use

**This does NOT mean:**
- The code is bug-free or perfectly secure
- The maintainers take liability for the widget
- You should skip reviewing the code yourself

### ⚡ Community (Yellow Badge)

- Multiple successful installations
- No reported security issues
- Basic automated security scans passed
- Not fully reviewed by maintainers

**Use with caution:**
- Review the code yourself before installing
- Check the widget's repository for activity
- Look for community feedback

### ⚠ Unverified (Red Badge)

- New submission or low install count
- Has NOT been reviewed by maintainers
- May contain security issues

**Strong warning shown before installation:**
- You MUST review the source code
- Installation requires explicit confirmation
- You are responsible for any consequences

## Security Review Process

When reviewing widgets for "Verified" status, maintainers check for:

### Code Review
- [ ] No hardcoded credentials or API keys
- [ ] No obvious command injection vulnerabilities
- [ ] No destructive commands (rm -rf, dd, mkfs, etc.)
- [ ] Input validation for user-provided data
- [ ] Proper error handling
- [ ] No obfuscated or suspicious code

### Network Security
- [ ] HTTPS used for all network requests
- [ ] URLs point to legitimate services
- [ ] No data exfiltration patterns
- [ ] Reasonable API usage

### Resource Usage
- [ ] No excessive CPU/memory consumption
- [ ] Reasonable refresh intervals
- [ ] Commands have timeouts
- [ ] No infinite loops or recursion

### Dependencies
- [ ] All required commands are documented
- [ ] Dependencies are reasonable for the widget's purpose
- [ ] No unnecessary sudo/root requirements

## SHA256 Checksum Security

**Critical Security Feature:**

1. **Mandatory** - Every widget artifact MUST have a SHA256 checksum
2. **Verified** - Checksums are verified during installation
3. **Immutable** - Once installed, checksums lock the widget version
4. **Transparent** - Checksum changes are clearly shown during updates

**What this protects against:**
- ✅ Modified widget files (tampering)
- ✅ Compromised GitHub releases
- ✅ Man-in-the-middle attacks
- ✅ Accidental file corruption

**What this does NOT protect against:**
- ❌ Malicious code in the original widget (review the code!)
- ❌ Vulnerabilities in dependencies
- ❌ Social engineering

## URL Restrictions

Widgets can only be downloaded from:
- `https://github.com/*/releases/download/*`
- `https://raw.githubusercontent.com/*`

This prevents:
- Widgets hosted on untrusted domains
- HTTP (unencrypted) downloads
- Arbitrary file hosting services

## Reporting Security Issues

### Found a vulnerability in a marketplace widget?

**DO NOT create a public issue.** Instead:

1. Email: security@serverhub.dev (or create a private security advisory)
2. Include:
   - Widget ID and version
   - Description of the vulnerability
   - Proof of concept (if applicable)
   - Suggested fix (if you have one)

We will:
1. Acknowledge within 48 hours
2. Investigate and assess severity
3. Work with widget author to fix
4. Remove widget from marketplace if critical and unfixed
5. Publish security advisory once patched

### Found a vulnerability in ServerHub itself?

Report it through the main [ServerHub repository](https://github.com/serverhub/serverhub/security).

## User Responsibilities

**Installing marketplace widgets is your responsibility:**

1. **Review the Code** - Always read the widget source before installing
2. **Check Dependencies** - Understand what system commands the widget uses
3. **Verify Author** - Check the author's GitHub profile and repository
4. **Read Changelog** - Review what changed in updates
5. **Test Safely** - Test new widgets in a non-production environment first

**Red flags to watch for:**
- 🚩 Requests for sudo/root access without clear reason
- 🚩 Obfuscated or hard-to-read code
- 🚩 Downloads additional scripts from the internet
- 🚩 Modifies system files or configuration
- 🚩 Makes network requests to unknown domains
- 🚩 No documentation or unclear purpose
- 🚩 Author has no public history on GitHub

## Security Best Practices for Widget Authors

If you're submitting a widget:

### Do ✅
- Use HTTPS for all network requests
- Validate and sanitize all user input
- Handle errors gracefully
- Document all dependencies
- Use meaningful variable names
- Comment complex logic
- Provide clear error messages
- Test edge cases
- Follow principle of least privilege

### Don't ❌
- Hardcode credentials or secrets
- Use `eval` with user input
- Execute downloaded code without verification
- Require sudo unless absolutely necessary
- Use destructive commands
- Make network requests to unknown domains
- Obfuscate your code
- Collect user data without disclosure

## Incident Response

If a security issue is discovered in a verified widget:

1. **Immediate** - Widget marked as "unverified" in registry
2. **24 hours** - Security advisory published
3. **48 hours** - Widget removed if unfixed and critical
4. **1 week** - Author given time to fix and resubmit

## Verification Tier Updates

- **Unverified → Community** - Automated after 25+ installs with no issues
- **Community → Verified** - Manual review by maintainers
- **Verified → Unverified** - If security issues found or author MIA
- **Any → Removed** - If critical security issue and unfixed

## Security Scanning

Automated CI checks run on all PRs:

1. **Manifest Validation** - Schema and format checks
2. **Checksum Verification** - Download and verify SHA256
3. **ShellCheck** - Static analysis of shell scripts
4. **Pattern Matching** - Scan for suspicious patterns:
   - Hardcoded IPs/credentials
   - Destructive commands
   - Command injection patterns
   - Data exfiltration attempts

**Note:** Automated scans are not perfect. Manual review is still required for "Verified" status.

## Updates and Transparency

This security policy may be updated as we learn and improve. All changes will be:
- Documented in git history
- Announced to the community
- Applied consistently to all widgets

---

**Remember:** The marketplace provides tools for security, but **you** are ultimately responsible for what runs on your system. When in doubt, review the code. 🔒
