<#
.SYNOPSIS
Tests whether one or more devices are online.

.DESCRIPTION
Accepts IP addresses or FQDNs from manual input, a text file, or a CSV file.
Each target is tested with Test-Connection to determine whether it responds to ping.

This is the example-level version of the script.
It is designed to show the basic logic clearly before adding deeper infrastructure checks.

.PARAMETER Target
One or more IP addresses or FQDNs entered manually.

.PARAMETER InputTxt
Path to a text file containing one target per line.

.PARAMETER InputCsv
Path to a CSV file containing a column named Target.

.EXAMPLE
.\Test-DeviceOnlineStatus.ps1 -Target "8.8.8.8","google.com"

.EXAMPLE
.\Test-DeviceOnlineStatus.ps1 -InputTxt .\devices.txt

.EXAMPLE
.\Test-DeviceOnlineStatus.ps1 -InputCsv .\devices.csv

.NOTES
Text file format:
8.8.8.8
google.com
AP-01

CSV file format:
Target,Name,Location
8.8.8.8,Google DNS,External
google.com,Google,External
10.10.10.25,AP-01,Warehouse
#>

param(
    # Manual input: one or more IP addresses or FQDNs
    [string[]]$Target,

    # Text file input: one target per line
    [string]$InputTxt,

    # CSV input: requires a column named "Target"
    [string]$InputCsv
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

# Test each device and create a structured result object.
$Results = foreach ($Device in $Devices) {

    # Test-Connection checks whether the device responds to ping.
    # -Count 2 sends two echo requests.
    # -Quiet returns True or False instead of detailed ping output.
    # -ErrorAction SilentlyContinue prevents unreachable targets from throwing noisy errors.
    $IsOnline = Test-Connection -ComputerName $Device -Count 2 -Quiet -ErrorAction SilentlyContinue

    # Create a clean output object for each device.
    [PSCustomObject]@{
        Target    = $Device
        Status    = if ($IsOnline) { "Online" } else { "Offline" }
        Timestamp = Get-Date
    }
}

# Display results in a readable table.
$Results | Format-Table -AutoSize