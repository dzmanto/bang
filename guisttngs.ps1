[CmdletBinding()]

Param(
)

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

if (Test-Path ".\bang.ini") {
	$ini = Parse-IniFile ".\bang.ini"
	$hostinfo = $ini["defaults"]["hostinfo"]
	$dwnldsrc = $ini["defaults"]["source"]
}

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
$objForm = New-Object System.Windows.Forms.Form
$objForm.Font = New-Object System.Drawing.Font("Arial", 11)

$objForm.Size = New-Object System.Drawing.Size(330,200)
$objForm.StartPosition = "CenterScreen"
$objForm.Text = "Bang Wallpaper Plus settings"

$objcheckBox = New-Object System.Windows.Forms.CheckBox
$objcheckBox.Location = New-Object System.Drawing.Size(10,25) 
$objcheckBox.Size = New-Object System.Drawing.Size(145,20)
$objcheckBox.CheckAlign = "MiddleRight";
$objcheckBox.Text = "display host info"
$objcheckBox.Checked = $true
if($hostinfo -eq "no") {
	$objcheckBox.Checked = $false
}
$objForm.Controls.Add($objcheckBox) 

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,80) 
$objLabel.Size = New-Object System.Drawing.Size(105,20) 
$objLabel.Text = "source"
$objForm.Controls.Add($objLabel) 

$objCombobox = New-Object System.Windows.Forms.Combobox 
$objCombobox.Location = New-Object System.Drawing.Size(145,80) 
$objCombobox.Size = New-Object System.Drawing.Size(160,20) 
[void] $objCombobox.Items.Add("bing")
[void] $objCombobox.Items.Add("heise (experimental)")
$objCombobox.SelectedIndex = 0
if($dwnldsrc -eq "heise") {
	$objCombobox.SelectedIndex = 1
}
$objCombobox.DropDownStyle = "DropDownList";
$objCombobox.Height = 70
$objForm.Controls.Add($objCombobox) 
$objForm.Topmost = $True

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(60,130)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Name = "OK"
$OKButton.DialogResult = "OK"
$OKButton.Add_Click(
{
$hostinfo = $objcheckBox.Checked
$dwnldsrc = $objCombobox.SelectedIndex
$objForm.Close()
})
$objForm.Controls.Add($OKButton) 

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(180,130)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Name = "Cancel"
$CancelButton.DialogResult = "Cancel"
$CancelButton.Add_Click({$objForm.Close(); $cancel = $true})
$objForm.Controls.Add($CancelButton) 

if (Test-Path ".\parrot.ico") {
	$objForm.Icon = New-Object System.Drawing.Icon(".\parrot.ico")
}

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()
if ($cancel) {return}

if($dwnldsrc -eq 0) {
	$dwnldsrc = "bing"
} else {
	$dwnldsrc = "heise"
}

if($hostinfo) {
	$hostinfo = "yes"
} else {
	$hostinfo = "no"
}

"[defaults]" | Out-File -FilePath ".\bang.ini" -Encoding ASCII
"hostinfo=$hostinfo" | Out-File -FilePath ".\bang.ini" -Encoding ASCII -Append
"source=$dwnldsrc" | Out-File -FilePath ".\bang.ini" -Encoding ASCII -Append

exit 0
