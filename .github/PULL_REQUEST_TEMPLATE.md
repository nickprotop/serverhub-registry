# Widget Submission

## Widget Information

**Widget ID:** `username/widget-name`
**Category:** monitoring|infrastructure|development|databases|networking|security|cloud|utilities
**Version:** 1.0.0

## Description

Brief description of what your widget does and why it's useful.

## Checklist

### Author Information
- [ ] GitHub account > 6 months old OR clear identity/organization
- [ ] Repository has meaningful commit history
- [ ] README with usage instructions

### Code Review
- [ ] Source code manually reviewed for malicious behavior
- [ ] No hardcoded credentials or secrets
- [ ] No obvious command injection vulnerabilities
- [ ] No destructive commands (rm -rf, dd, mkfs, etc.)
- [ ] Network requests to legitimate APIs only
- [ ] Reasonable resource usage
- [ ] Error handling implemented

### Manifest Validation
- [ ] SHA256 checksum manually verified (downloaded file and calculated hash)
- [ ] All URLs point to GitHub releases or raw.githubusercontent.com
- [ ] Description is accurate and clear
- [ ] License specified (valid SPDX identifier)
- [ ] Dependencies documented
- [ ] Category is appropriate

### Testing
- [ ] Widget runs successfully on my system
- [ ] Output follows ServerHub protocol (compact/expanded views)
- [ ] No errors in logs
- [ ] Actions (if any) work correctly
- [ ] Tested with required dependencies
- [ ] Tested without optional dependencies

### Documentation
- [ ] Repository has README with usage instructions
- [ ] Configuration example provided in manifest
- [ ] Dependencies clearly listed

## Additional Notes

<!-- Any special installation notes, known issues, or other information for reviewers -->

## Verification Status Request

I am requesting this widget be marked as:
- [ ] `verified` - I believe this meets all criteria for verified status
- [ ] `community` - This is ready for community testing
- [ ] `unverified` - This is an initial submission for feedback

---

By submitting this PR, I confirm:
- [ ] I am the author of this widget or have permission to submit it
- [ ] The widget is licensed under an open source license
- [ ] I have read and agree to the [Security Policy](../docs/SECURITY.md)
- [ ] I will maintain this widget and respond to security issues
