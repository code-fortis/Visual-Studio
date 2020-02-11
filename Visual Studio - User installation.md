# Visual Studio - User Installation

## Introduction
This page documents the process to install Visual Studio via the powershell script [Template]() provided.

## Platform compatibility and system requirements
### Operting systems
* Windows 8
* Windows 10
* Windows Server 2008(R2)/2012/2016

### Supported Architecture
* 64 bit (x64)

### Hardware requirement
* 1.6 GHz or faster processor
* 1 GB of RAM (1.5GB if running on a virtual machine)
* Minimum 16GB of Hard disk space

## Uninstall existing Visual Studio
Before we begin installing the enterprise version and enable official license, make sure any trial version or RC version are uninstalled
__Method 1:__ Use the unistaller
Generally, the standard uninstall procedure should work as expected, so definitely try this before moving on to method 2/3.

__Method 2:__ Uninstall any existing Visual Studio (!!Sure shot way!!)
Run the following program with administrative privileges: 
```
C:\Program Files (x86)\Microsoft Visual Studio\Installer\resources\app\layout\InstallCleanup.exe
```

__Method 3:__ The hard way, Deleting reistry entries
* Remove the registry key containing the license information: ***HKEY_CLASSES_ROOT\Licenses\AAAA-BBBB-CCCC-DDDD-EEEE***
> If you can't find the key, use sysinternals ProcessMonitor to check the registry access of VS2017 to locate the correct key which is always in HKEY_CLASSES_ROOT\Licenses
* Delete the following directories: 
```
C:\ProgramData\Microsoft\VisualStudio\<version>
%localappdata%\Microsoft\VisualStudio\<version>
%appdata%\Microsoft\VisualStudio\<version>
```
* Run the Registry Editor (regedit) and delete the following entries: 
```
HKLM\SOFTWARE\Microsoft\VisualStudio
HKLM\SOFTWARE\WoW6432Node\Microsoft\VisualStudio\
HKCU\SOFTWARE\Microsoft\VisualStudio\
```

## Gaining access to the installer
* Make a working version of the installer using the [powershell template] () and copy it to your local desktop from the source path (based on organization tools repository area)
* If you have any pending Windows updates, restart your machine before running the installer.
* Open a Windows PowerShell Command Prompt with Administrator privileges and copy the installer script.
```
xcopy \\<NFS_PATH>\vs_installer_2017.ps1 C:\Users\<USERNAME>\Desktop 
```
* __Set-ExecutionPolicy unrestricted__ 
```
PS H:\> Set-ExecutionPolicy unrestricted
Execution Policy Change
The execution policy helps protect you from scripts that you do not trust. Changing the execution policy might expose you to the security risks described in the about_Execution_Policies help topic at https:/go.microsoft.com/fwlink/?LinkID=135170. Do you want to change
the execution policy?
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "N"): A
```
* Run __C:\Users\<USERNAME>\Desktop\vs_installer_2017.ps1__
> Please note, your system may possibly be restarted at the end of the installation based on the installation status and VS initialization status.
