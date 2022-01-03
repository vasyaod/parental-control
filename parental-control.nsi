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
File parental-control-service.exe
File parental-control-service.xml
File config.yml

WriteUninstaller $INSTDIR\Uninstall.exe
; nsExec::ExecToStack '"$INSTDIR\reic\refresh.bat"'

ExecWait '"$INSTDIR\parental-control-service.exe" install'
ExecWait '"$INSTDIR\parental-control-service.exe" start'

SectionEnd ; end the section

; The uninstall section
Section "Uninstall"

ExecWait '"$INSTDIR\parental-control-service.exe" stop'
ExecWait '"$INSTDIR\parental-control-service.exe" uninstall'

RMDir /r "$INSTDIR\*.*"
RMDir $INSTDIR

SectionEnd