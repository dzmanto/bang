[CmdletBinding()]

Param(
)

$signature = @"
[DllImport("user32.dll")]
public static extern bool SystemParametersInfo(int uAction, int uParam, ref int lpvParam, int flags );
"@

$systemParamInfo = Add-Type -memberDefinition  $signature -Name ScreenSaver -passThru

Add-Type @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32;

namespace Wallpaper
{
   public enum Style : int
   {
       Tile, Center, Stretch, NoChange
   }
   public class Setter {
      public const int SetDesktopWallpaper = 20;
      public const int UpdateIniFile = 0x01;
      public const int SendWinIniChange = 0x02;
      [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
      private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
            
      public static void SetWallpaper (string path) {
        SystemParametersInfo(SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange);
      }
   }
}
"@

function goget {
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		[string]$strurl,
  
		[Parameter(Mandatory=$False,Position=2)]
		[string]$isdata
	)
	Write-Verbose "Load target website $strurl"
	$proxy = [System.Net.WebRequest]::GetSystemWebProxy()
	$wc = New-Object Net.WebClient
	$wc.proxy = $proxy
	$wc.Headers.Add("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8")
	$wc.Headers.Add("User-Agent", "Mozilla/4.0+(compatible;+MSIE+8.0;+Windows+NT+5.1)")
	$wc.UseDefaultCredentials = $true
	$wc.proxy.Credentials = $wc.Credentials

	$contents = ""
	$count = 1
	Do {
		if($isdata.contains("yes")) {
			[BYTE[]] $contents = $wc.DownloadData($strurl)
		} else {
			$contents = $wc.DownloadString($strurl)
		}
		# a network connection may not be available yet. Sleep for 7 seconds.
		if($contents.length -eq 0) {
			$count = $count + 1
			Write-Verbose "Target website returned zero length."
			Write-Verbose "Retry in 7 seconds."	
			sleep -seconds 7
		}
	} while($contents.length -eq 0 -and $count -lt 100)
	
	$wc.Dispose()

	if($contents.length -eq 0) {
		Write-Verbose "Target website returned zero length."
		Write-Verbose "Exit."
		Exit 1
	} else {
		return $contents
	}
}

function cutidx {
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		[string]$strtocut, 
		
		[Parameter(Mandatory=$True,Position=2)]
		[string]$stridx 
	)
	$dc = $strtocut.indexof($stridx)
	if($dc -ge 0) {
		$strtocut = $strtocut.substring($dc)
	}
	return $strtocut
}

function getttl {
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		[string]$contents, 
		
		[Parameter(Mandatory=$True,Position=2)]
		[string]$marker 
	)
	$contents = cutidx $contents $marker
	$e = $contents.substring($marker.Length).indexof("""")
	$Title = $contents.substring(($marker.Length),$e)
	return $Title
}

function procstr {
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		[string]$strtoproc 
	)
	$strtoproc = $strtoproc -replace """" , ""
	$strtoproc = $strtoproc -replace "\\/" , "/"
	$strtoproc = $strtoproc -replace "'", ""
	$strtoproc = $strtoproc.trim()
	return $strtoproc
}

function proctitle {
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		[string]$strtoproc 
	)
	$strtoproc = $strtoproc -replace "&amp;" , "&"
	$strtoproc = $strtoproc -replace "&quot;" , [char]34
	$strtoproc = $strtoproc -replace "&lt;" , "<"
	$strtoproc = $strtoproc -replace "&gt;" , ">"
	$strtoproc = $strtoproc -replace "&gt;" , ">"
	$strtoproc = $strtoproc -replace "&tilde;" , "˜"
	$strtoproc = $strtoproc -replace "&circ;" , "^"
	$strtoproc = $strtoproc -replace "&ndash;" , "–"
	$strtoproc = $strtoproc -replace "&mdash;" , "—"
	$strtoproc = $strtoproc -replace "&permil;" , "‰"
	$strtoproc = $strtoproc.trim()
	return $strtoproc
}

function resizeimg {
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		[string]$rwidth, 
		
		[Parameter(Mandatory=$True,Position=2)]
		[string]$rheight,
		
		[Parameter(Mandatory=$True,Position=3)]
		[System.Drawing.Bitmap]$bmpFile
	)
	$target_height = [double] $rheight
	$target_width = [double] $rwidth
	# keep aspect ratio
	if($bmpFile.Width/$bmpFile.Height -gt $target_width/$target_height) {
		$target_height=$target_width*$bmpFile.Height/$bmpFile.Width
		$rheight = [string] $target_height
	}
	if($bmpFile.Width/$bmpFile.Height -lt $target_width/$target_height) {
		$target_width=$target_height*$bmpFile.Width/$bmpFile.Height
		$rwidth = [string] $target_width
	}
	# create resized bitmap
	$bmpResized = New-Object System.Drawing.Bitmap([int] ($rwidth), [int] ($rheight))
	$graph = [System.Drawing.Graphics]::FromImage($bmpResized)
	$graph.Clear([System.Drawing.Color]::White)
	$graph.DrawImage($bmpFile,0, 0, $rwidth, $rheight)
	return $bmpResized
}

