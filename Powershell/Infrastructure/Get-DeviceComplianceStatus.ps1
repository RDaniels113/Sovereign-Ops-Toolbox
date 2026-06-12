<#
.SYNOPSIS
    Reports Intune managed device compliance status using Microsoft Graph.

.DESCRIPTION
    Connects to Microsoft Graph and exports managed device compliance data.
    Useful for endpoint administration, Intune reporting, and M365 operational checks.

.REQUIREMENTS
    Install-Module Microsoft.Graph.DeviceManagement
    Install-Module Microsoft.Graph.Authentication

.PERMISSIONS
    DeviceManagementManagedDevices.Read.All
#>

[CmdletBinding()]
param(
    [string]$OutputPath = ".\DeviceComplianceStatus.csv",
    [switch]$ExportCsv
)

$RequiredModules = @(
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.DeviceManagement"
)

foreach ($Module in $RequiredModules) {
    if (-not (Get-Module -ListAvailable -Name $Module)) {
        Write-Error "Missing required module: $Module. Install it with: Install-Module $Module -Scope CurrentUser"
        exit 1
    }
}

Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.DeviceManagement

try {
    Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan

    Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All" -NoWelcome

    Write-Host "Retrieving Intune managed devices..." -ForegroundColor Cyan

    $Devices = Get-MgDeviceManagementManagedDevice -All

    if (-not $Devices) {
        Write-Warning "No managed devices were returned. Check Intune licensing, permissions, and tenant access."
        return
    }

    $Report = $Devices | Select-Object `
        DeviceName,
        UserPrincipalName,
        OperatingSystem,
        OsVersion,
        ComplianceState,
        ManagementAgent,
        EnrollmentType,
        LastSyncDateTime,
        Manufacturer,
        Model,
        SerialNumber,
        AzureAdDeviceId,
        Id

    $Report | Sort-Object ComplianceState, DeviceName | Format-Table -AutoSize

    if ($ExportCsv) {
        $Report | Export-Csv -Path $OutputPath -NoTypeInformation
        Write-Host "Report exported to: $OutputPath" -ForegroundColor Green
    }

    $Summary = $Report | Group-Object ComplianceState | Select-Object Name, Count

    Write-Host "`nCompliance Summary:" -ForegroundColor Cyan
    $Summary | Format-Table -AutoSize
}
catch {
    Write-Error "Failed to retrieve device compliance status. $($_.Exception.Message)"
}
finally {
    Disconnect-MgGraph | Out-Null
}
