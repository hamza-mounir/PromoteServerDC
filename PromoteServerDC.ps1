# This script must be run as an administrator

<#
.SYNOPSIS
This script promotes a server to a domain controller.

.DESCRIPTION
This script uses several parameters to promote a server to a domain controller. Some parameters are mandatory while others are optional. The password parameter refers to the Directory Services Restore Mode (DSRM) password.

.PARAMETER help
Displays the help message.

.PARAMETER mode
The domain and forest mode. You can enter either the mode name or its corresponding number. This parameter is mandatory.

.PARAMETER domain
Your domain name. This parameter is mandatory.

.PARAMETER databasepath
The path to your database. The default is 'C:\\Windows\\NTDS'.

.PARAMETER sysvolpath
The path to your SYSVOL. The default is 'C:\\Windows\\SYSVOL'.

.PARAMETER netbiosname
The NetBIOS name of the domain. If not provided, the first part of your domain name will be used.

.EXAMPLE
.\PromoteServerDC.ps1 -mode 7 -domain company.local

.\PromoteServerDC.ps1 -mode <DomainAndForestMode> -domain <YourDomain> -databasepath <DatabasePath> -sysvolpath <SysvolPath> -netbiosname <NetBIOSName>

Replace <DomainAndForestMode>, <YourDomain>, <DatabasePath>, <SysvolPath>, and <NetBIOSName> with your actual values.

.AUTHOR
Hamza MOUNIR
LinkedIn: https://www.linkedin.com/in/hamzamounir/
#>

# Define parameters for the script
param(
    [switch]$help,
    [Parameter(Mandatory=$false, HelpMessage="Please enter the domain and forest mode. Example: -mode 7 or -mode WinThreshold")]
    [string]$mode,
    [Parameter(Mandatory=$false, HelpMessage="Please enter the domain name. Example: -domain company.local")]
    [string]$domain,
    [Parameter(Mandatory=$false, HelpMessage="Please enter the database path. Example: -databasepath 'C:\\Windows\\NTDS'")]
    [string]$databasepath = 'C:\\Windows\\NTDS',
    [Parameter(Mandatory=$false, HelpMessage="Please enter the SYSVOL path. Example: -sysvolpath 'C:\\Windows\\SYSVOL'")]
    [string]$sysvolpath = 'C:\\Windows\\SYSVOL',
    [Parameter(Mandatory=$false, HelpMessage="Please enter the NetBIOS name of the domain. Example: -netbiosname 'YourNetBIOSName'")]
    [string]$netbiosname
)

# If help switch is used, display the help message
if ($help) {
    Write-Output @"
Usage:
.\PromoteServerDC.ps1 -mode <DomainAndForestMode> -domain <YourDomain> -databasepath <DatabasePath> -sysvolpath <SysvolPath> -netbiosname <NetBIOSName>

Mandatory Parameters:
- <DomainAndForestMode> : Replace with the domain and forest mode. You can enter either the mode name or its corresponding number. Example: 7 or WinThreshold
- <YourDomain> : Replace with your domain name. Example: company.local

Optional Parameters:
- <DatabasePath> : Replace with your database path. Default is 'C:\\Windows\\NTDS'.
- <SysvolPath> : Replace with your SYSVOL path. Default is 'C:\\Windows\\SYSVOL'.
- <NetBIOSName> : Replace with your NetBIOS name. If not provided, the first part of your domain name will be used.

Examples:
.\PromoteServerDC.ps1 -mode 7 -domain company.local
.\PromoteServerDC.ps1 -mode 7 -domain company.local -databasepath 'C:\\Windows\\NTDS' -sysvolpath 'C:\\Windows\\SYSVOL' -netbiosname 'YourNetBIOSName'
.\PromoteServerDC.ps1 -mode WinThreshold -domain company.local -databasepath 'D:\\NTDS' -sysvolpath 'D:\\SYSVOL' -netbiosname 'AnotherNetBIOSName'
"@
    return
}

if (-not $mode -or -not $domain) {
    Write-Output "All required parameters are required. Use -help for more information."
    return
}

# Load the necessary assembly
Add-Type -AssemblyName System.Windows.Forms

# Define the modes
$modes = @{
    'WinThreshold' = 7
    'Win2012R2' = 6
    'Win2012' = 5
    'Win2008R2' = 4
}

