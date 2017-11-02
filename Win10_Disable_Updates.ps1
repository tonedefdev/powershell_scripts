Add-Type -AssemblyName PresentationFramework
$host.ui.rawui.WindowTitle = "Win10 Disable Updates Script"

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

$TeamViewerHost = {

    cmd.exe /C "C:\Installs\TeamViewer12\TeamViewer_Host_Setup.exe /S /norestart"

}

$TeamViewerAssignment = {

    cmd.exe /C "C:\Installs\TeamViewer12\TeamViewer_Assignment.bat"

}

$WindowsUpdatePath ="HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$LocalSecurityToken = "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$DisableWinUpdateAccess = "HKLM:SYSTEM\Internet Communication Management\Internet Communication"
$SpecialAccounts = "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
$AutoUpdate = "HKLM:Software\Policies\Microsoft\Windows\WindowsUpdate\AU"
$WSUS = "http://winupdate.nvanet.com:8530"


if (Test-Path -Path $WindowsUpdatePath) {

    Remove-Item -Path $WindowsUpdatePath -Recurse

}

New-Item -Path $WindowsUpdatePath -Force | Out-Null
New-Item -Path $AutoUpdate -Force | Out-Null

if (!(Get-Item -Path $DisableWinUpdateAccess -ErrorAction SilentlyContinue)) {

    New-Item -Path $DisableWinUpdateAccess -Force | Out-Null

}

if (Test-Path -Path $WindowsUpdatePath) {

    $Win10ScriptBlock = {
    param(
        $AutoUpdate,
        $WindowsUpdatePath,
        $WSUS,
        $LocalSecurityToken,
        $SpecialAccounts      
    )

        Set-ItemProperty -Path $AutoUpdate -Name NoAutoUpdate -Value 1 -Verbose -Force
        Set-ItemProperty -Path $WindowsUpdatePath -Name WUServer -Value $WSUS -Verbose -Force
        Set-ItemProperty -Path $WindowsUpdatePath -Name WUStatusServer -Value $WSUS -Verbose -Force
        Set-ItemProperty -Path $AutoUpdate -Name UseWUServer -Value 1 -Verbose -Force
        Set-ItemProperty -Path $WindowsUpdatePath -Name DoNotConnectToWindowsUpdateInternetLocations -Value 1 -Verbose -Force
        Set-ItemProperty -Path $WindowsUpdatePath -Name DisableWindowsUpdateAccess -Value 1 -Verbose -Force

        Set-ItemProperty -Path $LocalSecurityToken -Name LocalAccountTokenFilterPolicy -Value 1 -Verbose -Force
    
        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -Verbose

        $InterfaceAlias = Get-NetConnectionProfile | Select-Object -First 1
    
        Set-NetConnectionProfile -InterfaceAlias $InterfaceAlias.InterfaceAlias -NetworkCategory Private -Verbose

        Enable-PSRemoting -Force -SkipNetworkProfileCheck

        cmd.exe /C "gpupdate /force"

        cmd.exe /C "net user nvaadmin Nva!@#$% /add"

        cmd.exe /C "net localgroup administrators nvaadmin /add"

        Set-ItemProperty -Path $SpecialAccounts -Name nvaadmin -Value 0 -Verbose

        Set-Service -Name wuauserv -StartupType Manual -Verbose

    }

    Start-Job -Name Win10Update -ScriptBlock $Win10Scriptblock -ArgumentList $AutoUpdate,$WindowsUpdatePath,$WSUS,$LocalSecurityToken,$SpecialAccounts | Out-Null

        Write-Host "Configuring Win10 Updates [ " -NoNewLine
        
        while ((Get-Job -Name Win10Update | Select-Object -ExpandProperty State) -eq "Running") {
        
        Start-Sleep -Seconds 1
        Write-Host "#" -NoNewLine 
                
        }

        Write-Host " ]" -NoNewline

        "`n"

} else {
    
    Clear-Host
    Write-Host "Error creating registry keys. Ensure script was run with elevated privileges" -ForegroundColor Red
    $Exit = Read-Host "Press any key to exit..."

    if ($Exit -ne "") {Exit} 

}

