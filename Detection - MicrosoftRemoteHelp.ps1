<#  Detection-MicrosoftRemoteHelp

        MIT License

        Copyright (c) 2022 SmithingJon Jonathan W. Smith

    Helper functions taken from OSDCloud.ps1, copyright David Segura, MIT License.

        MIT License

        Copyright (c) 2022 OSDeploy.com David Segura

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.

    This Script will detect if Microsoft Remote Help is not installed, or if the version installed is an out of date version; and exit with a return code of 1 if either condition is satisfied.
#>
#=================================================
#region Helper Functions
function Write-DarkGrayDate {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [System.String]
        $Message
    )
    if ($Message) {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) $Message"
    }
    else {
        Write-Host -ForegroundColor DarkGray "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) " -NoNewline
    }
}
function Write-DarkGrayHost {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [System.String]
        $Message
    )
    Write-Host -ForegroundColor DarkGray $Message
}
function Write-DarkGrayLine {
    [CmdletBinding()]
    param ()
    Write-Host -ForegroundColor DarkGray "========================================================================="
}
function Write-SectionHeader {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [System.String]
        $Message
    )
    Write-DarkGrayLine
    Write-DarkGrayDate
    Write-Host -ForegroundColor Cyan $Message
}
function Write-SectionSuccess {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [System.String]
        $Message = 'Success!'
    )
    Write-DarkGrayDate
    Write-Host -ForegroundColor Green $Message
}
#endregion
#region
Write-DarkGrayLine
Write-SectionHeader -Message "Detection - Microsoft Remote Help"
Write-DarkGrayLine
#endregion


#region Define and Create Temp folder
Write-SectionHeader -Message "Create Temp Folder"

$tempFolder = "MicrosoftRemoteHelp"

Write-DarkGrayHost -Message "Temp Folder: $tempfolder"
Write-DarkGrayHost -Message "Full Path: $ENV:TEMP\$tempFolder"
Write-DarkGrayHost -Message "Creating Temp Folder"

New-Item -Path $ENV:TEMP\$tempFolder -ItemType  Directory -Force
if (Test-Path  -Path "$ENV:TEMP\$tempFolder") {
    Write-SectionSuccess
}
else {
    Exit 2
}

#endregion
#=================================================
#region Download latest version of Remote Help to Temp directory
Write-SectionHeader -Message "Download latest version of Remote Help to Temp directory"
Write-DarkGrayHost -Message "Source: https://aka.ms/downloadremotehelp"
Write-DarkGrayHost -Message "Destination: $ENV:TEMP\$tempFolder"

$installer = "MicrosoftRemoteHelpInstaller_$((Get-Date).ToString('yyyy-MM-dd')).exe"

Write-DarkGrayHost -Message "File Name $installer"

Start-BitsTransfer -Source https://aka.ms/downloadremotehelp -Destination $ENV:TEMP\$tempfolder\$installer

Write-SectionSuccess
#endregion
#=================================================
#region Determine the latest available version of Remote Help
Write-SectionHeader -Message "Getting latest available version from downloaded installer"

$version = Get-Item -Path $ENV:TEMP\$tempFolder\$installer
$desiredversion = [version]$version.VersionInfo.FileVersion

Write-DarkGrayHost -Message "Latest Version: $desiredversion"
#endregion
#=================================================
#region Determine the installed version of Remote Help
Write-SectionHeader -Message "Determine the installed version of Remote Help"
$keys = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
Write-DarkGrayHost -Message "Searching in HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$registryProperties = $keys.PSChildName | ForEach-Object { 
    Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$_ | Where-Object Displayname -CEQ "Remote help"
    }
if ($registryProperties -and $registryProperties.DisplayName -ceq 'Remote help') {
    <# Action to perform if the condition is true #>
    Write-DarkGrayHost "Found Version $($registryProperties.DisplayVersion) of $($registryProperties.Displayname)"
    $deviceversion = [version]$registryProperties.DisplayVersion
    Write-SectionSuccess
} elseif ($registryProperties -and $registryProperties.DisplayName -notcontains 'Remote help')  {
    Write-DarkGrayLine
    Write-DarkGrayDate
    Write-Error -Message "Something very wrong has happened. Found results in Registry, but not matching the desired DisplayName. Results will output below."
    $registryProperties
    Write-DarkGrayLine
    Throw
} else {
    Write-DarkGrayHost "Unable to find Installation of Remote Help"
}
#endregion
#=================================================
#region exitcodeobject
Write-SectionHeader -Message "Starting Exit code Logic"
if ($deviceversion -eq $desiredversion) {
    Write-DarkGrayHost "Installed Version matches desired Version. Exiting. Program does not need to be installed or updated."
    Exit 0
}
if (!($registryProperties)) {
    Write-DarkGrayHost "Installation of Remote Help not found. Program needs to be installed."
    Exit 1
}
if (([version]$deviceversion -ne [version]$desiredversion)) {
    Write-DarkGrayHost "Installation Version does not match desired Version. Program needs to be updated."
    Exit 1
}
catch {
    Stop-Transcript
    Exit 2
}
#endregion