Option Explicit
Dim WshShell

Set WshShell = CreateObject("WScript.Shell")

WshShell.Run "powershell.exe -nologo -NoProfile -ExecutionPolicy Bypass -command .\rotanconv35.ps1", 0, false

set WshShell = nothing
WScript.Quit