function Parse-IniFile ($file) {
  $ini = @{}

 # Create a default section if none exist in the file. Like a java prop file.
 $section = "NO_SECTION"
 $ini[$section] = @{}

  switch -regex -file $file {
    "^\[(.+)\]$" {
      $section = $matches[1].Trim()
      $ini[$section] = @{}
    }
    "^\s*([^#].+?)\s*=\s*(.*)" {
      $name,$value = $matches[1..2]
      # skip comments that start with semicolon:
      if (!($name.StartsWith(";"))) {
        $ini[$section][$name] = $value.Trim()
      }
    }
  }
  $ini
}

function loadandset {
	if (Test-Path ".\bang.ini") {
		$ini = Parse-IniFile ".\bang.ini"
		$hostinfo = $ini["defaults"]["hostinfo"]
		$dwnldsrc = $ini["defaults"]["source"]
	}
	
	if ($dwnldsrc -eq "heise") {
		$contents = goget "http://www.heise.de/foto/galerie/"
	} else {
		$contents = goget "http://www.bing.com/"
	}
	
	Write-Verbose "Parse target website"
	if ($dwnldsrc -eq "heise") {
		$contents = cutidx $contents "figure class=""main_stage"""
		$contents = cutidx $contents "<a href="""
		$dh = $contents.indexof("/"">")
		$imgnxt = $contents.substring(9,$dh-8)
		$imgnxt = procstr $imgnxt
		$imgnxt = "http://www.heise.de" + $imgnxt
		$contents = goget($imgnxt)
		$contents = cutidx $contents "<div class=""main_stage"">"
		$contents = cutidx $contents "<img src="""
		$gh = $contents.indexof(".jpg")
		$imgurl = $contents.substring(9,$gh-5)
		$imgurl = $imgurl -replace "570" , "1280"
		$imgurl = procstr $imgurl
	} else {
		$b = $contents.indexof("g_img={url:")
		$c = $contents.substring($b+12).indexof(".jpg")
		$imgurl = $contents.substring($b+12,$c+4)
		$imgurl = "http://www.bing.com" + $imgurl
		$imgurl = procstr $imgurl
	}
	
	Write-Verbose "Download image."
	try {
		[BYTE[]] $imgarray = goget $imgurl "yes"
	} catch [Exception] {
		Write-Verbose "Error downloading img data."
		Write-Verbose "Exit."
		Exit 1
	}
	$memoryStream = New-Object System.IO.MemoryStream(,$imgarray)
	
	if ($dwnldsrc -ne "heise") {
		$contentstemp = cutidx $contents "hpcNext""></div></div></a><a href"
		if($contents.compareto($contentstemp) -eq 0) {
			$contents = cutidx $contents "hpcNext""></div></div></a><a"
		} else {
			$contents = $contentstemp
		}
	}
	$contentstemp = cutidx $contents "={""copyright"":"""
	if($contentstemp -ne $contents -and $dwnldsrc -ne "heise") {
		$Title = getttl $contents "={""copyright"":"""
	} else {
		$Title = getttl $contents "alt="""
	}
	$Title = proctitle $Title
	
	Write-Verbose "Load System.Drawing."
	[Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
	[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	
	Write-Verbose "Source image from memorystream."
	$srcImg = [System.Drawing.Bitmap][System.Drawing.Image]::FromStream($memoryStream)
	$memoryStream.Dispose()
	
	$rheight=$srcImg.Height
	$rwidth=$srcImg.Width
	# Resize image if necessary
	$CurrentRes = (gwmi Win32_VideoController).VideoModeDescription;
	if($CurrentRes.GetType().IsArray) {
		$CurrentRes = [String] $CurrentRes
	}
	$CurrentRes_split = $CurrentRes.Split("x")
	$rwidth=$CurrentRes_split[0]
	$rwidth=$rwidth.trim()
	$rheight=$CurrentRes_split[1]
	$rheight=$rheight.trim()
	
	Write-Verbose "Resize image."
	$srcImg = resizeimg $rwidth $rheight $srcImg
	
	# rotate the image 
	$srcImg.rotateflip("Rotate270FlipNone")
	
	Write-Verbose "Create a bitmap object."
	$bmpFile = New-Object System.Drawing.Bitmap(([int]($srcImg.width)),([int]($srcImg.height)))
	
	Write-Verbose "Intialize graphics object."
	$Image = [System.Drawing.Graphics]::FromImage($bmpFile)
	$Image.SmoothingMode = "AntiAlias"
	
	$Rectangle = New-Object Drawing.Rectangle 0, 0, $srcImg.Width, $srcImg.Height
	$Image.DrawImage($srcImg, $Rectangle, 0, 0, $srcImg.Width, $srcImg.Height, ([Drawing.GraphicsUnit]::Pixel))
	
	$Font = New-Object System.Drawing.Font("Arial", 11)
	$Brush = New-Object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
	$sFormat = New-Object System.Drawing.Stringformat
	$sFormat.Alignment = [System.Drawing.StringAlignment]::Center
	$ts =  $Image.MeasureString($Title,$Font)
	$dist = 7
	if ($ts.Width -ge $srcImg.Width) {
		$Font = New-Object System.Drawing.Font("Arial", 8)
		$dist = 5
	}
	
	# draw opaque rectangle
	$ts =  $Image.MeasureString($Title, $Font)
	$Brush = new-object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(128, 0, 0, 0))
	$Image.FillRectangle($Brush,[System.Math]::Round($srcImg.Width/2-$ts.Width*1.1/2), $dist, [System.Math]::Round($ts.Width*1.1), [System.Math]::Round($ts.Height))
	$offset = [System.Math]::Round($srcImg.Width/2+$ts.Width*1.1/2)
	
	# draw string
	$Brush = New-Object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
	$Image.DrawString($Title, $Font, $Brush, $srcImg.Width/2, $dist,$sFormat)
	
	# begin display host info
	if ($hostinfo -ne "no") {
		$bmpFile.rotateflip("Rotate180FlipNone")
		$sFormatNew=New-Object System.Drawing.Stringformat("DirectionVertical")
		
		$hostname = $env:COMPUTERNAME
		$ipaddress = (gwmi Win32_NetworkAdapterConfiguration | ? { $_.IPAddress -ne $null }).ipaddress
		if(!$ipaddress) {
			$ipaddress = (gwmi Win32_NetworkAdapterConfiguration | ? { $_.IPAddress -ne $null })[0].ipaddress
		}
	    if($ipaddress.GetType().IsArray) {
		$ipaddress = $ipaddress[0]
	    }
		$username = $env:USERNAME
	
		$ts = $Image.MeasureString($hostname,$Font)
		$sw = [System.Math]::Round($ts.Width)
		$voffset = [System.Math]::Round($offset-$dist-$ts.Height)
		if($srcImg.Height -ge 966) {
			$hoffset = [System.Math]::Round(5/6*$srcImg.Height)
		} else {
			$hoffset = [System.Math]::Round($srcImg.Height) - 161
		}
	
		$ts =  $Image.MeasureString($ipaddress,$Font)
		if($ts.Width -ge $sw) {
			$sw = $ts.Width
		}
	
		$ivoffset = [System.Math]::Round($voffset-$dist-$ts.Height)
		
		$ts= $Image.MeasureString($username, $Font)
		if($ts.Width -ge $sw) {
			$sw = $ts.Width
		}
		$uvoffset = [System.Math]::Round($voffset-2*$dist-2*$ts.Height)
	
		# upper left corner of image = max
		if([System.Math]::Round($uvoffset+3*$dist+3*$ts.Height) -ge $srcImg.Width) {
			$uvoffset = [System.Math]::Round($srcImg.Width-3*$dist-3*$ts.Height)
			$ivoffset = [System.Math]::Round($uvoffset+$dist+$ts.Height)
			$voffset = [System.Math]::Round($ivoffset+$dist+$ts.Height)
		}
		
		# fill rectangle
		$Brush = New-Object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(128, 0, 0, 0))
		$Image.FillRectangle($Brush,$uvoffset, $hoffset-$dist, [System.Math]::Round(3*$dist+3*$ts.Height), [System.Math]::Round($sw+3*$dist))
		# draw strings
		$Brush = new-Object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
		$Image.DrawString($hostname, $Font, $Brush, $voffset, $hoffset, $sFormatNew)
		$Image.DrawString($ipaddress, $Font, $Brush, $ivoffset, $hoffset, $sFormatNew)
		$Image.DrawString($username, $Font, $Brush, $uvoffset, $hoffset, $sFormatNew)
		$bmpFile.rotateflip("Rotate270FlipNone")
	} else {
		# turn image back
		$bmpFile.rotateflip("Rotate90FlipNone")
	}
	
	# write image
	Write-Verbose "Save and close files."
	$path = [IO.Path]::GetFullPath("bingimagean.bmp")
	$bmpFile.save($path, [System.Drawing.Imaging.ImageFormat]::Bmp)
	$Image.Dispose()
	$bmpFile.Dispose()
	$srcImg.Dispose()
	
	# begin setwallpaper
	Write-Verbose "Write registry."
	$registryPath = "HKCU:\Control Panel\Desktop"
	
	if(!(Test-Path $registryPath)) {
	    New-Item -Path $registryPath -Force | Out-Null
	}
	
	$nm = "WallpaperStyle"
	$value = "0"
	New-ItemProperty -Path $registryPath -Name $nm -Value $value -PropertyType STRING -Force | Out-Null
	$nm = "TileWallpaper"
	$value = "0"
	New-ItemProperty -Path $registryPath -Name $nm -Value $value -PropertyType STRING -Force | Out-Null
	
	Write-Verbose "Refresh explorer."
	[Wallpaper.Setter]::SetWallpaper($path)
}

loadandset
$time_last_run = Get-Date
Do {
	$time_now = Get-Date
	$time_diff = $time_now - $time_last_run
	if($time_diff.hours -gt 12) {
		loadandset
		$time_last_run = Get-Date
	}
	start-sleep -s 60	
} while($true)

Exit 0
