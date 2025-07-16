# Powershell-Collection
A collection of the powerhell scripts ive made for diffrent tasks.

### Scripts:

[**DeleteAllUsers.Ps1**](https://github.com/0x-h4x/Powershell-Collection/blob/main/DeleteAllUsers.ps1)

*This scripts deletes all users besides the ones specified. This included both local and hybrid / AD users.*
*You will be promted to list the users to exclude. It must be run as an Administrator as we are modifying files outside the users scope*

[**IncreaseSCCMCache.ps1**](https://github.com/0x-h4x/Powershell-Collection/blob/main/IncreaseSCCMCache.ps1)

*This PowerShell script increases the SCCM client cache size to 15 GB, restarts the SMS Agent Host service, and confirms the change. It must be run as an administrator and is intended for systems with the SCCM client installed.*

[**DontSleep.ps1**](https://github.com/0x-h4x/Powershell-Collection/blob/main/DontSleep.ps1)

*This PowerShell script prevents the computer from sleeping or dimming the display while it runs. It keeps the system awake in a loop and restores normal sleep behavior when stopped (via Ctrl+C)*
