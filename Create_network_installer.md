# Visual Studio - Repository and network Installer setup
This document outlines the process/steps required for you to create a Visual Studio repository for Organization to be hosted internally
## Prerequisite
* A valid Microsoft subscription account to access the following 
* VS professional installer
* VS volume license key
* MPC Code for the required Visual Studio
* Access to your company’s role account for setting required directory structure and installer file under desired directory/destination.

#### How to get the MPC code<br/>
Visit [VS MPC Code](https://docs.microsoft.com/en-us/visualstudio/install/automatically-apply-product-keys-when-deploying-visual-studio)
> By default, the page shows the latest VS made available by Microsoft. You can change the VS version from the left-hand side of the browser menu.

## Setting up Visual Studio for network installation
### Download the installer and create a layout
* Download the professional version installer to a computer (Make sure you have at least __~50GB__ free space).
* Open a _PowerShell_ with _Administrative_ privileges.
* Run the following commands 
* cd __<Path_where_installer_is_downloaded>__
* Run __vs_professional.exe --layout <Destination> --lang en-US__
> _DESTINATION_ - Repository directory, I usually follow the template _VSVERSION_. Example "VS2019" for Visual Studio 2019.<br/>
> This command will take some time to complete. Its purpose is to download all the available modules in Visual Studio and make it available as a local resource for installation.

### Update the Response.json File
In general running, the VS installer will either install all modules by default or will leave up to the users to select the packages. But as admin and keeping infrastructure distribution in view, we choose packages that are needed. To make sure we have consistent modules for everyone, the layout folder holds a file __Response.json__. This file holds properties and settings that are necessary to enable Visual Studio Installer to be a network Installer.<br/><br/>
For every new VS, make sure you add the following entries
* __installPath__: _Target installation folder on the client's computer_
* __quiet__: _false_
* __passive__: _true_
* __includerRecommended__: _true_
* __norestart__: _true_
* __addProductLang__: _["en-us"]_
* __add__: _[All the required modules]_

#### Available components/Module
Visit [Component/Module](https://docs.microsoft.com/en-us/visualstudio/install/workload-and-component-ids)
> By default, the page shows the latest VS made available by Microsoft. You can change the VS version from the left-hand side of the browser menu.

***Leave the following key in response.json as defaulted to.***
```
{
    "installChannelUri":<XXYYZZ>,
    "channelUri":<XXYYZZ>,
    "installCatalogUri":<XXYYZZ>,
    "channelId":<XXYYZZ>,
    "productId":<XXYYZZ>,
}
```
#### Example Response.json for Visual Studio 2019 
```
{
    "installChannelUri":".\\ChannelManifest.json",
    "channelUri":"https://aka.ms/vs/16/release/channel",
    "installCatalogUri":".\\Catalog.json",
    "channelId":"VisualStudio.16.Release",
    "productId":"Microsoft.VisualStudio.Product.Professional",
    "installPath": "C:\\msvs2019",
    "quiet": false,
    "passive": true,
    "includeRecommended":  true,
    "norestart": true,
    "addProductLang":["en-us"],
    "add": [
                "Microsoft.VisualStudio.Component.IntelliTrace.FrontEnd",
                "Microsoft.VisualStudio.Workload.NativeDesktop",
                "Microsoft.VisualStudio.Workload.NativeCrossPlat",
                "Microsoft.VisualStudio.Component.UWP.VC.ARM64"
    ]
}
```
