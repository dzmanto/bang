; example1.nsi
;
; This script is perhaps one of the simplest NSIs you can make. All of the
; optional settings are left to their default settings. The installer simply 
; prompts the user asking them where to install, and drops a copy of example1.nsi
; there. 

;--------------------------------

!include "MUI.nsh"

!define MUI_WELCOMEPAGE
!define MUI_COMPONENTSPAGE
!define MUI_DIRECTORYPAGE
!define MUI_FINISHPAGE

; !insertmacro MUI_PAGE_WELCOME
; !insertmacro MUI_PAGE_COMPONENTS

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"

LangString Message ${LANG_ENGLISH} "Installation complete. Run Bang Wallpaper Plus now?"
LangString Message ${LANG_FRENCH} "Installation complète. Veuillez exécuter Bang Wallpaper Plus maintenant?"
LangString Message ${LANG_GERMAN} "Fertig. Bang Wallpaper Plus jetzt ausführen?"

Function .onInit
FunctionEnd

; The name of the installer
Name "Bang Wallpaper Plus"

; The file to write
OutFile bang.exe

; The default installation directory
InstallDir "$DESKTOP\Bang Wallpaper Plus"

; Icon
Icon parrot.ico

; Request application privileges for Windows Vista
RequestExecutionLevel user

;--------------------------------

; Pages
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section "" ;No components page, name is not important
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  WriteUninstaller "uninstall.exe"
  
  ; Put file there
  File bangwallpaper42.vbs
  File HELP.hta
  File hostinfo
  File parrot.ico
  File README.txt
  File rotanconv21.ps1
  
  CreateShortcut "$SMPROGRAMS\Startup\Bang Wallpaper Plus.lnk" $INSTDIR\bangwallpaper42.vbs "" $INSTDIR\parrot.ico 0
SectionEnd ; end the section

Function .onInstSuccess
    MessageBox MB_YESNO "$(Message)" IDNO NoRun
	Exec '"$SYSDIR\wscript.exe" //E:vbscript "$INSTDIR\bangwallpaper42.vbs"' ; run bang
	Sleep 3000
    NoRun:
FunctionEnd

Section "Uninstall"
  Delete "$SMPROGRAMS\Startup\Bang Wallpaper Plus.lnk"
  Delete $INSTDIR\bangwallpaper43.vbs
  Delete $INSTDIR\bangwallpaper42.vbs
  Delete $INSTDIR\bangwallpaper40.vbs
  Delete $INSTDIR\bingimage.jpg
  Delete $INSTDIR\bingimagean.bmp
  Delete $INSTDIR\desc.txt
  Delete $INSTDIR\dumpproxy.ps1
  Delete $INSTDIR\dumpproxy.txt
  Delete $INSTDIR\HELP.hta
  Delete $INSTDIR\heise
  Delete $INSTDIR\hostinfo 
  Delete $INSTDIR\log.txt
  Delete $INSTDIR\parrot.ico
  Delete $INSTDIR\pwd.txt
  Delete $INSTDIR\README.txt
  Delete $INSTDIR\rotanconv21.ps1
  Delete $INSTDIR\rotanconv20.ps1
  Delete $INSTDIR\rotanconv19.ps1
  Delete $INSTDIR\rotanconv18.ps1
  Delete $INSTDIR\rotanconv17.ps1
  Delete $INSTDIR\rotanconv16.ps1
  Delete $INSTDIR\rotanconv11.ps1
  Delete $INSTDIR\rotanconv10.ps1
  Delete $INSTDIR\rotanconv7.ps1
  Delete $INSTDIR\uninstall.exe
  RMDir $INSTDIR
SectionEnd

; Todo: registry key check via exec external vbs, request creation of startup folder items, dialog for registry modifications;
