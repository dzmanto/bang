Option Explicit
Dim WshShell

Set WshShell = CreateObject("WScript.Shell")

<<<<<<< HEAD
WshShell.Run "powershell.exe -nologo -NoProfile -ExecutionPolicy Bypass -command .\rotanconv36.ps1", 0, false
=======
WshShell.Run "powershell.exe -nologo -NoProfile -ExecutionPolicy Bypass -command .\rotanconv35.ps1", 0, false
>>>>>>> a9ab5839e7ebc1400bdf81aafaa63ca57cb5d7ab

set WshShell = nothing
WScript.Quit
