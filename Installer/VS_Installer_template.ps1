#-----------------------------------------------------------------------------------------------------
# Script: Microsoft Visual Studio Installer
# Author: Akshay Agrawal
# Keywords: Visual Studio Installer
# Version: 1.0.0
# Supports: 2017 and above
# Comments:
#-----------------------------------------------------------------------------------------------------
param(
    [ValidateNotNull()] [string]$global:Version="2017"
    )

# Global variables
$global:Username = $env:USERNAME
$global:Hostname = $env:COMPUTERNAME
$global:Os = $env:OS
$global:InstallPath="C:\msvsn$Version"
$global:Installer="vs_professional.exe"
$global:ProductKey="AAAA-BBBB-CCCC-DDDD-EEEE"
$global:MPC="ABCD"
$global:ENV_DATA_TXT="C:\Windows\Temp\env_data.txt"
$global:Site=""
$global:ToInstall = $true
$global:ToLicense = $true
$global:ToRestart = $false
$global:IPAddress = (Test-Connection -ComputerName (hostname) -count 1 | select IPV4Address).IPV4Address
$global:IP= $global:IPAddress.IPAddressToString
$global:InstallerPath = "\\<NFS_PATH>\VS$Version\$Installer"

function welcomeMessage {
    $message=@"

Welcome to Microsoft Visual Studio $global:Version - internal installer

This script automates the process for installing VS $global:Version and its dependencies.

To run as an administrator: 
    1. Exit this window
    2. Right-click the installer script and select 'Run as administrator'.

Please ensure you do not have any Windows updates pending for restart. If yes, please 
exit and reboot your machine and re-run the script.

****************************************************************
***  Please have all work saved, exit any other applications ***
***  and be prepared for a reboot!                           ***
****************************************************************
"@
    Write-Host -Object "$message`n"
    Write-Host -Object "Username: $global:Username"
    Write-Host -Object "Hostname: $global:Hostname"
    Write-Host -Object "OS Version: $global:Os"
    #! Todo: Need to add a prompt for the user to continue or not
}

function errorMessage {
    param([string]$Message)
    $supportMessage=@'
In case of the above error is not clear or not provided, 
    1. Please contact support team for further assistance. 
    2. Please file an SR against the 'Infrastructure' problem area.
'@
    Write-Host -Object "`n****************************************************************"
    Write-Host -Object "Unable to complete the installation due to the following error:`n"
    Write-Host -Object $Message -ForegroundColor Red
    Write-Host -Object "`n$supportMessage"
    Write-Host -Object "****************************************************************"
    exit 1;
}
# Check Admin rights
function isAdmin {
    Write-Host -Object "Checking for administrative rights: " -NoNewline
    $root_privilege = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
    if (!$root_privilege){
        Write-Host -Object "NOPE" -ForegroundColor Red
        errorMessage -Message "Installation requires the program to be run with admin privileges."
    } else {
        Write-Host -Object "GRANTED" -ForegroundColor Green
    }
}

# Check for installer access
function checkInstaller {
    param([string]$Installer)
    Write-Host -Object "Installer Access: " -NoNewline
    if(![System.IO.File]::Exists($Installer)) {
        Write-Host -Object "DENIED" -ForegroundColor Red
        errorMessage -Message "User $Username does not have access to the installer."
    }
    Write-Host -Object "GRANTED" -ForegroundColor Green
}

function runPreCheck {
    Write-Host -Object ""
    # Check if installation directory already exists or not
    if(Test-Path $global:InstallPath) {
        Write-Host -Object "[INFO] Destination $global:InstallPath already exist" -ForegroundColor Yellow
    }

    # Check if install.log is present or not
    Write-Host -Object "Visual Studio: " -NoNewline
    if (Test-Path $global:InstallPath\install.log) {
        Write-Host -Object "Installed instance already found" -ForegroundColor Green
        $global:ToInstall = $false
    } else { Write-Host -Object "PENDING" }

    # Check if license is applied or not
    Write-Host -Object "License registration: " -NoNewline
    if (Test-Path $global:InstallPath\license.log) {
        Write-Host -Object "DONE" -ForegroundColor Green
        $global:ToLicense = $false
    } else { Write-Host -Object "PENDING" }
}

function ToAudit {
    $Url = "http://<AUDIT_API_SERVER>:<PORT>/vs/ver/$Version/user/$Username/site/$Site/host/$Hostname/ip/$IP`?action=register"
    $result = Invoke-RestMethod -Uri $Url -Method Post;
}