# Function to check if the provided domain and forest mode is valid
function IsValidDomainForestMode($DomainAndForestModes) {
    if ($DomainAndForestModes -match '^\d+$') {
        $DomainAndForestModes = $modes.GetEnumerator() | Where-Object { $_.Value -eq [int]$DomainAndForestModes } | Select-Object -ExpandProperty Key
    }
    if ($null -eq $DomainAndForestModes -or -not $modes.ContainsKey($DomainAndForestModes)) {
        Write-Output "Invalid domain and forest mode. Use -help for more information."
        return $false
    }
    return $true
}

# Function to check if the provided domain is valid
function IsValidDomain($domain) {
    return $domain -match "^.+\..+$"
}

# Function to check if the provided path is valid
function IsValidPath($path) {
    return $path -match "^[a-zA-Z]:\\"
}

# Function to check if the provided NetBIOS name is valid
function IsValidNetbiosName($netbiosname) {
    return $netbiosname -match "^[a-zA-Z0-9-]+$"
}

# Check if the provided database path is valid
if (!(IsValidPath $databasepath)) {
    Write-Output "Invalid database path or the path does not exist. Please enter a valid path. Use -help for more information."
    return
}

# Check if the provided SYSVOL path is valid
if (!(IsValidPath $sysvolpath)) {
    Write-Output "Invalid SYSVOL path or the path does not exist. Please enter a valid path. Use -help for more information."
    return
}

# Check if the provided NetBIOS name is valid
if ($netbiosname -and !(IsValidNetbiosName $netbiosname)) {
    Write-Output "Invalid NetBIOS name. Please enter a valid name. Use -help for more information."
    return
}

# Check if the provided mode is valid
if (-not $mode -or -not $modes.ContainsKey($mode) -and -not $modes.ContainsValue([int]$mode)) {
    Write-Output "Invalid or missing mode. Use -help for more information."
    return
}

# Check if the provided domain and forest mode is valid
if (-not (IsValidDomainForestMode $mode)) {
    return
}

# Check if the provided domain is valid
if (!(IsValidDomain $domain)) {
    Write-Output "Invalid domain. Please enter a valid domain, for example 'mycompany.local'. Use -help for more information."
    return
}

# If no NetBIOS name is provided, use the first part of the domain name
if (-not $netbiosname) {
    $netbiosname = $domain.Split(".")[0]
}

# Ask for the DSRM password
$dsrm = Read-Host "Enter your DSRM password (must be at least 10 characters long, contain uppercase and lowercase letters, numbers, and special characters). Use -help for more information." -AsSecureString

# Start the server promotion
Write-Output "`nContinue with the promotion of the server !"

# Load the necessary module
Import-Module ServerManager

Write-Output "`nInstall Windows features now !"

# Install the necessary Windows features
$Features = @("RSAT-AD-Tools","RSAT-AD-AdminCenter","AD-Domain-Services","DNS")

# Install each feature
Foreach($Feature in $Features){

   if(((Get-WindowsFeature -Name $Feature).InstallState)-eq"Available"){

     Write-Output "`nFeature $Feature will be installed now !"

     Try{

        Install-WindowsFeature -Name $Feature -IncludeManagementTools -IncludeAllSubFeature

        Write-Output "$Feature : Installation is a success !"

     }Catch{

        Write-Output "$Feature : Error during installation !"
     }
   }  
} 

# Create the databasepath and sysvolpath directories if they do not exist
if (!(Test-Path -Path $databasepath)) {
    New-Item -ItemType Directory -Path $databasepath
}

if (!(Test-Path -Path $sysvolpath)) {
    New-Item -ItemType Directory -Path $sysvolpath
}

# Promote the server to a domain controller
Install-ADDSForest `
    -SafeModeAdministratorPassword $dsrm `
    -CreateDnsDelegation:$false `
    -DatabasePath $databasepath `
    -DomainMode $mode `
    -DomainName $domain `
    -DomainNetbiosName $netbiosname `
    -ForestMode $mode `
    -InstallDns:$true `
    -LogPath $databasepath `
    -NoRebootOnCompletion:$true `
    -SysvolPath $sysvolpath `
    -Force:$true

Write-Host "Server promoted successfully."

# Load the necessary module
Import-Module ADDSDeployment

# Remove the DSRM password variable
Remove-Variable -Name 'dsrm' 

# Countdown before restart
for ($i = 5; $i -gt 0; $i--) {
    Write-Host "Restarting computer in $i sec"
    Start-Sleep -Seconds 1
}
Write-Host "Restarting computer now..."

# Restart the computer
Restart-Computer -Force -Verbose
