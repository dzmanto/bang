Option Explicit
Dim WshShell

Set WshShell = CreateObject("WScript.Shell")

WshShell.Run "powershell.exe -nologo -NoProfile -ExecutionPolicy Bypass -command .\rotanconv29.ps1", 0, TRUE

set WshShell = nothing
WScript.Quit
