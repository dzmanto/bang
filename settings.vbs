Option Explicit
Dim WshShell

Set WshShell = CreateObject("WScript.Shell")

REM WshShell.Run "powershell.exe -nologo -file .\guisttngs.ps1"

WshShell.Run "powershell -nologo -noexit -ExecutionPolicy Bypass -WindowStyle Hidden -command .\guisttngs.ps1", 0, False

set WshShell = nothing
WScript.Quit
