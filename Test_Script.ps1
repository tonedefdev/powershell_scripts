$Logfile = "C:\Users\$env:username\Desktop\error.log"

Function Write-Log
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

$testPath = Test-Path -Path "\\$env:COMPUTERNAME\c$"
if ($testPath -eq $true) {
        Write-Log $env:COMPUTERNAME "This path exists"
}