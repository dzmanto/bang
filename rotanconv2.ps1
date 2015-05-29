# Orignal code from http://www.ravichaganti.com/blog/?p=1012
[CmdletBinding()]

Param(
  [Parameter(Mandatory=$False,Position=1)]
  [string]$Title
)

# foreach ($key in $MyInvocation.BoundParameters.keys)
# {
#    $value = (get-variable $key).Value 
#    write-host "$key -> $value"
# }


# Title = Get-Content -Path ".\desc.txt" | Out-String

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
