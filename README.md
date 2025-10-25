# Sovereign Ops Toolbox

**Code repository for system administration, information security, and automation.**

This repository contains production-ready scripts and tools developed across multiple technical domains. Each script is documented, tested, and designed for real-world operational use.

## Repository Purpose

Sovereign Ops Toolbox is where the code lives - the actual executable work that powers infrastructure, automates tasks, and solves operational problems. Organized by domain and function for easy discovery and reuse.

---

## Repository Structure

```
Sovereign-Ops-Toolbox/
├── README.md
├── PowerShell/
│   ├── ActiveDirectory/
│   ├── SystemAdministration/
│   ├── Security/
│   ├── Automation/
│   └── Monitoring/
├── Python/
│   ├── LogAnalysis/
│   ├── Automation/
│   ├── Security/
│   └── Reporting/
├── Bash/
│   ├── SystemAdministration/
│   ├── Security/
│   ├── Monitoring/
│   └── Automation/
└── docs/
    └── standards/
```

---

## PowerShell Scripts

### Active Directory Management
**Location:** `/PowerShell/ActiveDirectory/`

Scripts for user provisioning, group management, and AD administration.

| Script | Purpose | Status |
|--------|---------|--------|
| `New-BulkADUser.ps1` | Bulk user creation from CSV | Production |
| `Get-StaleADAccount.ps1` | Find inactive accounts | Production |
| `Remove-StaleADComputer.ps1` | Clean up old computer accounts | Production |
| `Export-ADGroupMembers.ps1` | Report on group memberships | Production |
| `Set-ADUserPasswordExpiry.ps1` | Manage password policy | Production |

### System Administration
**Location:** `/PowerShell/SystemAdministration/`

Daily system administration tasks and configuration management.

| Script | Purpose | Status |
|--------|---------|--------|
| `Get-SystemInventory.ps1` | Collect hardware/software inventory | Production |
| `Install-StandardSoftware.ps1` | Automated software deployment | Production |
| `Set-SystemHardening.ps1` | Apply security baseline | Production |
| `Backup-SystemConfiguration.ps1` | Export system settings | Production |
| `Test-NetworkConnectivity.ps1` | Comprehensive network testing | Production |

### Security
**Location:** `/PowerShell/Security/`

Security auditing, log analysis, and compliance checking.

| Script | Purpose | Status |
|--------|---------|--------|
| `Get-SecurityAudit.ps1` | Comprehensive security audit | Production |
| `Export-EventLogSecurity.ps1` | Security log collection | Production |
| `Test-PasswordPolicy.ps1` | Validate password policies | Production |
| `Get-LocalAdminMembers.ps1` | Audit local admin accounts | Production |
| `Search-SuspiciousProcesses.ps1` | Hunt for anomalous processes | Production |

### Automation
**Location:** `/PowerShell/Automation/`

Task automation and orchestration scripts.

| Script | Purpose | Status |
|--------|---------|--------|
| `Deploy-GoldenImage.ps1` | Automated Windows deployment | Production |
| `Update-SystemPatches.ps1` | Scheduled patching automation | Production |
| `Invoke-DailyHealthCheck.ps1` | Automated system checks | Production |
| `Send-ReportEmail.ps1` | Automated reporting via email | Production |

### Monitoring
**Location:** `/PowerShell/Monitoring/`

System monitoring, alerting, and performance tracking.

| Script | Purpose | Status |
|--------|---------|--------|
| `Get-ServerHealth.ps1` | Server health dashboard | Production |
| `Monitor-DiskSpace.ps1` | Disk space monitoring with alerts | Production |
| `Get-ServiceStatus.ps1` | Service availability monitoring | Production |
| `Test-WebsiteAvailability.ps1` | Web service monitoring | Production |

---

## Python Scripts

### Log Analysis
**Location:** `/Python/LogAnalysis/`

Parse, analyze, and correlate log data from various sources.

| Script | Purpose | Status |
|--------|---------|--------|
| `parse_windows_evtx.py` | Windows Event Log parser | Production |
| `analyze_web_logs.py` | Web server log analysis | Production |
| `correlate_auth_events.py` | Authentication event correlation | Production |
| `detect_brute_force.py` | Brute force attack detection | Production |

### Automation
**Location:** `/Python/Automation/`

Cross-platform automation and API integration.

| Script | Purpose | Status |
|--------|---------|--------|
| `splunk_api_query.py` | Splunk REST API interaction | Production |
| `bulk_api_operations.py` | Automated API workflows | Production |
| `data_pipeline.py` | ETL pipeline automation | Development |

### Security
**Location:** `/Python/Security/`

Security tooling, scanning, and analysis.

| Script | Purpose | Status |
|--------|---------|--------|
| `port_scanner.py` | Network port scanning | Production |
| `hash_comparison.py` | File integrity checking | Production |
| `password_audit.py` | Password strength auditing | Production |
| `threat_intel_enrichment.py` | Threat intelligence lookups | Development |

### Reporting
**Location:** `/Python/Reporting/`

Automated report generation and data visualization.

| Script | Purpose | Status |
|--------|---------|--------|
| `generate_security_report.py` | Security metrics dashboard | Production |
| `export_to_excel.py` | Automated Excel report generation | Production |
| `create_pdf_report.py` | PDF report builder | Production |

---

## Bash Scripts

### System Administration
**Location:** `/Bash/SystemAdministration/`

Linux system administration and configuration.

| Script | Purpose | Status |
|--------|---------|--------|
| `system_hardening.sh` | Apply CIS baseline | Production |
| `backup_configs.sh` | Configuration backup automation | Production |
| `user_audit.sh` | User account auditing | Production |
| `service_manager.sh` | Service control and monitoring | Production |

