; The name of the installer
Name "Parental Control"

; The file to write
OutFile "parental-control-setup.exe"

!include "MUI.nsh"
!insertmacro MUI_PAGE_LICENSE "LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

; Uninstall pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; The default installation directory
InstallDir $PROGRAMFILES64\parental-control

; The text to prompt the user to enter a directory
DirText "This will install My Cool Program on your computer. Choose a directory"

RequestExecutionLevel admin

;--------------------------------

; The stuff to install
Section "Primary service" ;No components page, name is not important

SectionIn RO ; Read only, always installed

; Set output path to the installation directory.
SetOutPath $INSTDIR

; Put file there
File parental-control.exe
File parental-control-web.exe
File parental-control-service.exe
File parental-control-service.xml
File config.yml
File README.md
File LICENSE

File parental-control-web-service.exe
File parental-control-web-service.xml
File bundle.js
File index.html

WriteUninstaller $INSTDIR\Uninstall.exe
; nsExec::ExecToStack '"$INSTDIR\reic\refresh.bat"'

ExecWait '"$INSTDIR\parental-control-service.exe" install'
ExecWait '"$INSTDIR\parental-control-service.exe" start'

ExecWait '"$INSTDIR\parental-control-web-service.exe" install'
ExecWait '"$INSTDIR\parental-control-web-service.exe" start'

SectionEnd ; end the section

;Section "Web interface"

;SetOutPath $INSTDIR

;File parental-control-web-service.exe
;File parental-control-web-service.xml
;File bundle.js
;File index.html

;ExecWait '"$INSTDIR\parental-control-service.exe" install'
;ExecWait '"$INSTDIR\parental-control-service.exe" start'

;SectionEnd

; The uninstall section
Section "Uninstall"

ExecWait '"$INSTDIR\parental-control-web-service.exe" stop'
ExecWait '"$INSTDIR\parental-control-web-service.exe" uninstall'

ExecWait '"$INSTDIR\parental-control-service.exe" stop'
ExecWait '"$INSTDIR\parental-control-service.exe" uninstall'

RMDir /r "$INSTDIR\*.*"
RMDir $INSTDIR

SectionEnd