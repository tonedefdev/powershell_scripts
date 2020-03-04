. "C:\users\admin.aowens\desktop\PowerShell Scripts\function_Update-PandoraFMSConfiguration.ps1"
#Import-Module ActiveDirectory
$Computers = @("NY-DC03","SD-DC03")

foreach ($Computer in $Computers)
{
    $PandoraPath = Test-Path -Path "\\$($Computer)\C$\Program Files\pandora_agent" -ea SilentlyContinue
    if ($PandoraPath)
    {
        Update-PandoraFMSConfiguration -Computer $Computer -Selections @("DomainController") -AddModule $true
    } else {
        Write-Host "Skipping '$($Computer)' as the PandoraFMS agent was not found" -ForegroundColor Cyan
    }
}