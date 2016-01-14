# Orignal code from http://www.ravichaganti.com/blog/?p=1012
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
            
      public static void SetWallpaper (string path, Wallpaper.Style style) {
      	RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
        switch(style)
        {
           case Style.Stretch :
              key.SetValue(@"WallpaperStyle", "2") ; 
              key.SetValue(@"TileWallpaper", "0") ;
              break;
           case Style.Center :
              key.SetValue(@"WallpaperStyle", "1") ; 
              key.SetValue(@"TileWallpaper", "0") ; 
              break;
           case Style.Tile :
              key.SetValue(@"WallpaperStyle", "1") ; 
              key.SetValue(@"TileWallpaper", "1") ;
              break;
           case Style.NoChange :
              break;
        }
        key.Close();
        SystemParametersInfo(SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange);
      }
   }
}
"@

$wc = New-Object Net.WebClient
$wc.DownloadFile($imgurl, ".\bingimage.jpg")

Write-Verbose "Load System.Drawing"
[Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

Write-Verbose "Get the image from $sourcePath"
$srcImg = new-object System.Drawing.Bitmap(".\bingimage.jpg")

# Rotate the image 
$srcImg.rotateflip("Rotate270FlipNone")

Write-Verbose "Create a bitmap as $destPath"
$bmpFile = new-object System.Drawing.Bitmap([int]($srcImg.width)),([int]($srcImg.height))

Write-Verbose "Intialize Graphics"
$Image = [System.Drawing.Graphics]::FromImage($bmpFile)
$Image.SmoothingMode = "AntiAlias"

$Rectangle = New-Object Drawing.Rectangle 0, 0, $srcImg.Width, $srcImg.Height
$Image.DrawImage($srcImg, $Rectangle, 0, 0, $srcImg.Width, $srcImg.Height, ([Drawing.GraphicsUnit]::Pixel))

$Title=$Title -replace "singletickstart", "‘"
$Title=$Title -replace "singletickstop", "’"
$Title=$Title -replace "tickcharacter", "'"
Write-Verbose "Draw title: $Title"
$Font = new-object System.Drawing.Font("Arial", 11)
$Brush = new-Object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$sFormat = new-object system.drawing.stringformat
$sFormat.Alignment = [system.drawing.StringAlignment]::Center
$ts =  $Image.MeasureString($Title,$Font)
$dist = 7
if ($ts.Width -ge $srcImg.Width) {
	$Font = new-object System.Drawing.Font("Arial", 8)
	$dist = 5
}
$Image.DrawString($Title, $Font, $Brush, $srcImg.Width/2, $dist,$sFormat)

# Draw opaque rectangle
$ts =  $Image.MeasureString($Title,$Font)
$Brush = new-object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(128, 0, 0, 0))
$Image.FillRectangle($Brush,$srcImg.Width/2-$ts.Width*1.1/2, $dist, $ts.Width*1.1, $ts.Height)

# Re-draw string
$Brush = new-Object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$Image.DrawString($Title, $Font, $Brush, $srcImg.Width/2, $dist,$sFormat)

# Turn image back
$bmpFile.rotateflip("Rotate90FlipNone")

# write image
Write-Verbose "Save and close the files"
$destPath = ".\bingimagean.bmp"
$bmpFile.save($destPath, [System.Drawing.Imaging.ImageFormat]::Bmp)
$bmpFile.Dispose()
$srcImg.Dispose()

# begin setwallpaper
$filename = "bingimagean.bmp"
$path = [IO.Path]::GetFullPath($filename)
[Wallpaper.Setter]::SetWallpaper($path, 1)

