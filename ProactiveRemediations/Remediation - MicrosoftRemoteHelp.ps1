<#  Remediation-MicrosoftRemoteHelp

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

    This Script will install the latest version of remote help from aka.ms/downloadremotehelp.
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
#region Title
Write-DarkGrayLine
Write-SectionHeader -Message "Remediation - Microsoft Remote Help"
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
#region Installer Logic
Write-SectionHeader "Starting Installation..."
Start-Process -FilePath $ENV:TEMP\$tempFolder\$installer -ArgumentList '/quiet acceptTerms=1' -Wait
Write-DarkGrayHost "Cleaning up..."
Remove-Item -Path $ENV:TEMP\$tempFolder\$installer -ErrorAction SilentlyContinue
Remove-Item -Path $ENV:TEMP\$tempFolder\ -ErrorAction SilentlyContinue
Write-SectionSuccess