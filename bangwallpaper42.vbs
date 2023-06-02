Option Explicit
Dim WshShell
Dim objFSO
Dim cmd
Dim counter
Dim f
Dim ftd
Dim i
Dim ke
Set WshShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

counter = 0
ftd = false
ke = true
while ke = true
	counter = counter + 1
	f = "rotanconv" & counter & ".ps1"
	if(objFSO.FileExists(f)) then
		ke = true
		ftd = true
	else
		if(ftd = true) then
			ke = false
			f = "rotanconv" & counter - 1 & ".ps1"
		end if
	end if
	if counter < 2 OR counter = 37 then
		ke = true
	end if
wend

cmd = "cmd /c powershell.exe -nologo -NoProfile -ExecutionPolicy Bypass -command .\" & f
WshShell.Run cmd, 0, false

set WshShell = nothing
WScript.Quit
