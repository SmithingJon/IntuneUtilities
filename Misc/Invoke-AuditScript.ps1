
# Show input box popup and return the value entered by the user.
function Read-InputBoxDialog([string]$Message, [string]$WindowTitle, [string]$DefaultText)
{
    Add-Type -AssemblyName Microsoft.VisualBasic
    return [Microsoft.VisualBasic.Interaction]::InputBox($Message, $WindowTitle, $DefaultText)
}

    Install-module AzureAD -Force
    Import-module AzureAD -force
    Connect-AzureAD

$groups = Get-AzureADGroup -SearchString 'Intune' -All $true | Where-Object { $_.DisplayName.EndsWith('Compute') } | Select-Object ObjectID,DisplayName
$array = @(foreach ($name in $groups) {
    $name.DisplayName
})

$chosengroup = $array | Out-Gridview -title "Please select a group to put device in" -PassThru
$chosengroup

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Computer Name'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,120)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)
$font = New-Object System.Drawing.Font("Segoe UI",13,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel)
$form.Font = $font

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,120)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please enter a computer name:'
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox)

$form.Topmost = $true

$form.Add_Shown({$textBox.Select()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $textBox.Text
    $x
}
else
{
$assettag = (Get-WmiObject -Class Win32_SystemEnclosure).SMBIOSAssetTag
$x = "TNU-$assetag"
}

$newcomputername = $x


$groupid = Get-AzureADGroup -SearchString "$chosengroup" | Select-Object ObjectID
& "C:\Program Files\WindowsPowerShell\Scripts\Get-WindowsAutoPilotInfo.ps1" -Online -AddToGroup "$chosengroup" -Assign

$serial = (Get-WmiObject Win32_BIOS).SerialNumber
Write-Verbose -Verbose "Serial Number is $serial"
Get-AutopilotDevice -serial $serial | Select-Object id | Set-AutopilotDevice -displayName $newcomputername

$cpumodel =  (Get-WmiObject win32_processor).name
$wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
$answer = $wshell.Popup("CPU Model is $cpumodel.`nDo you want to install the Intel iRST Driver?`nIt is only recommended for Mobile 8th gen and newer Intel Core Processors, and Desktop 10th Gen and newer Intel Core Processors.",0,"Install iRST Driver?",32+4)

$answer
if ( $answer -eq 6 ) {
    Start-BitsTransfer -Source 'https://downloadmirror.intel.com/655256/SetupRST.exe' -Destination "$env:TEMP\SetupRST.exe"
    Start-Process -FilePath "$env:TEMP\SetupRST.exe" -ArgumentList '-Silent -accepteula' -Wait
}
else {
    pause
}
