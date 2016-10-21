Option Explicit
Dim dt
Dim owd
Dim wd
Dim WshShell

owd = -1
Set WshShell = CreateObject("WScript.Shell")

while true
	dt = Date
	wd = WeekDay(dt)
	if(wd <> owd) then 
		WshShell.Run "powershell.exe -nologo -ExecutionPolicy Bypass -command .\rotanconv20.ps1", 0, TRUE
		owd = wd
	end if
	REM check every hour if today is a new day
	WScript.Sleep 3600*1000
wend

set WshShell = nothing
WScript.Quit