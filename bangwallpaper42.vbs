Option Explicit
Dim WshShell

Set WshShell = CreateObject("WScript.Shell")

WshShell.Run "powershell.exe -nologo -ExecutionPolicy Bypass -command .\rotanconv26.ps1", 0, TRUE

set WshShell = nothing
WScript.Quit
