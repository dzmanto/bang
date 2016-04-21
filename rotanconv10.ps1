[CmdletBinding()]

Param(
  [Parameter(Mandatory=$False,Position=1)]
  [string]$imgurl,
  
  [Parameter(Mandatory=$False,Position=2)]
  [string]$Title
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

Write-Verbose "Load http://www.bing.com"
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
$contents = $wc.DownloadString("http://www.bing.com/")
# a network connection may not be available yet. Sleep for 7 seconds.
if($contents.length -eq 0) {
	$count = $count + 1
	Write-Verbose "www.bing.com returned zero length."
	Write-Verbose "Retry in 7 seconds."	
	sleep -seconds 7
}
} while($contents.length -eq 0 -and $count -lt 100)

if($contents.length -eq 0) {
	Write-Verbose "www.bing.com returned zero length."
	Write-Verbose "Exit."
	Exit 1
}

Write-Verbose "Parse http://www.bing.com"
$b = $contents.indexof("g_img={url:'")
$c = $contents.substring($b+12).indexof(".jpg")
$imgurl = $contents.substring($b+12,$c+4)
$imgurl = "http://www.bing.com" + $imgurl
$d = $contents.indexof("hpcNext""></div></div></a><a href")
$contents = $contents.substring($d)
$d = $contents.indexof("alt=""")
$contents = $contents.substring($d)
$e = $contents.substring(5).indexof("""")
$Title = $contents.substring(5,$e)

Write-Verbose "Download image"
[BYTE[]] $imgarray=$wc.DownloadData($imgurl)
$wc.Dispose()
$memoryStream = New-Object System.IO.MemoryStream(,$imgarray)

# Add-Type -AssemblyName PresentationFramework, System.Windows.Forms
# Create a streaming image by streaming the base64 string to a bitmap streamsource
# $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
# $bitmap.BeginInit()
# $bitmap.StreamSource = [System.IO.MemoryStream]$imgarray
# $bitmap.EndInit()
# $bitmap.Freeze()

Write-Verbose "Load System.Drawing"
[Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

Write-Verbose "Get the image from $sourcePath"
# $srcImg = New-Object [System.Drawing.Image]::FromStream($memoryStream, $true)
# $srcImg = [System.Drawing.Bitmap][System.Drawing.Image]::FromStream($bitmap.StreamSource)
$srcImg = [System.Drawing.Bitmap][System.Drawing.Image]::FromStream($memoryStream)
$memoryStream.Dispose()

# rotate the image 
$srcImg.rotateflip("Rotate270FlipNone")

Write-Verbose "Create a bitmap as $destPath"
$bmpFile = New-Object System.Drawing.Bitmap([int]($srcImg.width)),([int]($srcImg.height))

Write-Verbose "Intialize Graphics"
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
If ($ts.Width -ge $srcImg.Width) {
	$Font = New-Object System.Drawing.Font("Arial", 8)
	$dist = 5
}

# draw opaque rectangle
$ts =  $Image.MeasureString($Title,$Font)
$Brush = new-object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(128, 0, 0, 0))
$Image.FillRectangle($Brush,[System.Math]::Round($srcImg.Width/2-$ts.Width*1.1/2), $dist, [System.Math]::Round($ts.Width*1.1), [System.Math]::Round($ts.Height))
$offset = [System.Math]::Round($srcImg.Width/2+$ts.Width*1.1/2)

# draw string
$Brush = New-Object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$Image.DrawString($Title, $Font, $Brush, $srcImg.Width/2, $dist,$sFormat)

# begin display host info
$strFileName = ".\hostinfo"
If (Test-Path $strFileName) {
	$bmpFile.rotateflip("Rotate180FlipNone")
	$sFormatNew=New-Object System.Drawing.Stringformat("DirectionVertical")
        
	$hostname = $env:COMPUTERNAME
	$ipaddress = (gwmi Win32_NetworkAdapterConfiguration | ? { $_.IPAddress -ne $null }).ipaddress
	if(!$ipaddress) {
		$ipaddress = (gwmi Win32_NetworkAdapterConfiguration | ? { $_.IPAddress -ne $null })[0].ipaddress
	}
	$username = $env:USERNAME

	$ts = $Image.MeasureString($hostname,$Font)
	$sw = [System.Math]::Round($ts.Width)
	$voffset = [System.Math]::Round($offset-$dist-$ts.Height)
	$hoffset = [System.Math]::Round(5/6*$srcImg.Height)

	$ts =  $Image.MeasureString($ipaddress,$Font)
	If($ts.Width -ge $sw) {
		$sw = $ts.Width
	}

	$ivoffset = [System.Math]::Round($voffset-$dist-$ts.Height)
	
	$ts= $Image.MeasureString($username,$Font)
	If($ts.Width -ge $sw) {
		$sw = $ts.Width
	}
	$uvoffset = [System.Math]::Round($voffset-2*$dist-2*$ts.Height)

	# upper left corner of image = max
	If([System.Math]::Round($uvoffset+3*$dist+3*$ts.Height) -ge $srcImg.Width) {
		$uvoffset = [System.Math]::Round($srcImg.Width-3*$dist-3*$ts.Height)
		$ivoffset = [System.Math]::Round($uvoffset+$dist+$ts.Height)
		$voffset = [System.Math]::Round($ivoffset+$dist+$ts.Height)
	}
	
	# fill rectangle
	$Brush = New-Object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(128, 0, 0, 0))
	$Image.FillRectangle($Brush,$uvoffset, $hoffset-$dist, [System.Math]::Round(3*$dist+3*$ts.Height), [System.Math]::Round($sw+3*$dist))
	# draw strings
	$Brush = new-Object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
	$Image.DrawString($hostname, $Font, $Brush, $voffset, $hoffset,$sFormatNew)
	$Image.DrawString($ipaddress, $Font, $Brush, $ivoffset, $hoffset,$sFormatNew)
	$Image.DrawString($username, $Font, $Brush, $uvoffset, $hoffset,$sFormatNew)
	$bmpFile.rotateflip("Rotate270FlipNone")
} Else {
	# turn image back
	$bmpFile.rotateflip("Rotate90FlipNone")
}

# write image
Write-Verbose "Save and close the files"
$destPath = ".\bingimagean.bmp"
$bmpFile.save($destPath, [System.Drawing.Imaging.ImageFormat]::Bmp)
$Image.Dispose()
$bmpFile.Dispose()
$srcImg.Dispose()

# begin setwallpaper
Write-Verbose "Write registy"
$value = "1"
$filename = "bingimagean.bmp"
$path = [IO.Path]::GetFullPath($filename)
$registryPath = "HKCU:\Control Panel\Desktop"

If(!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
    $nm = "WallpaperStyle"
    New-ItemProperty -Path $registryPath -Name $nm -Value $value -PropertyType DWORD -Force | Out-Null
    $nm = "TileWallpaper"
    New-ItemProperty -Path $registryPath -Name $nm -Value $value -PropertyType DWORD -Force | Out-Null
} Else {
    $nm = "WallpaperStyle"
    New-ItemProperty -Path $registryPath -Name $nm -Value $value -PropertyType DWORD -Force | Out-Null
    $nm = "TileWallpaper"
    New-ItemProperty -Path $registryPath -Name $nm -Value $value -PropertyType DWORD -Force | Out-Null
}
Write-Verbose "Refresh explorer"
[Wallpaper.Setter]::SetWallpaper($path)
