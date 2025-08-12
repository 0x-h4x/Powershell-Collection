## WIP - Work in progress
*(all scripts are tested, however use on your own discretion, i take no responsiblities for your shit breaking)*

# Powershell-Collection
### A collection of the powershell scripts to automate tedious tasks.



To run these scripts remotely, usse the following command:

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

[**DontSleep.ps1**](https://github.com/0x-h4x/Powershell-Collection/blob/main/Scripts/DontSleep.ps1)\
*This PowerShell script prevents the computer from sleeping or dimming the display while it runs. It keeps the system awake in a loop and restores normal sleep behavior when stopped (via Ctrl+C)*

[**RepairSecureChannel.ps1**](https://github.com/0x-h4x/Powershell-Collection/blob/main/Scripts/RepairSecureChannel.ps1)\
*This PowerShell script checks if the secure channel to AD is broken, if yes it prompts for AD domain credentials and tries to repair the channel. It must be run as an administrator and you will need to have an AD Domain Admin avalible for repair.\
Run with "FalseP" to force repair regardless of status.*

**Open a issue to make a request.**

#

<div align="right">
  <p><em>Star me :)</em>
  <a href="https://github.com/0x-h4x/Powershell-Collection">
    </p> <img src="https://img.shields.io/github/stars/0x-h4x/Powershell-Collection?style=social" alt="Star on GitHub" />
  </a>
</div>


