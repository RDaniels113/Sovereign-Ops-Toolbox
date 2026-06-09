# Script Standards

## Purpose

These standards are intended to promote consistency, maintainability, and readability across all scripts within the Sovereign Ops Toolbox repository.

---

## General Principles

Scripts should be:

* Readable
* Maintainable
* Documented
* Error-aware
* Safe to execute

Whenever possible, avoid unnecessary complexity.

---

## Naming Conventions

### PowerShell

```text
Verb-Noun.ps1
```

Examples:

```text
Get-SystemInventory.ps1
Get-EndpointCompliance.ps1
Test-SecurityBaseline.ps1
```

### Python

```text
snake_case.py
```

Examples:

```text
system_inventory.py
security_audit.py
license_report.py
```

### Bash

```text
lowercase-hyphen.sh
```

Examples:

```text
system-info.sh
security-check.sh
log-review.sh
```

---

## Documentation

Production-ready scripts should include:

* Purpose
* Parameters
* Requirements
* Usage examples

PowerShell scripts should use comment-based help whenever practical.

---

## Error Handling

Scripts should:

* Validate input
* Handle common failures gracefully
* Return meaningful error messages
* Avoid silent failures

---

## Output

Whenever practical:

* Use structured output
* Support CSV export
* Support logging
* Avoid excessive console noise

---

## Security

Scripts should never contain:

* Hardcoded passwords
* API keys
* Access tokens
* Sensitive organizational data

All examples should be sanitized before publication.

---

## Repository Philosophy

Functionality is more important than complexity.

A simple script that solves a real problem is more valuable than a complex script that solves none.
