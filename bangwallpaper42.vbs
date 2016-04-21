Option Explicit
Dim WshShell

Set WshShell = CreateObject("WScript.Shell")

REM Check if powershell is enabled
REM On Error Resume Next
REM rps=WshShell.RegRead("HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell\ExecutionPolicy")
REM If Err.Number <> 0 Then
REM	writelog("No key HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell\ExecutionPolicy. Exit.")
REM	set WshShell = nothing
REM	WScript.Quit
REM End If

REM if trim(LCase(rps)) <> "remotesigned" and trim(LCase(rps)) <> "unrestricted" then
REM 	writelog("No permission to run powershell scripts. Exit")
REM	set WshShell = nothing
REM	WScript.Quit
REM end if


WshShell.Run "powershell.exe -nologo -ExecutionPolicy Bypass -command .\rotanconv10.ps1", 0, TRUE

set WshShell = nothing
WScript.Quit
