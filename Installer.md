# Visual Studio - Installer changes/setup
A generic power shell based installer has been written for organization's internal consumption. The installer has 4 basic functionalities as follows
* Do a basic check pre checks such as Admin privileges, any previous installation and license registration instances
* Run the main Visual Studio installation
* Register the user to fully license and authorize the installed Visual Studio
* Make an API call to audit server to register the latest installation (successful) made by the user.

## What to change ?
Once we have a new Visual Studio version available and we are done with on how to create [network installer](Create_network_installer.md). We need to do few basic changes in the installer for it to support latest Visual Studio.

### Change Visual Studio Version ($global:Version)
```
# Sample change
Line number: 10 
<< [ValidateNotNull()] [string]$global:Version="2017"
>> [ValidateNotNull()] [string]$global:Version="<new visual studio version>"
```

### Change Product Key and MPC Value ($global:ProductKey, $global:MPC)
```
# Sample change
Line 19-20 
<<------------------------------------------------
$global:ProductKey="AAAAA-BBBBB-CCCCC-DDDDD-EEEEE"
$global:MPC="ABCD"

>>------------------------------------------------
$global:ProductKey="FFFFF-GGGGG-HHHHH-IIIII-JJJJJ"
$global:MPC=<NEW_MPC_CODE>
```
### Change  NFS volume path value ($global:InstallerPath)
```
# Sample change
Line 29
<< $global:InstallerPath = "\\<NFS_PATH>\VS$Version\$Installer"
>> $global:InstallerPath = "\\ogrcifs.domain.com\VisualStudio\\VS$Version\$Installer"
```

### Change  Audit API Host (<AUDIT_API_HOST>:<PORT>)
```
# Sample change
Line 116
<< $Url = "http://<AUDIT_API_SERVER>:<PORT>/vs/ver/$Version/user/$Username/site/$Site/host/$Hostname/ip/$IP`?action=register"
>> $Url = "http://audit.domaind.com:3000/vs/ver/$Version/user/$Username/site/$Site/host/$Hostname/ip/$IP`?action=register"
```
