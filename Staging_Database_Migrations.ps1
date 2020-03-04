Clear-Host
$ErrorActionPreference = "Stop"
Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = "Choose the CSV file that contains users to be migrated"
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

function Check-System {
[CmdletBinding()]
param(
    $Message,
    $Condition1,
    $Condition2 
)
    if ($condition1 -eq $condition2) 
    {
    
        Write-Host $message -NoNewline 
        Write-Host " [ " -NoNewline
        Write-Host "OK" -NoNewline -ForegroundColor Green
        Write-Host " ]" -NoNewline
        "`n"
    
    } else {
    
        Write-Host $message -NoNewline 
        Write-Host " [ " -NoNewline
        Write-Host "FAIL" -NoNewline -ForegroundColor Red
        Write-Host " ]" -NoNewline    
        "`n"
    }
}

function Start-Migration
{
    $dbMountCheck = Get-MailboxDatabase "STAGING" -Status -ea SilentlyContinue
    if ($dbMountCheck.Mounted -eq $true)
    {
        $userCheck = Read-Host "Enter [Y] to start moving mailboxes to 'STAGING' database or enter [X] to cancel"
        switch ($userCheck)
        {
            'Y'
            {
                $csv = Get-FileName
                $users = Import-Csv -Path $csv
                Write-Host "Processing mailbox move requests to 'STAGING' database:" -ForegroundColor Yellow
                foreach ($user in $users)
                {
                    try 
                    {
                        Write-Host "`tMove request started for '$($user.Email)'"
                        New-MoveRequest -Identity $user.Email -TargetDatabase "STAGING" -SuspendWhenReadyToComplete:$true -BadItemLimit 500 -LargeItemLimit 500 -AcceptLargeDataLoss
                    }
                    catch 
                    {
                        throw $Error[0]
                        break
                    }
                    
                }
            }
    
            'X'
            {
                exit
            }
        }
    }
    else
    {
        throw "Staging database is not mounted. Unable to initiate migration steps."
    }

    $userCheck = Read-Host "All pre-migration steps have been completed. Press any key to exit"
}

Add-PSSnapin "Microsoft.Exchange.Management.PowerShell.SnapIn"
$stagingEDBPath = "\\ES-16EXCH01\Q`$\STAGING\"
$stagingLogPath = "\\ES-16EXCH01\R`$\STAGING\"
$stagingDB = Get-MailboxDatabase "STAGING" -ea SilentlyContinue
$dbCopyServers = @("ES-16EXCH02","TX-16EXCH01","TX-16EXCH02")

