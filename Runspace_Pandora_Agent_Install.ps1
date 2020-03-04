$Servers = Import-CSV -Path "C:\users\admin.aowens\desktop\Install_Pandora.csv"

$pandoraScriptblock = {
param(
    [object]$Server,
    [string]$Destination
)      

    if (Test-Path -Path "$Destination\Pandora\Pandora FMS Windows Agent v7.0NG.727_x86_64.exe")
    {
        Write-Host "Launching installer on $($Server.Computer)" -ForegroundColor Yellow
        Start-Process -FilePath "C:\Temp\Pandora\Pandora FMS Windows Agent v7.0NG.727_x86_64.exe" -ArgumentList "/S"
    } else {
        Write-Host "Unable to copy Pandora install to $($Server.Computer). Install canceled" -ForegroundColor Red
        Break
    }

    $PandoraPath = "C:\Program Files\pandora_agent\"

    while ([bool](Get-Process * | ? {$_.Name -like "*Pandora*"}))
    {
        Start-Sleep -Seconds 1
    }

    Write-Host "Setting configuration file on $env:COMPUTERNAME" -ForegroundColor Yellow

    $PandoraCfg = "C:\Temp\Pandora\pandora_agent.conf"
    Copy-Item -Path $PandoraCfg -Destination "$PandoraPath\pandora_agent.conf" -Force

    $IP = [System.Net.Dns]::GetHostAddresses($env:COMPUTERNAME) | Select-String "10.*" | Out-String
    $IP = $IP.trim()
    
    $PandoraConfig = Get-Content -Path "$PandoraPath\pandora_agent.conf"
    $PandoraConfig[50] = "address $IP"
    Set-Content -Value $PandoraConfig -Path "$PandoraPath\pandora_agent.conf" -Force
    
    Write-Host "Starting Pandora services on $env:COMPUTERNAME" -ForegroundColor Yellow
    Start-Service -Name PandoraFMSAgent
    Write-Host "Cleaning up install files on $env:COMPUTERNAME" -ForegroundColor Yellow
    Remove-Item -Path "C:\Temp\Pandora" -Recurse -Force -ErrorAction SilentlyContinue

    $PandoraServiceCheck = Get-Service -Name PandoraFMSAgent
    $TimeStamp = (Get-Date)
    $CSV = "FileSystem::\\es-aowens\c$\temp\pandora_install_report.csv"
    
    if ($PandoraServiceCheck.Status -eq "Running")
    {
        $Params = @{
            Server = $env:COMPUTERNAME
            PandoraRunning = $true
            TimeStamp = $TimeStamp
        }

        Write-Host "Successfully installed and configured Pandora Agent on $env:COMPUTERNAME" -ForegroundColor Green
        $Result = New-Object -TypeName PSObject -Property $Params | Select Server,PandoraRunning,TimeStamp | Export-CSV -Path $CSV -Append -NoTypeInformation
    } else {
        $Params = @{
            Server = $env:COMPUTERNAME
            PandoraRunning = $false
            TimeStamp = $TimeStamp
        }

        Write-Host "Unable to confirm if Pandora service is running on $env:COMPUTERNAME. Installation likely failed." -ForegroundColor Red
        $Result = New-Object -TypeName PSObject -Property $Params | Select Server,PandoraRunning,TimeStamp | Export-CSV -Path $CSV -Append -NoTypeInformation
    }
}

$Scriptblock = {
param(
    $pandoraScriptblock,
    [object]$Server
)

    Write-Host "Copying Pandora install files to $($Server.Computer)" -ForegroundColor Cyan

    $Source = "\\PS-TASKS02\DSCResources\Pandora"
    $Destination = "\\$($Server.Computer)\c$\Temp\"

    if (!(Test-Path -Path $Destination))
    {
        New-Item -Path $Destination -ItemType Directory -Force | Out-Null
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
        Start-Sleep -Seconds 5
    } else {
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
        Start-Sleep -Seconds 5
    }
    
    Invoke-Command -ComputerName $Server.Computer -ScriptBlock $pandoraScriptblock -ArgumentList $Server,$Destination
}

$Throttle = 10
$initialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $Throttle,$initialSessionState,$Host)
$RunspacePool.Open()
$Jobs = @()

foreach ($Server in $Servers)
{
    $Job = [powershell]::Create().AddScript($Scriptblock).AddArgument($pandoraScriptblock).AddArgument($Server)
    $Job.RunspacePool = $RunspacePool
    $Jobs += New-Object PSObject -Property @{
        Pipe = $Job
        Result = $Job.BeginInvoke()
    }
}

$Results = @()

foreach ($Job in $Jobs)
{   
    $Results += $Job.Pipe.EndInvoke($Job.Result)
}