if (!(Test-Path -Path "C:\Program Files (x86)\TeamViewer")) {

    Copy-Item -Path "C:\Installs\Win10 Disable Update Scripts\TeamViewer12" -Destination "C:\Installs" -Recurse -Force

    Start-Job -Name TeamViewerHost -ScriptBlock $TeamViewerHost | Out-Null

    Write-Host "Installing Team Viewer 12 [ " -NoNewLine
        
    while ((Get-Job -Name TeamViewerHost | Select-Object -ExpandProperty State) -eq "Running") {
        
        Start-Sleep -Seconds 1
        Write-Host "#" -NoNewLine 
                
        }

        Write-Host " ]" -NoNewline

    "`n"

    Start-Job -Name TeamViewerAssign -ScriptBlock $TeamViewerAssignment | Out-Null

    Write-Host "Uploading Machine To Web Console [ " -NoNewLine

    while ((Get-Job -Name TeamViewerAssign | Select-Object -ExpandProperty State) -eq "Running") {
            
            Start-Sleep -Seconds 1
            Write-Host "#" -NoNewLine 
                    
            }
        
            Write-Host " ]" -NoNewline
        
        "`n"
    
}

Clear-Host

$GetNoUpdate = Get-Item -Path $AutoUpdate
$WSUSPointer = $GetNoUpdate.GetValue("UseWUServer")
$GetUpdate = Get-Item -Path $WindowsUpdatePath
$WindowsUpdate = $GetUpdate.GetValue("WUServer")
$WSUSStatus = $GetUpdate.GetValue("WUStatusServer")
$UpdateAccess = $GetUpdate.GetValue("DisableWindowsUpdateAccess")
$DoNotConnect = $GetUpdate.GetValue("DoNotConnectToWindowsUpdateInternetLocations")
$UpdateService = Get-Service -Name wuauserv
$SecurityToken = "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$GetToken = Get-Item -Path $SecurityToken
$Token = $GetToken.GetValue("LocalAccountTokenFilterPolicy")
$Firewall = Get-NetFirewallProfile
$ConnectionProfile = Get-NetConnectionProfile | Select-Object -First 1
$Admin = Get-WmiObject -Class Win32_UserAccount | ? {$_.Name -eq "nvaadmin"}
$GetAdmin = Get-Item -Path $SpecialAccounts
$SpecialAccount = $GetAdmin.GetValue("nvaadmin")

Check-System -Message "Windows WSUS Server " -Condition1 $WSUSPointer -Condition2 "1"

Check-System -Message "Windows WSUS Status Server " -Condition1 $WSUSStatus -Condition2 $WSUS

Check-System -Message "Pointed to WSUS Server " -Condition1 $WindowsUpdate -Condition2 $WSUS

Check-System -Message "Disabled Windows Update Access " -Condition1 $UpdateAccess -Condition2 "1"

Check-System -Message "Windows Update Connection Disabled " -Condition1 $DoNotConnect -Condition2 "1"

Check-System -Message "Windows Update Service Set to Manual " -Condition1 $UpdateService.StartType -Condition2 "Manual"

Check-System -Message "PsExec Registry Key " -Condition1 $Token -Condition2 "1"

foreach ($Profile in $Firewall) {
    $Name = $Profile.Name 
    Check-System -Message "Windows Firewall Disabled - $Name " -Condition1 $Profile.Enabled -Condition2 $False
}

Check-System -Message "Network Connection Profile Set to Private " -Condition1 $ConnectionProfile.NetworkCategory -Condition2 "Private"

Check-System -Message "User account 'nvaadmin' created " -Condition1 $Admin.Name -Condition2 "nvaadmin"

Check-System -Message "User account 'nvaadmin hidden " -Condition1 $SpecialAccount -Condition2 "0"

Start-Job -Name PSRemoting -ScriptBlock {[bool](Test-WSman -ComputerName $env:COMPUTERNAME)} | Out-Null
                    
Write-Host "Testing PowerShell Remoting [ " -NoNewLine
                    
while ((Get-Job -Name PSRemoting | Select-Object -ExpandProperty State) -eq "Running") {
                    
Start-Sleep -Seconds 1
Write-Host "#" -NoNewLine 
                    
}

Write-Host " ]" -NoNewline

"`n"

Check-System -Message "PowerShell Remoting Enabled " -Condition1 (Receive-Job -Name PSRemoting) -Condition2 $True

Remove-Job -Name PSRemoting,TeamViewerAssign,TeamViewerHost,Win10Update | Out-Null

$Exit = [System.Windows.MessageBox]::Show("If all checks came back 'OK' - press 'OK' to commit changes to Drive Vaccine baseline and restart the computer. Otherwise, hit 'Cancel' if some items failed.","Win10 Disable Updates Finished","OKCancel","Information")

switch ($Exit) {

    'OK' { cmd.exe /C "ShdCmd.exe /Baseline /update /u administrator /p nva100" }

    'Cancel' { Exit }
    
}