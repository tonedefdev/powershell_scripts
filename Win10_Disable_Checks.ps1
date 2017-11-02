$host.ui.rawui.WindowTitle = "Win10 Disable Checks"
function Check-System {
[CmdletBinding()]
param(
    $Message,
    $Condition1,
    $Condition2 
)
if ($Condition1 -eq $Condition2) {

    Write-Host $Message -NoNewline 
    Write-Host "[ " -NoNewline
    Write-Host "OK" -NoNewline -ForegroundColor Green
    Write-Host " ]" -NoNewline
    "`n"

} else {

    Write-Host $Message -NoNewline 
    Write-Host "[ " -NoNewline
    Write-Host "FAIL" -NoNewline -ForegroundColor Red
    Write-Host " ]" -NoNewline    
    "`n"
}
}

$AUPath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"
$Update = Get-ChildItem -Path $AUPath
$WindowsUpdate = $Update.GetValue("NoAutoUpdate")
$SecurityToken = "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$GetToken = Get-Item -Path $SecurityToken
$Token = $GetToken.GetValue("LocalAccountTokenFilterPolicy")
$Firewall = Get-NetFirewallProfile
$ConnctionProfile = Get-NetConnectionProfile -InterfaceAlias "Ethernet"

Check-System -Message "Windows Updates Disabled " -Condition1 $WindowsUpdate -Condition2 "1"

Check-System -Message "PsExec Registry Key " -Condition1 $Token -Condition2 "1"

foreach ($Profile in $Firewall) {
    $Name = $Profile.Name 
    Check-System -Message "Windows Firewall Disabled - $Name " -Condition1 $Profile.Enabled -Condition2 $False
}

Check-System -Message "Network Connection Profile Set to Private " -Condition1 $ConnctionProfile.NetworkCategory -Condition2 "Private"

Start-Job -Name PSRemoting -ScriptBlock {[bool](Test-WSman -ComputerName $env:COMPUTERNAME)} | Out-Null
                    
Write-Host "Testing PowerShell Remoting [ " -NoNewLine
                    
while ((Get-Job -Name PSRemoting | Select-Object -ExpandProperty State) -eq "Running") {
                    
Start-Sleep -Seconds 1
Write-Host "#" -NoNewLine 
                    
}

Write-Host " ]" -NoNewline

"`n"

Check-System -Message "PowerShell Remoting Enabled " -Condition1 (Receive-Job -Name PSRemoting) -Condition2 $True

Remove-Job -Name PSRemoting | Out-Null

Write-Host "If all checks are OK, delete all the scripts, open Drive Vaccine, set the current image as the new baseline image, and you're set!" -ForegroundColor Cyan

"`n"

Read-Host "Press any key to end script"
