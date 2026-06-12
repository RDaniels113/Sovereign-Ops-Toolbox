# Sovereign-Ops-Toolbox

Operational scripting focused on systems administration, infrastructure, and security.

This repository contains practical automation tools developed from real troubleshooting scenarios and day-to-day operational work. The emphasis is on clarity, maintainability, and solving actual problems rather than building frameworks for their own sake.

---

## Language Focus

PowerShell is the primary language used throughout this repository and reflects the majority of my operational experience.

Python implementations demonstrate cross-platform automation capability and continued growth beyond the Microsoft ecosystem.

Bash implementations demonstrate Linux operational familiarity and shell scripting fundamentals.

---

## Repository Structure

```text
Sovereign-Ops-Toolbox/
├── powershell/
│   ├── examples/
│   ├── infrastructure/
│   └── security/
│
├── python/
│   ├── examples/
│   ├── infrastructure/
│   └── security/
│
├── bash/
│   ├── examples/
│   ├── infrastructure/
│   └── security/
│
├── docs/
└── README.md
```

---

## PowerShell

### Examples

#### Test-DeviceOnlineStatus.ps1

Tests whether one or more devices respond to ping.

Features:

* Manual input
* TXT input
* CSV input
* Input normalization
* Target deduplication
* Structured output using PSCustomObject

Purpose:

> "Can I reach the device?"

---

### Infrastructure

#### New-BulkADUser.ps1

Creates Active Directory users in bulk from structured input.

Features:

* Bulk user creation
* Structured data processing
* Reduced repetitive administration
* Identity lifecycle automation

Purpose:

> Automate common onboarding activities.

---

#### Test-DeviceOpenPorts.ps1

Performs network port checks against target systems.

Features:

* TCP port validation
* Service troubleshooting
* Operational diagnostics

Purpose:

> "What services are reachable on this device?"

---

### Security

#### Test-DeviceExposureStatus.ps1

Evaluates exposed services on target systems.

Features:

* Security port profiles
* Severity ratings
* Recommendations
* Findings-based reporting
* TXT and CSV support

Purpose:

> "Should I be concerned about what I'm seeing?"

---

## Python

### Examples

#### test_device_online_status.py

Tests whether one or more devices respond to ping.

Features:

* argparse
* TXT input
* CSV input
* subprocess execution
* Target deduplication
* Structured results

Purpose:

> "Can I reach the device?"

---

### Infrastructure

#### test_device_open_ports.py

Performs TCP port validation against target systems.

Features:

* socket programming
* Configurable port testing
* Network diagnostics
* Service validation
* Structured output

Purpose:

> "What services are reachable on this device?"

---

### Security

#### test_device_exposure_status.py

Evaluates exposed services using predefined security profiles.

Features:

* Findings-based reporting
* Severity classification
* Recommendations
* Security profile mapping
* Defensive visibility

Purpose:

> "Should I be concerned about what I'm seeing?"

---

## Bash

### Examples

#### test-device-online-status.sh

Tests whether one or more devices respond to ping.

Features:

* TXT input
* CSV input
* Cross-platform shell fundamentals
* Target deduplication
* Basic operational validation

Purpose:

> "Can I reach the device?"

---

### Infrastructure

#### test-device-open-ports.sh

Performs TCP port checks against target systems.

Features:

* Service validation
* Network diagnostics
* Operational troubleshooting
* Linux-native tooling

Purpose:

> "What services are reachable on this device?"

---

### Security

#### test-device-exposure-status.sh

Evaluates exposed services and reports findings.

Features:

* Findings-based reporting
* Severity classifications
* Security recommendations
* Defensive visibility

Purpose:

> "Should I be concerned about what I'm seeing?"

---

## Philosophy

The scripts in this repository follow a simple progression:

```text
Identify the problem
↓
Create a working solution
↓
Refine the solution
↓
Document the process
↓
Build reusable operational tooling
```

The goal is not to build the largest collection of scripts.

The goal is to build tools that are understandable, maintainable, and useful.

---

## Current Status

This repository is actively evolving.

New scripts are added as operational challenges are encountered and refined into reusable solutions.

Quality and practical value take priority over quantity.

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

## License

This project is licensed under the terms of the LICENSE file included in this repository.
