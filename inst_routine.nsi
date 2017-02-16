; example1.nsi
;
; This script is perhaps one of the simplest NSIs you can make. All of the
; optional settings are left to their default settings. The installer simply 
; prompts the user asking them where to install, and drops a copy of example1.nsi
; there. 

;--------------------------------

!include MUI2.nsh
!include nsDialogs.nsh
!include LogicLib.nsh

!define MUI_WELCOMEPAGE
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\$(^Name)"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
!define MUI_DIRECTORYPAGE
; !insertmacro MUI_PAGE_COMPONENTS

Var SMDir

!insertmacro MUI_PAGE_WELCOME
;Start Menu Folder Page Configuration
!insertmacro MUI_PAGE_STARTMENU 0 $SMDir
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_RUN "$SYSDIR\wscript.exe"
!define MUI_FINISHPAGE_RUN_PARAMETERS "/E:vbscript $\"$INSTDIR\bangwallpaper42.vbs$\""
!define MUI_FINISHPAGE_RUN_TEXT $(Message_complete)
!define MUI_FINISHPAGE_RUN_CHECKED
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"
LangString Message_complete ${LANG_ENGLISH} "Installation complete. Run Bang Wallpaper Plus now?"
LangString Message_complete ${LANG_FRENCH} "Installation complète. Veuillez exécuter Bang Wallpaper Plus maintenant?"
LangString Message_complete ${LANG_GERMAN} "Fertig. Bang Wallpaper Plus jetzt ausführen?"
LangString Message_startup ${LANG_ENGLISH} "&Create startup item"
LangString Message_startup ${LANG_FRENCH} "&Créer un élément de démarrage"
LangString Message_startup ${LANG_GERMAN} "&Autostart-Element erstellen"

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

; The stuff to install
Section "" ;No components page, name is not important

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  WriteUninstaller "uninstall.exe"
  
  ; Put file there
  File bang.ini
  File bangwallpaper42.vbs
  File guisttngs.ps1
  File HELP.hta
  File parrot.ico
  File README.txt
  File settings.vbs
  File rotanconv23.ps1
   
  CreateShortcut "$SMSTARTUP\Bang Wallpaper Plus.lnk" $INSTDIR\bangwallpaper42.vbs "" $INSTDIR\parrot.ico 0
SectionEnd ; end the section

Section -StartMenu
!insertmacro MUI_STARTMENU_WRITE_BEGIN 0 ;This macro sets $SMDir and skips to MUI_STARTMENU_WRITE_END if the "Don't create shortcuts" checkbox is checked... 
CreateDirectory "$SMPrograms\$SMDir"
; CreateShortCut "$SMPROGRAMS\$SMDir\Bang Wallpaper Plus.lnk" "$\"$INSTDIR\bangwallpaper42.vbs$\""
CreateShortcut "$SMPROGRAMS\$SMDir\Bang Wallpaper Plus.lnk" $INSTDIR\bangwallpaper42.vbs "" $INSTDIR\parrot.ico 0
CreateShortcut "$SMPROGRAMS\$SMDir\Help.lnk" $INSTDIR\HELP.hta
CreateShortcut "$SMPROGRAMS\$SMDir\Settings.lnk" $INSTDIR\settings.vbs "" $INSTDIR\parrot.ico 0
CreateShortcut "$SMPROGRAMS\$SMDir\Uninstall.lnk" $INSTDIR\uninstall.exe
!insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Function .onInstSuccess
    ; MessageBox MB_YESNO "$(Message_complete)" IDNO NoRun
    ;	Exec '"$SYSDIR\wscript.exe" //E:vbscript "$INSTDIR\bangwallpaper42.vbs"' ; run bang
    ;	Sleep 3000
    ; NoRun:
FunctionEnd

Section "Uninstall"
  Delete $INSTDIR\bangwallpaper43.vbs
  Delete $INSTDIR\bangwallpaper42.vbs
  Delete $INSTDIR\bangwallpaper40.vbs
  Delete $INSTDIR\bang.ini
  Delete $INSTDIR\bingimage.jpg
  Delete $INSTDIR\bingimagean.bmp
  Delete $INSTDIR\desc.txt
  Delete $INSTDIR\dumpproxy.ps1
  Delete $INSTDIR\dumpproxy.txt
  Delete $INSTDIR\guisttngs.ps1
  Delete $INSTDIR\HELP.hta
  Delete $INSTDIR\heise
  Delete $INSTDIR\hostinfo 
  Delete $INSTDIR\log.txt
  Delete $INSTDIR\parrot.ico
  Delete $INSTDIR\pwd.txt
  Delete $INSTDIR\README.txt
  Delete $INSTDIR\rotanconv23.ps1
  Delete $INSTDIR\rotanconv22.ps1
  Delete $INSTDIR\rotanconv21.ps1
  Delete $INSTDIR\rotanconv20.ps1
  Delete $INSTDIR\rotanconv19.ps1
  Delete $INSTDIR\rotanconv18.ps1
  Delete $INSTDIR\rotanconv17.ps1
  Delete $INSTDIR\rotanconv16.ps1
  Delete $INSTDIR\rotanconv11.ps1
  Delete $INSTDIR\rotanconv10.ps1
  Delete $INSTDIR\rotanconv7.ps1
  Delete $INSTDIR\settings.vbs
  Delete $INSTDIR\uninstall.exe
  RMDir $INSTDIR
  
  !insertmacro MUI_STARTMENU_GETFOLDER 0 $SMDir
  
  Delete "$SMSTARTUP\Bang Wallpaper Plus.lnk"
  Delete "$SMPROGRAMS\$SMDir\Bang Wallpaper Plus.lnk"
  Delete "$SMPROGRAMS\$SMDir\Help.lnk"
  Delete "$SMPROGRAMS\$SMDir\Settings.lnk"
  Delete "$SMPROGRAMS\$SMDir\Uninstall.lnk"
  RMDIR "$SMPROGRAMS\$SMDir"
SectionEnd

; Todo: registry key check via exec external vbs, request creation of startup folder items, dialog for registry modifications;
