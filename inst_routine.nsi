; example1.nsi
;
; This script is perhaps one of the simplest NSIs you can make. All of the
; optional settings are left to their default settings. The installer simply 
; prompts the user asking them where to install, and drops a copy of example1.nsi
; there. 

;--------------------------------

!include "MUI.nsh"
!include "StrFunc.nsh"

!define MUI_WELCOMEPAGE
!define MUI_COMPONENTSPAGE
!define MUI_DIRECTORYPAGE
!define MUI_FINISHPAGE

; !insertmacro MUI_PAGE_WELCOME
; !insertmacro MUI_PAGE_COMPONENTS

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "German"

LangString Message ${LANG_ENGLISH} "Installation complete. Run bong wallpaper plus?"
LangString Message ${LANG_GERMAN} "Fertig. Bong Wallpaper Plus ausf�hren?"

Function .onInit
FunctionEnd

; The name of the installer
Name "bong wallpaper plus"

; The file to write
OutFile bong.exe

; The default installation directory
InstallDir $DESKTOP\bong

; Icon
Icon parrot.ico

; Request application privileges for Windows Vista
RequestExecutionLevel user

# Declare used functions
${StrCase}
${StrClb}
${StrIOToNSIS}
${StrLoc}
${StrNSISToIO}
${StrRep}
${StrStr}
${StrStrAdv}
${StrTok}
${StrTrimNewLines}
${StrSort}

${UnStrCase}
${UnStrClb}
${UnStrIOToNSIS}
${UnStrLoc}
${UnStrNSISToIO}
${UnStrRep}
${UnStrStr}
${UnStrStrAdv}
${UnStrTok}
${UnStrTrimNewLines}
${UnStrSort}

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
  File bingwallpaper31.vbs
  File dumpproxy.ps1
  File powershell_change_background.ps1
  File rotanconv2.ps1
  File parrot.ico
  CreateShortcut $SMPROGRAMS\Startup\bong.lnk $INSTDIR\bingwallpaper31.vbs "" $INSTDIR\parrot.ico 0
  ; ReadRegStr $0  HKLM "SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" "ExecutionPolicy"
  ; ${StrCase} $1 $0 "L"
  ; MessageBox MB_YESNO|MB_ICONEXCLAMATION $1
  ; StrCmp $1 "remotesigned" goahead
  ; StrCmp $1 "unrestricted" goahead
  ; MessageBox MB_YESNO|MB_ICONEXCLAMATION "fix registry now"
  ; WriteRegStr HKLM "SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" "ExecutionPolicy" "Remotesigned"
  ; goahead:
  	  ; everything alright
SectionEnd ; end the section

Function .onInstSuccess
    MessageBox MB_YESNO "$(Message)" IDNO NoRun
	Exec '"$SYSDIR\wscript.exe" //E:vbscript "$INSTDIR\bingwallpaper31.vbs"' ; run bong
	Sleep 3000
    NoRun:
FunctionEnd

Section "Uninstall"
  ; DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BigNSISTest"
  ; DeleteRegKey HKLM "SOFTWARE\NSISTest\BigNSISTest"
  Delete $SMPROGRAMS\Startup\bong.lnk
  Delete $INSTDIR\bingwallpaper31.vbs
  Delete $INSTDIR\dumpproxy.ps1
  Delete $INSTDIR\powershell_change_background.ps1
  Delete $INSTDIR\rotanconv2.ps1
  Delete $INSTDIR\parrot.ico
  Delete $INSTDIR\desc.txt
  Delete $INSTDIR\dumpproxy.txt
  Delete $INSTDIR\pwd.txt
  Delete $INSTDIR\bingimage.jpg
  Delete $INSTDIR\bingimagean.bmp
  Delete $INSTDIR\uninstall.exe
  RMDir $INSTDIR
SectionEnd

; Todo: registry key check via exec external vbs, request creation of startup folder items, dialog for registry modifications;
