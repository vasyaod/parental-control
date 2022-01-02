; The name of the installer
Name "Parental Control"

; The file to write
OutFile "parental-control-setup.exe"

; The default installation directory
InstallDir $PROGRAMFILES64\parental-control

; The text to prompt the user to enter a directory
DirText "This will install My Cool Program on your computer. Choose a directory"

RequestExecutionLevel admin

;--------------------------------

; The stuff to install
Section "" ;No components page, name is not important

; Set output path to the installation directory.
SetOutPath $INSTDIR

; Put file there
File parental-control.exe
File parental-control-web.exe
File config.yml

WriteUninstaller $INSTDIR\Uninstall.exe

SectionEnd ; end the section

; The uninstall section
Section "Uninstall"

Delete $INSTDIR\Uninstall.exe
Delete $INSTDIR\parental-control.exe
Delete $INSTDIR\parental-control-web.exe
RMDir $INSTDIR

SectionEnd 