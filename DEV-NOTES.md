# Parental control

 * [Add binary file as service on Windows](https://docs.microsoft.com/en-US/windows-server/administration/windows-commands/sc-create)
 * [nsis documetation (windows installer)](https://nsis.sourceforge.io/Docs/Chapter2.html#tutintro)
   * https://github.com/joncloud/makensis-action
   * https://github.com/marketplace/actions/makensis
 * https://github.com/marketplace/actions/setup-msbuild

## Mono
 
 An attempt to build haskell Windows version by Wine 
 
 * Install winehq
 * Download mono from https://dl.winehq.org/wine/wine-mono/ 
 * Install mono by `wine msiexec /i ./wine-mono-6.0.0-x86.msi`
 
# Windows command line

```
# Session ID query / Check command 
query user yasha 

# Log out command.
logoff $SESSION_ID
``` 

# Service

```
sc.exe create parental-control type=own start=delayed-auto binpath="C:\Program Files\parental-control\parental-control.exe -c C:\Program Files\parental-control\config.yml"
sc.exe delete parental-control
```
 
 
 
