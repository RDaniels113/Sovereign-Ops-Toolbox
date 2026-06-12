<#
.SYNOPSIS
Checks one or more devices for exposed common network services.

.DESCRIPTION
Accepts IP addresses or FQDNs from manual input, a text file, or a CSV file.

The script tests common administrative and service ports, then reports only open ports
as security findings. Each open port is mapped to a service name, severity, finding,
and recommendation.

This is a basic exposure review script. It does not exploit, brute force, or perform
intrusive vulnerability scanning.

.PARAMETER Target
One or more IP addresses or FQDNs entered manually.

.PARAMETER InputTxt
Path to a text file containing one target per line.

.PARAMETER InputCsv
Path to a CSV file containing a column named Target.

.EXAMPLE
.\Test-DeviceExposureStatus.ps1 -Target "192.168.1.10"

.EXAMPLE
.\Test-DeviceExposureStatus.ps1 -InputTxt .\devices.txt

.EXAMPLE
.\Test-DeviceExposureStatus.ps1 -InputCsv .\devices.csv

.NOTES
TXT format:
192.168.1.10
server01.domain.local
ap01.domain.local

CSV format:
Target,Name,Location
192.168.1.10,Server01,Office
ap01.domain.local,AP01,Warehouse
#>

param(
    # Manual input: one or more IP addresses or FQDNs.
    [string[]]$Target,

    # Text file input: one target per line.
    [string]$InputTxt,

    # CSV input: requires a column named "Target".
    [string]$InputCsv
)

# -------------------------------------------------------------------------
# 1. Define security port profiles.
# -------------------------------------------------------------------------
# This is the security logic of the script.
# Each profile maps a TCP port to a service, severity, finding, and recommendation.
# The script will loop through these profiles and test each port against each target.

$PortProfiles = @(
    @{
        Port           = 21
        Service        = "FTP"
        Severity       = "Medium"
        Finding        = "FTP is exposed. FTP may transmit credentials in cleartext."
        Recommendation = "Disable FTP where possible or replace it with SFTP/FTPS."
    },
    @{
        Port           = 22
        Service        = "SSH"
        Severity       = "Low"
        Finding        = "SSH is exposed."
        Recommendation = "Verify access controls, restrict source IPs, and require key-based authentication where possible."
    },
    @{
        Port           = 23
        Service        = "Telnet"
        Severity       = "High"
        Finding        = "Telnet is exposed. Telnet transmits data in cleartext."
        Recommendation = "Disable Telnet and replace it with SSH."
    },
    @{
        Port           = 25
        Service        = "SMTP"
        Severity       = "Medium"
        Finding        = "SMTP is exposed."
        Recommendation = "Verify this device is intended to send or receive mail and restrict relay behavior."
    },
    @{
        Port           = 53
        Service        = "DNS"
        Severity       = "Medium"
        Finding        = "DNS is exposed."
        Recommendation = "Verify DNS exposure is intended and restrict recursion where appropriate."
    },
    @{
        Port           = 80
        Service        = "HTTP"
        Severity       = "Medium"
        Finding        = "HTTP is exposed. Web traffic may be unencrypted."
        Recommendation = "Redirect HTTP to HTTPS or disable HTTP if not required."
    },
    @{
        Port           = 135
        Service        = "RPC"
        Severity       = "Medium"
        Finding        = "RPC is exposed."
        Recommendation = "Restrict RPC exposure to trusted internal networks only."
    },
    @{
        Port           = 139
        Service        = "NetBIOS"
        Severity       = "Medium"
        Finding        = "NetBIOS is exposed."
        Recommendation = "Disable NetBIOS where not required or restrict it to trusted internal networks."
    },
    @{
        Port           = 389
        Service        = "LDAP"
        Severity       = "Medium"
        Finding        = "LDAP is exposed."
        Recommendation = "Verify LDAP exposure is required and prefer LDAPS where possible."
    },
    @{
        Port           = 443
        Service        = "HTTPS"
        Severity       = "Low"
        Finding        = "HTTPS is exposed."
        Recommendation = "Verify certificate validity and restrict access to management interfaces where possible."
    },
    @{
        Port           = 445
        Service        = "SMB"
        Severity       = "High"
        Finding        = "SMB is exposed."
        Recommendation = "Restrict SMB to trusted internal networks and verify SMB signing requirements."
    },
    @{
        Port           = 3389
        Service        = "RDP"
        Severity       = "High"
        Finding        = "RDP is exposed."
        Recommendation = "Restrict RDP behind VPN, require MFA, and limit access by source IP."
    },
    @{
        Port           = 5985
        Service        = "WinRM HTTP"
        Severity       = "Medium"
        Finding        = "WinRM over HTTP is exposed."
        Recommendation = "Restrict WinRM to trusted admin networks and prefer HTTPS where possible."
    },
    @{
        Port           = 5986
        Service        = "WinRM HTTPS"
        Severity       = "Low"
        Finding        = "WinRM over HTTPS is exposed."
        Recommendation = "Verify certificate configuration and restrict access to trusted admin networks."
    }
)

# -------------------------------------------------------------------------
# 2. Collect device targets from all supported input methods.
# -------------------------------------------------------------------------
# Targets may come from:
# - Manual input through -Target
# - A text file through -InputTxt
# - A CSV file through -InputCsv

$Devices = @()

# Add manually entered targets.
if ($Target) {
    $Devices += $Target
}

# Add targets from a text file.
if ($InputTxt) {
    $Devices += Get-Content -Path $InputTxt
}

# Add targets from a CSV file.
# The CSV must include a column named "Target".
if ($InputCsv) {
    $Devices += (Import-Csv -Path $InputCsv).Target
}

# -------------------------------------------------------------------------
# 3. Clean and deduplicate the target list.
# -------------------------------------------------------------------------
# This removes blank lines, trims spaces, and prevents duplicate scans.

$Devices = $Devices |
    Where-Object { $_ -and $_.Trim() -ne "" } |
    ForEach-Object { $_.Trim() } |
    Sort-Object -Unique

# Stop if no valid devices were found.
if (-not $Devices) {
    Write-Warning "No valid targets were provided. Use -Target, -InputTxt, or -InputCsv."
    return
}

# -------------------------------------------------------------------------
# 4. Test each device against each security port profile.
# -------------------------------------------------------------------------
# Outer loop: each device
# Inner loop: each port profile
#
# The script only creates output when a port is open.
# Closed ports are not reported because this is a findings-based security script.

$Results = foreach ($Device in $Devices) {

    foreach ($PortProfile in $PortProfiles) {

        # Test the current device against the current port.
        $ConnectionTest = Test-NetConnection `
            -ComputerName $Device `
            -Port $PortProfile.Port `
            -WarningAction SilentlyContinue

        # Only report open ports as findings.
        if ($ConnectionTest.TcpTestSucceeded) {

            [PSCustomObject]@{
                Target         = $Device
                RemoteAddress  = $ConnectionTest.RemoteAddress
                Port           = $PortProfile.Port
                Service        = $PortProfile.Service
                Severity       = $PortProfile.Severity
                Finding        = $PortProfile.Finding
                Recommendation = $PortProfile.Recommendation
                TestedFrom     = $env:COMPUTERNAME
                Timestamp      = Get-Date
            }
        }
    }
}

# -------------------------------------------------------------------------
# 5. Display results.
# -------------------------------------------------------------------------
# If findings exist, display them in a table.
# If no findings exist, report that no exposed services were found.

if ($Results) {
    $Results | Format-Table Target, RemoteAddress, Port, Service, Severity, Finding -AutoSize
}
else {
    Write-Host "No exposed services were found on the tested targets."
}