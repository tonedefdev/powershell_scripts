$host.ui.rawui.WindowTitle = "Remote Spooler Cleanup"
$currentPath = Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path
Write-Host "This script only works with NVA.local domain joined servers!" -ForegroundColor Yellow
$Server = Read-Host "Enter the server address you want to connect to"

if((Test-Connection -Count 1 -ComputerName $Server -Quiet -ErrorAction SilentlyContinue) -eq $false) {

    Write-Host "Connection to $Server is unavailable. Check spelling, or network connection, and try again!" -ForegroundColor Red
    $Exit = Read-Host "Press any key to reload script, or press 'x' to exit"
        if ($Exit -eq "x") {Exit}
        if ($Exit -ne $null) {& $currentPath\Remote_Spooler_Cleanup.ps1}
}
 
if ((Test-Connection -Count 2 -ComputerName $Server -Quiet -ErrorAction SilentlyContinue) -eq $true) {
 
$SpoolerScript = "\\$Server\C$\Installs\PowerShell_Scripts\Spooler_Cleanup\Spooler_Cleanup.bat"
$ScriptSource = "\\10.252.70.3\Users\Public\Downloads\PowerShell_Scripts\Spooler_Cleanup"
$Destination = "\\$Server\C$\Installs\PowerShell_Scripts"

if ((Test-Path -Path $Destination -PathType Container) -eq $false) {
    
    New-Item -Path $Destination -ItemType Directory -Force | Out-Null

}

if ((Test-Path -Path $SpoolerScript -PathType Leaf) -eq $false ) {
    
    Copy-Item -Container $ScriptSource -Destination $Destination -Recurse -Force
    Invoke-Command -ComputerName $Server -ScriptBlock { & "C:\Installs\PowerShell_Scripts\Spooler_Cleanup\Spooler_Cleanup.ps1" } 

}

else {

    Invoke-Command -ComputerName $Server -ScriptBlock { & "C:\Installs\PowerShell_Scripts\Spooler_Cleanup\Spooler_Cleanup.ps1" } 
}
}