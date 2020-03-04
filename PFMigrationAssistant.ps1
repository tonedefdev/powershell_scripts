Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
$to = "sysadmins@are.com"
$from = "PFMigrationAssistant@are.com"
$subject = "PF Migration Assistant Alert"
$check = $true
while ($check)
{
    $database = Get-MailboxDatabaseCopyStatus * | ? {$_.CopyQueueLength -gt 7500}
    if ($database)
    {
        $dateStamp = (Get-Date).ToShortDateString()
        $timeStamp = (Get-Date).ToShortTimeString()
        $batch = Get-MigrationBatch -Identity "PFMigration"
        $batch | Stop-MigrationBatch -Confirm:$false
        Write-Host "[$dateStamp $timeStamp] Stopping migration batch since copy queue length is above threshold" -ForegroundColor Red
        Send-MailMessage -From $from -To $to -Subject $subject -SmtpServer $env:COMPUTERNAME -Body "[$dateStamp $timeStamp] Stopping public folder migration batch since copy queue length target is above the threshold (7500)"
        $check = $false
    }
    else 
    {
        $dateStamp = (Get-Date).ToShortDateString()
        $timeStamp = (Get-Date).ToShortTimeString()
        Write-Host "[$dateStamp $timeStamp] Copy queue length not at 7500 threshold" -ForegroundColor Cyan
        Start-Sleep -Seconds 60
    }
}

$resume = $false
while (!($resume))
{
    $database = Get-MailboxDatabaseCopyStatus * | ? {$_.CopyQueueLength -lt 50}
    if ($database)
    {
        $dateStamp = (Get-Date).ToShortDateString()
        $timeStamp = (Get-Date).ToShortTimeString()
        $batch = Get-MigrationBatch -Identity "PFMigration"
        $batch | Start-MigrationBatch -Confirm:$false
        Write-Host "[$dateStamp $timeStamp] Resuming migration batch" -ForegroundColor Green
        Send-MailMessage -From $from -To $to -Subject $subject -SmtpServer $env:COMPUTERNAME -Body "[$dateStamp $timeStamp] Restarting public folder migration batch since copy queue length target is below the threshold (50)"
        $resume = $true
    }
    else 
    {
        $dateStamp = (Get-Date).ToShortDateString()
        $timeStamp = (Get-Date).ToShortTimeString()
        Write-Host "[$dateStamp $timeStamp] Waiting for copy queues to go below 50 before resuming" -ForegroundColor Cyan
        Start-Sleep -Seconds 60
    }
}

if ((-not $check -and $resume))
{
    $currentPath = Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path
    & "$currentPath\PFMigrationAssitant.ps1"
}