## WIP - Work in progress
*(all scripts are tested, however use on your own discretion, i take no responsiblities for your shit breaking)*

# Powershell-Collection
### A collection of the powershell scripts to automate tedious tasks.

Feel free to fork these and customize them to automate tasks within your own environment.



To run these scripts remotely, use the following command:

```
$script="$env:TEMP\TempScript.ps1"; Invoke-WebRequest 'https://raw.githubusercontent.com/0x-h4x/Powershell-Collection/refs/heads/main/Scripts/ReplaceMe.ps1' -OutFile $script; & $script; Remove-Item $script -Force
```

**Replace ReplaceMe.ps1 with the script of your wish.**

If policies are blocking powershell scripts; use this command to allow scripts for the current powershell session.
```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
```


### Scripts:

[**DeleteAllUsers.ps1**](https://github.com/0x-h4x/Powershell-Collection/blob/main/Scripts/DeleteAllUsers.ps1)\
*This scripts deletes all users besides the ones specified and the default Windows users. This includes both local and hybrid / AD users.*
*You will be promted to list the users to exclude. It must be run as an Administrator as we are modifying files outside the users scope*

[**IncreaseSCCMCache.ps1**](https://github.com/0x-h4x/Powershell-Collection/blob/main/Scripts/IncreaseSCCMCache.ps1)\
*This PowerShell script increases the SCCM client cache size (default 15 GB), restarts the SMS Agent Host service, and confirms the change. It must be run as an administrator and is intended for systems with the SCCM client installed.*
**Will be upgraded to use CIM instead of WIM.**

[**NoSleep.ps1**](https://github.com/0x-h4x/Powershell-Collection/blob/main/Scripts/NoSleep.ps1)\
*This PowerShell script prevents the computer from sleeping or dimming the display while it runs. It keeps the system awake in a loop and restores normal sleep behavior when stopped (via Ctrl+C)*

[**RepairSecureChannel.ps1**](https://github.com/0x-h4x/Powershell-Collection/blob/main/Scripts/RepairSecureChannel.ps1)\
*This PowerShell script checks if the secure channel to AD is broken, if yes it prompts for AD domain credentials and tries to repair the channel. It must be run as an administrator and you will need to have an AD Domain Admin avalible for repair.\
Run with "FalseP" to force repair regardless of status.*

[**InstallPrinter.ps1**](https://github.com/0x-h4x/Powershell-Collection/blob/main/Scripts/InstallPrinter.ps1)\
*Automates the task of installing a networksprinter, also sets the new printer as default. Add the name and path of the printer and let it run. If the printername is the same as the path, you only need the path. i.e "\\\10.0.0.1\Printername"*

[**TestAdCreds.ps1**](https://github.com/0x-h4x/Powershell-Collection/blob/main/Scripts/TestAdCreds.ps1)\
*This PowerShell script prompts the user for credentials and then attempts to authenticate the provided username and password against Active Directory (AD).
You will need to be on a domain joined computer for this to work*

[**AdToolsInstaller.ps1**](https://github.com/0x-h4x/Powershell-Collection/blob/main/Scripts/AdToolsInstaller.ps1)\
*This PowerShell script is an automated installer for Active Directory management tools that ensures you’re running it as Administrator, detects your Windows version to confirm RSAT can be installed via Windows capabilities (Windows 10 1809+ or Windows 11), and then checks which tools are already present. It offers a menu where you can choose to install ADUC (Active Directory Users and Computers), the RSAT ActiveDirectory PowerShell module, or both at once *

**Open a issue to make a request.**

#

<div align="right">
  <p><em>Star me :)</em>
  <a href="https://github.com/0x-h4x/Powershell-Collection">
    </p> <img src="https://img.shields.io/github/stars/0x-h4x/Powershell-Collection?style=social" alt="Star on GitHub" />
  </a>
</div>