$mailboxCheck = $stagingDB | Get-Mailbox
if ($mailboxCheck)
{
    Write-Warning "The following mailboxes are still present on the 'STAGING' database:"
    foreach ($mailbox in $mailboxCheck)
    {
        Write-Host "`t$($mailbox.PrimarySmtpAddress)" -ForegroundColor Yellow -BackgroundColor Black
    }
    throw "All mailboxes must be moved from this database prior to running this script"
    break
}
else
{
    $userCheck = Read-Host "Enter [Y] to continue to recreate the 'STAGING' database, [C] to continue to user migration, or enter [X] to cancel"
    switch ($userCheck)
    {
        'Y'
        {
            Write-Host "Dismounting 'STAGING' database"
            $stagingDB | Set-MailboxDatabase -CircularLoggingEnabled:$false -ea SilentlyContinue
            $stagingDB | Dismount-Database -Confirm:$false -ea SilentlyContinue
            $dbMountCheck = Get-MailboxDatabase "STAGING" -Status -ea SilentlyContinue
            if ($dbMountCheck.Mounted -eq $true)
            {
                $limit = 5
                for ($i = 1; $i -le $limit; $i++)
                {
                    $dbMountCheck = Get-MailboxDatabase "STAGING" -Status
                    if ($dbMountCheck.Mounted -eq $true)
                    {
                        Write-Warning "Mailbox database was still mounted. Attempting to dismount it now. Attempt $i of 5"
                        $stagingDB | Dismount-Database -Confirm:$false
                        Write-Warning "Waiting five seconds before next check and attempt..."
                        Start-Sleep -Seconds 5
                    }
                    else
                    {
                        Write-Host "'STAGING' database was successfully dismounted."
                        break
                    }
                }
            }

            Write-Host "Removing 'STAGING' database copies"
            foreach ($server in $dbCopyServers)
            {
                Write-Host "`n`tWorking on $($server)" -ForegroundColor Yellow
                Remove-MailboxDatabaseCopy -Identity "STAGING\$server" -Confirm:$false -ea SilentlyContinue -wa SilentlyContinue

                $edbPath = "\\$server\Q`$\STAGING\"
                $logPath = "\\$server\R`$\STAGING\"
                
                Write-Host "`tCleaning up old 'STAGING' database copy files" -NoNewline
                
                $removed = $false
                while (-not $removed)
                {
                    try 
                    {
                        if ([bool](Test-Path -Path $edbPath -ea SilentlyContinue) -or [bool](Test-Path -Path $logPath -ea SilentlyContinue))
                        {
                            Remove-Item -Path $edbPath -Recurse -Force -Confirm:$false -ea Stop
                            Remove-Item -Path $logPath -Recurse -Force -Confirm:$false -ea Stop
                            $removed = $true
                        }
                        else
                        {
                            $removed = $true
                        }
                    }
                    catch 
                    {
                        Write-Host "." -NoNewLine
                        Start-Sleep -Seconds 30
                        $removed = $false
                    }
                }
            }

            "`n"
            Write-Host "Removing 'STAGING' database"
            $stagingDB | Remove-MailboxDatabase -Confirm:$false -ea SilentlyContinue -wa SilentlyContinue

            Write-Host "Cleaning up 'STAGING' database log files" -NoNewline

            $removed = $false
            while (-not $removed)
            {
                try 
                {
                    if ([bool](Test-Path -Path $stagingEDBPath -ea SilentlyContinue) -or [bool](Test-Path -Path $stagingLogPath -ea SilentlyContinue))
                    {
                        Remove-Item -Path $stagingEDBPath -Recurse -Force -Confirm:$false -ea Stop
                        Remove-Item -Path $stagingLogPath -Recurse -Force -Confirm:$false -ea Stop
                        $removed = $true
                    }
                    else
                    {
                        $removed = $true
                    }
                }
                catch 
                {
                    Write-Host "." -NoNewLine
                    Start-Sleep -Seconds 30
                    $removed = $false
                }
            }

            $cleanupCheck = [bool](Get-Item -Path $stagingEDBPath -ea SilentlyContinue)
            if (-not $cleanupCheck)
            {
                "`n"
                Write-Host "Successfully deleted 'STAGING' database" 
            }
            else
            {
                throw "There was an error deleting the 'STAGING' database"
            }

            Write-Host "Re-creating 'STAGING' database"

            $params = @{
                Name = "STAGING"
                Server = "ES-16EXCH01"
                OfflineAddressBook = "OAB (Ex2013)"
                EdbFilePath = "Q:\STAGING\STAGING.edb"
                LogFolderPath = "R:\STAGING\"
                IsExcludedFromProvisioning = $true
                Confirm = $false
            }

            try
            {
                New-MailboxDatabase @params -wa SilentlyContinue -DomainController "ES-DC1" | Out-Null
            }
            catch
            {
                Write-Host $Error[0] -ForegroundColor Red
                break
            }

            $params = @{
                Identity = "STAGING"
                CircularLoggingEnabled = $false
                ProhibitSendQuota = "Unlimited"
                IssueWarningQuota = "Unlimited"
                ProhibitSendReceiveQuota = "Unlimited"
                Confirm = $false
            }

            try 
            {
                Set-MailboxDatabase @params -DomainController "ES-DC1"
            }
            catch 
            {
                Write-Host $Error[0] -ForegroundColor Red
                break
            }
            
            Write-Host "Mounting 'STAGING' database" -NoNewLine

            $mounted = $false
            while (-not $mounted)
            {
                try 
                {
                    Mount-Database "STAGING" -Confirm:$false -DomainController "ES-DC1" -ea Stop
                    $mounted = $true
                }
                catch 
                {
                    Write-Host "." -NoNewLine
                    Start-Sleep -Seconds 30
                    $mounted = $false
                }
            }
            
            $dbMountCheck = Get-MailboxDatabase "STAGING" -Status
            "`n"
            if ($dbMountCheck.Mounted -eq $true)
            {
                $i = 2
                foreach ($server in $dbCopyServers)
                {
                    Write-Host "Working on $($server):" -ForegroundColor Yellow                        
                    Write-Host "`tAdding 'STAGING' database copy"
                    $params = @{
                        Identity = "STAGING"
                        MailboxServer = $server
                        ActivationPreference = $i
                        Confirm = $false
                        ErrorAction = "SilentlyContinue"
                    }

                    Add-MailboxDatabaseCopy @params -wa SilentlyContinue
                    $i++
                }
            }

            $health = $false
            "`n"
            Write-Host "Verifying database copy health" -NoNewline
            while (-not $health)
            {
                $healthCheck = Get-MailboxDatabaseCopyStatus "STAGING" | ? {$_.ContentIndexState -ne "Healthy"}
                if ($healthCheck)
                {
                    foreach ($db in $healthCheck)
                    {
                        if ($db.ContentIndexState -eq "FailedAndSuspended" -or $db.Status -eq "FailedAndSuspended")
                        {
                            Suspend-MailboxDatabaseCopy -Identity $db.Name -Confirm:$false -wa SilentlyContinue
                            Update-MailboxDatabaseCopy -Identity $db.Name -DeleteExistingFiles -Force -Confirm:$false -wa SilentlyContinue
                        }
                    }

                    $health = $false
                    Write-Host "." -NoNewline
                    Start-Sleep -Seconds 120
                }
                else 
                {
                    $health = $true
                }
            }

            "`n"
            Write-Host "All database copies are verifed to be healthy" -ForegroundColor Green
            "`n"
            Write-Host "Reconfiguring 'STAGING' for circular logging" -NoNewline

            $circular = $false
            while (-not $circular)
            {
                $stagingDB = Get-MailboxDatabase "STAGING"
                if ($stagingDB.CircularLoggingEnabled -eq $false)
                {
                    $stagingDB | Set-MailboxDatabase -CircularLoggingEnabled $true -Confirm:$false -ea SilentlyContinue
                    $circular = $false
                    Write-Host "." -NoNewline
                    Start-Sleep -Seconds 15
                }
                else
                {
                    $circular = $true
                }
            }

            "`n"
            Write-Host "Performing database validation checks"
            $stagingDB = Get-MailboxDatabase "STAGING" -Status
            $staging1 = Get-MailboxDatabaseCopyStatus -Identity "STAGING\ES-16EXCH01"
            $staging2 = Get-MailboxDatabaseCopyStatus -Identity "STAGING\ES-16EXCH02"
            $staging3 = Get-MailboxDatabaseCopyStatus -Identity "STAGING\TX-16EXCH01"
            $staging4 = Get-MailboxDatabaseCopyStatus -Identity "STAGING\TX-16EXCH02"

            Check-System -Message "Database Mounted" -Condition1 $stagingDB.Mounted -Condition2 $true
            Check-System -Message "STAGING 'ES-16EXCH01' Health" -Condition1 $staging1.ContentIndexState -Condition2 "Healthy"
            Check-System -Message "STAGING 'ES-16EXCH02' Health" -Condition1 $staging2.ContentIndexState -Condition2 "Healthy"
            Check-System -Message "STAGING 'TX-16EXCH01' Health" -Condition1 $staging3.ContentIndexState -Condition2 "Healthy"
            Check-System -Message "STAGING 'TX-16EXCH02' Health" -Condition1 $staging4.ContentIndexState -Condition2 "Healthy"
            Check-System -Message "Circular Logging Enabled" -Condition1 $stagingDB.CircularLoggingEnabled -Condition2 $true

            Read-Host "After verifying health - press any key to continue"
        }

        'X'
        {
            exit
        }

        'C'
        {
            Start-Migration
        }
    }

    if ($userCheck -ne "C")
    {
        Start-Migration
    }
}