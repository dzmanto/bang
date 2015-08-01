Option Explicit
Dim H 
Dim pos0, pos1, pos2 
Dim url
Dim desc
Dim WshShell
Dim filesys, filetxt
Dim objHTTP
Dim pwd 
Dim i
Dim objFile
Dim objStream
Dim proxy
Dim errout
Dim rps
Dim imgpath

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


REM programmatically retrieve proxy
WshShell.Run "powershell.exe -nologo -ExecutionPolicy Bypass -command .\dumpproxy.ps1", 0, TRUE

Set objFile = CreateObject("Scripting.FileSystemObject")
If objFile.FileExists("dumpproxy.txt") Then
	Set objFile = objFile.OpenTextFile("dumpproxy.txt", 1)
Else
	set objFile = nothing
	set WshShell = nothing
	WScript.Quit
End If

Do Until objFile.AtEndOfStream
    proxy = objFile.ReadLine  
Loop
objFile.Close

if Instr(proxy,"http://") = 1 then
	proxy = Mid(proxy,8, Len(proxy))
elseif Instr(proxy,"https://") = 1 then
	proxy = Mid(proxy, 9, Len(proxy))
end if

if proxy <> "" then
if Mid(proxy,Len(proxy),1) = "/" then
	proxy = Mid(proxy,1,Len(proxy) -1)
end if
end if

Set objHTTP = CreateObject( "WinHttp.WinHttpRequest.5.1" )
REM Download the specified URL
objHTTP.Open "GET", "http://www.bing.com/", False
On Error Resume Next
if proxy <> "" then
	objHTTP.setProxy 2, proxy
end if
REM objHttp.setRequestHeader "User-Agent", "Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+5.1)"
objHTTP.setRequestHeader "Content-Type", "application/x-www-form-urlencoded; charset=UTF-8"
objHTTP.Send
If Err.Number <> 0 Then
	errout = "Download from http://www.bing.com/ returned error " + CStr(Err.Number) + "."
	writelog(errout)
	set objHTTP = nothing
	set objFile = nothing
	set WshShell = nothing
	Wscript.Quit
End If

Set objStream = CreateObject("ADODB.Stream")
objStream.Open
objStream.Type = 1
objStream.Write objHTTP.Responsebody
objStream.Position = 0
objStream.Type = 2
objStream.Charset = "utf-8"
H = objStream.ReadText
Set objStream = Nothing

objHTTP.Disconnect

if Len(H)=0 then
	writelog("Zero length ADODB object stream.")
	set objStream = nothing
	set objHTTP = nothing
	set objFile = nothing
	set WshShell = nothing
	WScript.Quit
end if

pos0=Instr(H,"""hpcNext""></div></div></a><a href")
pos1=Instr(pos0,H,"title=")
pos2=Instr(pos1, H,"hpcCopyInfo")
desc=Mid(H,pos1+7, pos2-pos1-59)
if Len(Trim(desc))=0 or pos1<100 then
	pos0=Instr(H,"""hpcNext""></div></div></a><a href")
	pos1=Instr(pos0,H,"alt=")
	pos2=Instr(pos1, H,"hpcCopyInfo")
	desc=Mid(H,pos1+5, pos2-pos1-85)
end if

desc=Replace(desc,"&#128;","€")
desc=Replace(desc,"&#147;","“")
desc=Replace(desc,"&#148;","”")
desc=Replace(desc,"&#163;","£")
desc=Replace(desc,"&#169;","©")
desc=Replace(desc,"&#171;","«")
desc=Replace(desc,"&#176;","°")
desc=Replace(desc,"&#187;","»")
desc=Replace(desc,"&#196;","Ä")
desc=Replace(desc,"&#201;","É")
desc=Replace(desc,"&#214;","Ö")
desc=Replace(desc,"&#220;","Ü")
desc=Replace(desc,"&#223;","ß")
desc=Replace(desc,"&#228;","ä")
desc=Replace(desc,"&#233;","é")
desc=Replace(desc,"&#237;","í")
desc=Replace(desc,"&#240;","ð")
desc=Replace(desc,"&#246;","ö")
desc=Replace(desc,"&#252;","ü")
desc=Replace(desc,"&amp;","&")
desc=Replace(desc,"’","specialtickcharacter") ' works

pos1=Instr(H,"g_img={url:'")
pos2=Instr(pos1, H,".jpg")

url=Mid(H,pos1+12, pos2-pos1-8)

if Len(url)=0 then
	writelog("Zero length url of bing image.")
	set filesys = nothing
	set filetxt = nothing
	set objStream = nothing
	set objHTTP = nothing
	set objFile = nothing
	set WshShell = nothing
	WScript.Quit
end if

url = "http://www.bing.com" + url

REM Download the bing image from the url
objHTTP.Open "GET", url, False
On Error Resume Next
objHTTP.Send
If Err.Number <> 0 Then
	errout = "failed to download bing image from the url " + url + ". Error number " + CStr(Err.Number) + "."
	writelog(errout)
	set filesys = nothing
	set filetxt = nothing
	set objStream = nothing
	set objHTTP = nothing
	set objFile = nothing
	set WshShell = nothing
  	Wscript.Quit
End If
	
REM Write the downloaded byte stream to the target file
H=""
For i = 1 To LenB( objHTTP.ResponseBody )
    H = H + Chr( AscB( MidB( objHTTP.ResponseBody, i, 1 ) ) )
Next
objHTTP.Disconnect

Set filesys = CreateObject("Scripting.FileSystemObject")
Set filetxt = filesys.OpenTextFile("bingimage.jpg", 2, True) 
filetxt.Write H
filetxt.Close 

WshShell.Run "powershell.exe -nologo -ExecutionPolicy Bypass -command .\rotanconv4.ps1 {" + desc + "}", 0, TRUE
REM WshShell.Run "powershell.exe -nologo -ExecutionPolicy Bypass -command .\powershell_change_background.ps1", 0, TRUE
REM WshShell.Run "powershell.exe -nologo -command .\powershell_change_background.ps1", 0, TRUE

REM pwd=WshShell.CurrentDirectory
REM imgpath = pwd + "\bingimgean.bmp"
REM WshShell.RegWrite "HKCU\Control Panel\Desktop\Wallpaper", imgpath


set WshShell = nothing
set objHTTP = nothing
Set objFile = nothing
Set filesys = nothing
Set filetxt = nothing
set objStream = nothing
WScript.Quit

Function writelog(lgtxt)
	Dim logsys
	Dim logtxt
	Set logsys = CreateObject("Scripting.FileSystemObject")
	Set logtxt = logsys.OpenTextFile("log.txt", 8, True)
	logtxt.Write Now
	logtxt.Write " "
	logtxt.WriteLine(lgtxt)
	logtxt.close
	Set logtxt = nothing
	Set logsys = nothing
End Function

Function ConvertBinaryData(arrBytes)
  Dim objStream
  Set objStream = CreateObject("ADODB.Stream")
  objStream.Open
  objStream.Type = 1
  objStream.Write arrBytes
  objStream.Position = 0
  objStream.Type = 2
  objStream.Charset = "utf-8"
  ConvertBinaryData = objStream.ReadText
  Set objStream = Nothing
End Function