function RunInstallation {
    Write-Host -Object "`nRunning Installation (this may take some time, please be patient) ..."
    $installerArgs = @(("--wait --noWeb"))
    $result = Start-Process -NoNewWindow -PassThru -Wait -FilePath "$global:InstallerPath" -ArgumentList ($InstallerArgs -join " ")

    Write-Host -Object "Installation: " -NoNewline
    if($result.ExitCode -eq 0) {
        Write-Host -Object "Success" -ForegroundColor Green
        Set-Content -Path "$global:InstallPath\install.log" -Value "True"
        #return $true
    } elseif ($result.ExitCode -eq 3010) {
        Write-Host -Object "Success [RESTART REQUIRED]" -ForegroundColor Green
        $global:ToRestart=$true
        return $true
    } elseif ($result.ExitCode -eq 1) {
        Write-Host -Object "Failed [Critical Error]" -ForegroundColor Red
        errorMessage -Message "Nature of failure unknown"
    } else {
        Write-Host -Object "Failed [Unkown Error]" -ForegroundColor Red
        errorMessage -Message "Nature of failure unknown"
    }
}

function ApplyLicense {
    Write-Host -Object "`nPreparing for license activation"
    $KeyExec = "$global:InstallPath\Common7\IDE\StorePID.exe"
    $InstallerArgs = @(("$global:ProductKey $global:MPC"))

    Write-Host -Object "Running $KeyExec AAAAA-BBBBB-CCCCC-DDDDD-EEEEE MPC"
    $result = Start-Process -NoNewWindow -PassThru -Wait -FilePath "$KeyExec" -ArgumentList ($InstallerArgs -join " ")

    if($result.ExitCode -eq 0) {
        Write-Host -Object "Success" -ForegroundColor Green
        Set-Content -Path "$global:InstallPath\license.log" -Value "True"
        
        # Send the installation details to Internal audit server
        ToAudit
        #return $true
    } elseif($result.ExitCode -eq 1) {
        Write-Host -Object "Failed [PID_ACTION_NOTINSTALLED]" -ForegroundColor Red
        errorMessage -Message "License activation failed, PID_ACTION_NOTINSTALLED - VS installation no found"
    } elseif($result.ExitCode -eq 2) {
        Write-Host -Object "Failed [PID_ACTION_INVALID]" -ForegroundColor Red
        errorMessage -Message "License activation failed, PID_ACTION_INVALID - Invalid product key given"
    } elseif($result.ExitCode -eq 3) {
        Write-Host -Object "Failed [PID_ACTION_EXPIRED]" -ForegroundColor Red
        errorMessage -Message "License activation failed, PID_ACTION_EXPIRED - Product key expired"
    } elseif($result.ExitCode -eq 4) {
        Write-Host -Object "Failed [PID_ACTION_INUSE]" -ForegroundColor Red
        errorMessage -Message "License activation failed, PID_ACTION_INUSE - Product key already in use"
    } elseif($result.ExitCode -eq 5) {
        Write-Host -Object "Failed [PID_ACTION_FAILURE]" -ForegroundColor Red
        errorMessage -Message "License activation failed, PID_ACTION_FAILURE - Could not apply product key"
    } elseif($result.ExitCode -eq 6) {
        Write-Host -Object "Failed [PID_ACTION_NOUPGRADE]" -ForegroundColor Red
        errorMessage -Message "License activation failed, PID_ACTION_NOUPGRADE: Cannot apply new key to already registered product"
    }
}

#*******************
# START OF PROGRAM
#*******************

# Print the welcome message
welcomeMessage

# Check if the script is running in amdinistrator mode
isAdmin

# Check if access to installer for current user is granted or not
checkInstaller -Installer $global:InstallerPath

# Run precheck before attempting to run installation
runPreCheck

# Run Visual Studio Installation
if($global:ToInstall) { RunInstallation }

# Run License application
if($global:ToLicense) { ApplyLicense }

$finalMessage=@"
********************************
***         SUMMARY          ***
***                          ***
***  Installation : DONE     ***
***  License Reg  : DONE     ***
***                          ***
********************************
"@
Write-Host -Object "`n$finalMessage`n"

# Restart the system if required
if($global:ToRestart) {
    Write-Host -Object "System will restart in .... 10 Seconds (Please save your work)"
    Start-Sleep -Seconds 10; Restart-Computer -Force 
}
