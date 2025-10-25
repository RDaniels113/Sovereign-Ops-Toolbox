<#
.SYNOPSIS
    Creates Active Directory user accounts in bulk from CSV file

.DESCRIPTION
    Reads a CSV file containing user information and creates AD user accounts
    with proper attributes, group memberships, and organizational unit placement.
    Includes error handling, logging, and validation of required fields.

.PARAMETER CSVPath
    Path to CSV file containing user information
    Required columns: FirstName, LastName, SamAccountName, Email, Department, OU

.PARAMETER DomainController
    Domain controller to target for user creation (optional)

.PARAMETER WhatIf
    Runs the script in test mode without creating users

.EXAMPLE
    .\New-BulkADUser.ps1 -CSVPath "C:\Temp\NewUsers.csv"
    Creates users from the specified CSV file

.EXAMPLE
    .\New-BulkADUser.ps1 -CSVPath "C:\Temp\NewUsers.csv" -WhatIf
    Tests user creation without making changes

.NOTES
    Author: [Your Name]
    Date: 2025-10-25
    Version: 1.0
    Requires: Active Directory PowerShell module, appropriate AD permissions
    
.LINK
    https://github.com/YOUR-USERNAME/Sovereign-Ops-Toolbox
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_})]
    [string]$CSVPath,
    
    [Parameter(Mandatory=$false)]
    [string]$DomainController,
    
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf
)

# Import Active Directory module
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "[INFO] Active Directory module loaded successfully" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Failed to import Active Directory module: $_" -ForegroundColor Red
    exit 1
}

# Initialize logging
$LogPath = Join-Path $PSScriptRoot "New-BulkADUser_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Add-Content -Path $LogPath -Value $LogMessage
    
    switch ($Level) {
        "ERROR" { Write-Host $Message -ForegroundColor Red }
        "WARN"  { Write-Host $Message -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
        default { Write-Host $Message }
    }
}

Write-Log "Script started by $env:USERNAME on $env:COMPUTERNAME"
Write-Log "CSV Path: $CSVPath"

# Read and validate CSV
try {
    $Users = Import-Csv -Path $CSVPath -ErrorAction Stop
    Write-Log "Successfully imported $($Users.Count) users from CSV" "SUCCESS"
}
catch {
    Write-Log "Failed to read CSV file: $_" "ERROR"
    exit 1
}

# Validate required columns
$RequiredColumns = @('FirstName', 'LastName', 'SamAccountName', 'Email', 'Department', 'OU')
$CSVColumns = ($Users | Select-Object -First 1).PSObject.Properties.Name

foreach ($Column in $RequiredColumns) {
    if ($Column -notin $CSVColumns) {
        Write-Log "Missing required column: $Column" "ERROR"
        exit 1
    }
}

Write-Log "CSV validation complete. All required columns present." "SUCCESS"

# Process each user
$SuccessCount = 0
$FailCount = 0
$SkipCount = 0

foreach ($User in $Users) {
    $SamAccountName = $User.SamAccountName
    
    Write-Log "Processing user: $SamAccountName"
    
    # Check if user already exists
    try {
        $ExistingUser = Get-ADUser -Identity $SamAccountName -ErrorAction SilentlyContinue
        if ($ExistingUser) {
            Write-Log "User $SamAccountName already exists. Skipping." "WARN"
            $SkipCount++
            continue
        }
    }
    catch {
        # User doesn't exist, continue with creation
    }
    
    # Validate OU exists
    try {
        $OUExists = Get-ADOrganizationalUnit -Identity $User.OU -ErrorAction Stop
    }
    catch {
        Write-Log "OU does not exist: $($User.OU). Skipping user $SamAccountName" "ERROR"
        $FailCount++
        continue
    }
    
    # Generate initial password
    $InitialPassword = -join ((65..90) + (97..122) + (48..57) + (33, 35, 36, 37, 38, 42, 43) | Get-Random -Count 16 | ForEach-Object {[char]$_})
    $SecurePassword = ConvertTo-SecureString $InitialPassword -AsPlainText -Force
    
    # Build user parameters
    $UserParams = @{
        Name = "$($User.FirstName) $($User.LastName)"
        GivenName = $User.FirstName
        Surname = $User.LastName
        SamAccountName = $User.SamAccountName
        UserPrincipalName = "$($User.SamAccountName)@$((Get-ADDomain).DNSRoot)"
        EmailAddress = $User.Email
        Department = $User.Department
        Path = $User.OU
        AccountPassword = $SecurePassword
        Enabled = $true
        ChangePasswordAtLogon = $true
    }
    
    # Create user
    if ($WhatIf) {
        Write-Log "WHATIF: Would create user $SamAccountName" "INFO"
        $SuccessCount++
    }
    else {
        try {
            New-ADUser @UserParams -ErrorAction Stop
            Write-Log "Successfully created user: $SamAccountName" "SUCCESS"
            Write-Log "Initial password for $SamAccountName : $InitialPassword" "INFO"
            $SuccessCount++
        }
        catch {
            Write-Log "Failed to create user $SamAccountName : $_" "ERROR"
            $FailCount++
        }
    }
}

# Summary
Write-Log "==================== SUMMARY ====================" "INFO"
Write-Log "Total users processed: $($Users.Count)" "INFO"
Write-Log "Successfully created: $SuccessCount" "SUCCESS"
Write-Log "Skipped (already exist): $SkipCount" "WARN"
Write-Log "Failed: $FailCount" "ERROR"
Write-Log "Log file: $LogPath" "INFO"
Write-Log "Script completed" "INFO"

# Return exit code
if ($FailCount -gt 0) {
    exit 1
} else {
    exit 0
}