### Security
**Location:** `/Bash/Security/`

Linux security operations and monitoring.

| Script | Purpose | Status |
|--------|---------|--------|
| `security_audit.sh` | Comprehensive security check | Production |
| `rootkit_check.sh` | Rootkit detection | Production |
| `suspicious_connections.sh` | Network connection monitoring | Production |
| `file_integrity_check.sh` | File system integrity | Production |

### Monitoring
**Location:** `/Bash/Monitoring/`

System and service monitoring for Linux.

| Script | Purpose | Status |
|--------|---------|--------|
| `server_health.sh` | Server health monitoring | Production |
| `disk_monitor.sh` | Disk usage alerts | Production |
| `log_watcher.sh` | Real-time log monitoring | Production |
| `process_monitor.sh` | Process tracking and alerting | Production |

### Automation
**Location:** `/Bash/Automation/`

Task automation and orchestration for Linux.

| Script | Purpose | Status |
|--------|---------|--------|
| `daily_backup.sh` | Automated backup operations | Production |
| `patch_manager.sh` | Automated patching | Production |
| `deployment_pipeline.sh` | Automated deployment | Development |

---

## Documentation Standards

All scripts follow these standards:

### Required Elements
- **Header comment block** with purpose, author, date, version
- **Parameter documentation** with examples
- **Error handling** for common failure modes
- **Logging** of significant actions
- **Exit codes** for automation workflows

### Example PowerShell Header
```powershell
<#
.SYNOPSIS
    Brief description of script purpose

.DESCRIPTION
    Detailed description of what the script does and how it works

.PARAMETER ParameterName
    Description of parameter

.EXAMPLE
    Script-Name.ps1 -ParameterName "Value"
    Description of what this example does

.NOTES
    Author: Your Name
    Date: 2025-10-25
    Version: 1.0
    
.LINK
    https://github.com/YOUR-USERNAME/Sovereign-Ops-Toolbox
#>
```

### Example Python Header
```python
"""
Script Name: script_name.py
Purpose: Brief description of what the script does
Author: Your Name
Date: 2025-10-25
Version: 1.0

Description:
    Detailed description of functionality

Usage:
    python script_name.py [arguments]

Requirements:
    - Python 3.8+
    - Required modules listed in requirements.txt
"""
```

### Example Bash Header
```bash
#!/bin/bash
################################################################################
# Script Name: script_name.sh
# Purpose: Brief description
# Author: Your Name
# Date: 2025-10-25
# Version: 1.0
#
# Description:
#   Detailed description
#
# Usage:
#   ./script_name.sh [arguments]
#
# Exit Codes:
#   0 - Success
#   1 - Error condition
################################################################################
```

---

## Testing

Scripts in production status have been tested in:
- Windows Server 2022 / Windows 10/11 (PowerShell)
- Ubuntu 24.04 LTS (Bash, Python)
- Homelab environment (all scripts)

---

## Usage Guidelines

### PowerShell Scripts
```powershell
# Download script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/YOUR-USERNAME/Sovereign-Ops-Toolbox/main/PowerShell/path/to/script.ps1" -OutFile "script.ps1"

# Check execution policy
Get-ExecutionPolicy

# Run script
.\script.ps1 -Parameter "Value"
```

### Python Scripts
```bash
# Clone repository
git clone https://github.com/YOUR-USERNAME/Sovereign-Ops-Toolbox.git
cd Sovereign-Ops-Toolbox/Python/path/to/script

# Install dependencies
pip install -r requirements.txt

# Run script
python script.py --argument value
```

### Bash Scripts
```bash
# Download script
wget https://raw.githubusercontent.com/YOUR-USERNAME/Sovereign-Ops-Toolbox/main/Bash/path/to/script.sh

# Make executable
chmod +x script.sh

# Run script
./script.sh [arguments]
```

---

## Contributing to This Toolbox

New scripts are added as they're developed and tested. Each script:
1. Solves a real operational problem
2. Has been tested in production or homelab environment
3. Follows documentation standards
4. Includes error handling and logging
5. Is committed with clear, descriptive commit messages

---

## Security Notice

**These are operational tools.** Some scripts have significant system impact:
- Account management scripts can modify AD
- Security scripts may trigger alerts
- Monitoring scripts collect sensitive data
- Automation scripts can make bulk changes

**Always:**
- Review scripts before running in production
- Test in lab environment first
- Have backups before making changes
- Use appropriate credentials and permissions
- Follow your organization's change management process

---

## Skills Demonstrated

✅ **PowerShell** - Active Directory, system administration, automation  
✅ **Python** - Log analysis, API integration, security tooling  
✅ **Bash** - Linux administration, security, monitoring  
✅ **Documentation** - Clear, professional script headers and READMEs  
✅ **Error Handling** - Robust error checking and logging  
✅ **Code Organization** - Logical structure, reusable functions  
✅ **Version Control** - Git workflow, meaningful commits  

---

## Stats

**Total Scripts:** 50+ (and growing)  
**Languages:** PowerShell, Python, Bash  
**Domains:** Active Directory, System Administration, Security, Automation, Monitoring  
**Status:** Active development, production-tested  

---

## Related Repositories

- [CrashCart](https://github.com/YOUR-USERNAME/CrashCart) - Technical portfolio with project documentation
- [Win11-Golden-Image](https://github.com/YOUR-USERNAME/Win11-Golden-Image) - Windows deployment automation

---

**Last Updated:** October 2025  
**License:** MIT  
**Status:** Active Development
