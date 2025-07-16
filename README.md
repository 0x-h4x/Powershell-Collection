# Powershell-Collection
A collection of the powerhell scripts ive made for diffrent tasks.

### Scripts:

**DeleteAllUsers.Ps1**

*This scripts deletes all local users besides the ones specified. This included both local and hybrid / AD users.*
*You will be promted to list the users to exclude. It must be run as an Administrator as we are modifying files outside the users scope*

**IncreaseSCCMCache.ps1**

*This PowerShell script increases the SCCM client cache size to 15 GB, restarts the SMS Agent Host service, and confirms the change. It must be run as an administrator and is intended for systems with the SCCM client installed.*
