# Sovereign Ops Toolbox

A growing collection of security and infrastructure scripts for practical IT operations.

This repository contains PowerShell, Python, and Bash utilities focused on system administration, endpoint management, security validation, infrastructure support, and operational automation.

The objective is simple: build a library of tools that solve real-world problems encountered by systems administrators, infrastructure engineers, and security practitioners.

---

## Current Status

This repository is actively maintained and developed in public.

Each language section currently contains:

* Functional scripts used for operational tasks
* Template/example scripts used for structure and future development
* Supporting documentation where applicable

Scripts are clearly labeled according to their current maturity.

### Status Definitions

| Status      | Description                             |
| ----------- | --------------------------------------- |
| Functional  | Tested and usable for intended purpose  |
| Template    | Example structure or learning reference |
| In Progress | Under active development                |
| Planned     | Scheduled for future implementation     |
| Deprecated  | Retained for historical reference       |

---

## Repository Structure

```text
Sovereign-Ops-Toolbox/
│
├── powershell/
│   ├── security/
│   ├── infrastructure/
│   └── examples/
│
├── python/
│   ├── security/
│   ├── infrastructure/
│   └── examples/
│
├── bash/
│   ├── security/
│   ├── infrastructure/
│   └── examples/
│
└── docs/
```

---

## Language Focus Areas

### PowerShell

Focused on Microsoft-centric administration and automation.

Examples include:

* Endpoint administration
* Windows configuration validation
* Active Directory and Entra ID support
* Microsoft 365 operations
* Infrastructure automation
* Reporting and diagnostics

### Python

Focused on cross-platform automation, reporting, and data processing.

Examples include:

* Security tooling
* Data collection and analysis
* Reporting utilities
* Log parsing
* Operational workflows

### Bash# Sovereign-Ops-Toolbox

Operational scripting focused on systems administration, infrastructure, and security.

This repository contains practical PowerShell tools developed from real troubleshooting scenarios and day-to-day operational work. The emphasis is on clarity, maintainability, and solving actual problems rather than building frameworks for their own sake.

---

## Current Focus

* PowerShell automation
* Infrastructure operations
* Security validation
* Identity administration
* Repeatable troubleshooting workflows

---

## Repository Structure

```text
Sovereign-Ops-Toolbox/
├── examples/
├── infrastructure/
├── security/
└── docs/
```

---

## Examples

Example scripts designed to teach concepts clearly and solve common operational problems.

### Current Scripts

#### Test-DeviceOnlineStatus.ps1

Tests whether one or more devices respond to ping.

Features:

* Supports manual input
* Supports TXT input
* Supports CSV input
* Removes duplicate targets
* Returns structured output objects
* Demonstrates arrays, looping, and input normalization

Example use:

```powershell
.\Test-DeviceOnlineStatus.ps1 -Target "google.com"

.\Test-DeviceOnlineStatus.ps1 -InputTxt .\devices.txt

.\Test-DeviceOnlineStatus.ps1 -InputCsv .\devices.csv
```

Purpose:

> "Can I reach the device?"

---

## Infrastructure

Operational tools intended for systems and infrastructure administration.

### Current Scripts

#### New-BulkADUser.ps1

Creates Active Directory users in bulk from structured input.

Features:

* Bulk user creation
* Structured input processing
* Reduced repetitive administration
* Identity lifecycle automation

Purpose:

> Automate common onboarding activities.

---

#### Test-DeviceOpenPorts.ps1

Performs network port checks against target systems.

Features:

* Port availability testing
* Service validation
* Network diagnostics
* Operational troubleshooting

Purpose:

> "What services are reachable on this device?"

---

### Infrastructure Focus Areas

* Active Directory administration
* Identity lifecycle operations
* Network diagnostics
* Operational reporting
* Repeatable infrastructure automation

---

## Security

Security-focused scripts intended to identify findings and support defensive operations.

### Current Scripts

#### Test-DeviceExposureStatus.ps1

Evaluates exposed services on target systems and reports findings based on severity.

Features:

* Supports manual input
* Supports TXT input
* Supports CSV input
* Uses predefined security port profiles
* Reports findings only when exposures exist
* Assigns severity ratings
* Provides recommendations

Purpose:

> "Should I be concerned about what I'm seeing?"

Example findings include:

* Telnet exposure
* RDP exposure
* SMB exposure
* Unsecured HTTP services
* Administrative surface review

---

### Security Focus Areas

* Exposure assessment
* Baseline validation
* Administrative surface review
* Defensive visibility
* Security-oriented reporting

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
* Active Directory
* Windows Administration
* Infrastructure Operations
* Security Operations

---

## License

This project is licensed under the terms of the LICENSE file included in this repository.


Focused on Linux and macOS administration.

Examples include:

* System validation
* Log analysis
* Security checks
* Configuration auditing
* Infrastructure support tasks

---

## Philosophy

The goal of this repository is not to accumulate hundreds of scripts.

The goal is to build a collection of tools that are understandable, maintainable, and useful in real operational environments.

Whenever possible, scripts should include:

* Clear documentation
* Error handling
* Logging
* Parameter validation
* Practical examples

---

## Disclaimer

This repository is being built in public.

Scripts marked Functional are intended for operational use.

Scripts marked Template or In Progress are provided as references, learning resources, or foundations for future development and should be reviewed before production use.

---

## Areas of Interest

Current development priorities include:

* Endpoint Management
* Microsoft Intune
* Microsoft 365 Administration
* Entra ID
* Infrastructure Automation
* Security Operations
* Compliance Validation
* Operational Reporting

---

## License

This repository is released under the MIT License.

