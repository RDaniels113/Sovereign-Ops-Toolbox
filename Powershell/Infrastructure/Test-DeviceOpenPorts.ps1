<#
.SYNOPSIS
Checks whether one or more devices expose common network ports.

.DESCRIPTION
Accepts IP addresses or FQDNs from manual input, a text file, or a CSV file.
Tests common administrative and network service ports using Test-NetConnection.

This is a security-focused script intended for basic exposure review.
It does not perform exploitation, vulnerability scanning, or intrusive testing.

.PARAMETER Target
One or more IP addresses or FQDNs entered manually.

.PARAMETER InputTxt
Path to a text file containing one target per line.

.PARAMETER InputCsv
Path to a CSV file containing a column named Target.

.PARAMETER Ports
One or more TCP ports to test. If not provided, the script checks common administrative and service ports.

.EXAMPLE
.\Test-DeviceExposureStatus.ps1 -Target "192.168.1.10"

.EXAMPLE
.\Test-DeviceExposureStatus.ps1 -InputTxt .\devices.txt

.EXAMPLE
.\Test-DeviceExposureStatus.ps1 -InputCsv .\devices.csv

.EXAMPLE
.\Test-DeviceExposureStatus.ps1 -Target "server01" -Ports 22,80,443,3389

.NOTES
CSV file format:
Target,Name,Location
192.168.1.10,Server01,Office
192.168.1.20,AP01,Warehouse
#>

param(
    # Manual input: one or more IP addresses or FQDNs
    [string[]]$Target,

    # Text file input: one target per line
    [string]$InputTxt,

    # CSV input: requires a column named "Target"
    [string]$InputCsv,

    # TCP ports to test
    [int[]]$Ports = @(21,22,23,25,53,80,135,139,389,443,445,3389,5985,5986)
)

# Create an empty array to hold every device target from all input methods.
$Devices = @()

# Add manually entered targets, if provided.
if ($Target) {
    $Devices += $Target
}

# Add targets from a text file, if provided.
if ($InputTxt) {
    $Devices += Get-Content -Path $InputTxt
}

# Add targets from a CSV file, if provided.
# The CSV must contain a column named "Target".
if ($InputCsv) {
    $Devices += (Import-Csv -Path $InputCsv).Target
}

# Clean up the final device list:
# - Remove blank entries
# - Trim extra spaces
# - Remove duplicates
$Devices = $Devices |
    Where-Object { $_ -and $_.Trim() -ne "" } |
    ForEach-Object { $_.Trim() } |
    Sort-Object -Unique

# If no valid devices were found, stop the script.
if (-not $Devices) {
    Write-Warning "No valid targets were provided. Use -Target, -InputTxt, or -InputCsv."
    return
}

# Create an empty collection for port check results.
$Results = foreach ($Device in $Devices) {

    foreach ($Port in $Ports) {

        # Test whether the TCP port is reachable.
        $ConnectionTest = Test-NetConnection -ComputerName $Device -Port $Port -WarningAction SilentlyContinue

        # Create a structured output object for each device/port check.
        [PSCustomObject]@{
            Target       = $Device
            Port         = $Port
            Status       = if ($ConnectionTest.TcpTestSucceeded) { "Open" } else { "Closed/Filtered" }
            RemoteIP     = $ConnectionTest.RemoteAddress
            TestedFrom   = $env:COMPUTERNAME
            Timestamp    = Get-Date
        }
    }
}

# Display results in a readable table.
$Results | Format-Table -AutoSize