$signature = @"
[DllImport("user32.dll")]
public static extern bool SystemParametersInfo(int uAction, int uParam, ref int lpvParam, int flags );
"@

$systemParamInfo = Add-Type -memberDefinition  $signature -Name ScreenSaver -passThru
 
Function Get-ScreenSaverTimeout
{
  [Int32]$value = 0
  $systemParamInfo::SystemParametersInfo(14, 0, [REF]$value, 0)
  $($value/60)
}
 
Function Set-ScreenSaverTimeout
{
  Param ([Int32]$value)
  $seconds = $value * 60
  [Int32]$nullVar = 0
  $systemParamInfo::SystemParametersInfo(15, $seconds, [REF]$nullVar, 2)
}

Function sw
{
$imgpath = Get-Content -Path ".\pwd.txt" | Out-String
$UpdateIniFile = 0x01
$SendWinIniChange = 0x02
# $systemParamInfo::SystemParametersInfo(20, 0, $imgpath, $UpdateIniFile | $SendWinIniChange )
}

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
            
      public static void SetWallpaper ( string path, Wallpaper.Style style ) {
      	RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
        switch( style )
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
        SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
      }
   }
}
"@

# [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
# [System.Windows.Forms.MessageBox]::Show($flup, "Status")
$imgpath = Get-Content -Path ".\pwd.txt" | Out-String
$path = [IO.Path]::GetFullPath( $imgpath )
[Wallpaper.Setter]::SetWallpaper($path, 1 )
# [Wallpaper.Setter]::SetWallpaper(".\bingimagean.bmp", 2 )