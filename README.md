# Sovereign Ops Toolbox

Practical automation for systems administration, infrastructure, and security operations.

Sovereign Ops Toolbox contains scripts developed from real troubleshooting scenarios and day-to-day operational work. The emphasis is on clarity, maintainability, and solving actual problems rather than building frameworks for their own sake.

The goal is simple:

**Find the repetitive work. Automate it. Document it. Improve it.**

---

## Repository Purpose

This repository exists to transform operational experience into reusable tooling.

These scripts aren't academic exercises. They're built to answer real questions encountered during support, administration, and troubleshooting.

Questions like:

* Is the device online?
* What services are exposed?
* What ports are open?
* Can this task be automated?
* How do we solve this once instead of twenty times?

---

## Repository Structure

```text
Sovereign-Ops-Toolbox/
├── Powershell/
│   ├── Examples/
│   ├── Infrastructure/
│   └── Security/
├── Python/
│   ├── Examples/
│   ├── Infrastructure/
│   └── Security/
├── Bash/
│   ├── Examples/
│   ├── Infrastructure/
│   └── Security/
├── Docs/
├── LICENSE
├── SECURITY.md
└── README.md
```

---

## PowerShell

### Examples

#### Test-DeviceOnlineStatus.ps1

Determines whether one or more devices respond to ping.

Features:

* Manual input
* TXT input
* CSV input
* Target deduplication
* PSCustomObject output

Purpose:

> Can I reach the device?

---

### Infrastructure

#### New-BulkADUser.ps1

Automates Active Directory user creation from structured input.

Features:

* Bulk user creation
* Identity lifecycle automation
* Structured processing
* Reduced repetitive administration

Purpose:

> How do we onboard efficiently?

---

#### Test-DeviceOpenPorts.ps1

Validates TCP connectivity against target systems.

Features:

* TCP port testing
* Service validation
* Operational diagnostics

Purpose:

> What services are reachable?

---

### Security

#### Test-DeviceExposureStatus.ps1

Evaluates exposed services using predefined security profiles.

Features:

* Severity ratings
* Recommendations
* Findings-based reporting
* TXT and CSV support

Purpose:

> Should I be concerned about what I'm seeing?

---

## Python

Cross-platform implementations demonstrating continued growth beyond the Microsoft ecosystem.

* test_device_online_status.py
* test_device_open_ports.py
* test_device_exposure_status.py

Focus Areas:

* argparse
* socket programming
* subprocess execution
* structured output
* defensive visibility

---

## Bash

Linux-native implementations focused on operational fundamentals.

* test-device-online-status.sh
* test-device-open-ports.sh
* test-device-exposure-status.sh

Focus Areas:

* shell scripting
* diagnostics
* service validation
* defensive visibility
* cross-platform administration

---

## Philosophy

Every script follows the same progression:

```text
Identify the problem
↓
Build a working solution
↓
Refine the implementation
↓
Document the process
↓
Create reusable operational tooling
```

The objective is not to build the largest script repository.

The objective is to build tools that are understandable, maintainable, and genuinely useful.

---

## Current Status

Sovereign Ops Toolbox is actively evolving.

New scripts are added as operational challenges emerge and mature into reusable solutions.

Practical value always takes priority over quantity.

---

## Technologies

* PowerShell
* Python
* Bash
* Active Directory
* Windows Administration
* Infrastructure Operations
* Security Operations
* Cross-Platform Automation

---

## Author

**Ron Daniels**

Veteran. Systems builder. Founder @ Cyberron.

* GitHub: https://github.com/RDaniels113
* Website: https://cyberron.org
* LinkedIn: https://linkedin.com/in/rdaniels113
