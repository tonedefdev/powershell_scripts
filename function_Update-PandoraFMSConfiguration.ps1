function Update-PandoraFMSConfiguration {
[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [array]$Selections,
    [ValidateNotNullOrEmpty()]
    [string]$Computer,
    [bool]$Reconfigure,
    [bool]$AddModule,
    [bool]$New
)

$scriptBlock = {
param(
    [string]$Computer,
    [array]$Selections,
    [bool]$Reconfigure,
    [bool]$AddModule,
    [bool]$New
)
    Write-Host "`tStopping Pandora FMS services" -ForegroundColor Yellow
    Stop-Service -Name PandoraFMSAgent -Force

    if ($Selections)
    {
        $Modules = @()
        foreach ($Selection in $Selections)
        {
            switch ($Selection)
            {
                "Default"
		        {
			        $Path = $null
                    $Module = $null
                }
                
		        "DFS" 
		        {
			        $Path = "C:\Temp\Pandora\DFS"
                    $Module = Get-Content -Path "$Path\DFS.txt"
                    $Modules += $Module
		        }

		        "DHCP" 
		        {
			        $Path = "C:\Temp\Pandora\DHCP"
                    $Module = Get-Content -Path "$Path\DHCP.txt"
                    $Modules += $Module
		        }

                "DomainController"
                {
                    $Path = "C:\Temp\Pandora\Domain Controller"
                    $Module = Get-Content -Path "$Path\Domain Controller.txt"
                    $Modules += $Module
                }

                "Exchange" 
		        {
			        $Path = "C:\Temp\Pandora\Exchange"
                    $Module = Get-Content -Path "$Path\Exchange.txt"
                    $Modules += $Module
                }

                "ExchangeDBMonitor"
                {
                    $Path = "C:\Temp\Pandora\Exchange DB Monitor"
                    $Module = Get-Content -Path "$Path\ExchangeDBMonitor.txt"
                    $Modules += $Module
                }

                "InfoSecApps"
                {
                    $Path = "C:\Temp\Pandora\InfoSec Apps"
                    $Module = Get-Content -Path "$Path\InfoSec Apps.txt"
                    $Modules += $Module
                }
                
                "JDE" 
		        {
			        $Path = "C:\Temp\Pandora\JDE"
                    $Module = Get-Content -Path "$Path\JDE.txt"
                    $Modules += $Module
		        }

		        "MicrosoftSQL" 
		        {
			        $Path = "C:\Temp\Pandora\Microsoft SQL"
                    $Module = Get-Content -Path "$Path\Microsoft SQL.txt"
                    $Modules += $Module
                }
                
                "ScriptLogic" 
		        {
			        $Path = "C:\Temp\Pandora\Script Logic"
                    $Module = Get-Content -Path "$Path\Script Logic.txt"
                    $Modules += $Module
                }

                "SourceOne"
                {
                    $Path = "C:\Temp\Pandora\Source One"
                    $Module = Get-Content -Path "$Path\Source One.txt"
                    $Modules += $Module
                }

                "Umbrella"
                {
                    $Path = "C:\Temp\Pandora\Umbrella"
                    $Module = Get-Content -Path "$Path\Umbrella.txt"
                    $Modules += $Module
                }
                
                "Veeam"
                {
                    $Path = "C:\Temp\Pandora\Veeam"
                }

                "Websense"
                {
                    $Path = "C:\Temp\Pandora\Websense"
                }
            }
            
            $PandoraPath = "C:\Program Files\pandora_agent"

            if ($Path)
            {
                $Items = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue
            }

            if ($Items)
            {
                Write-Host "`tCopying selected modules" -ForegroundColor Yellow
                foreach ($Item in $Items)
                {
                    switch ($Item.Name)
                    {
                        "util" 
                        {	
                            $OriginUtil = "$Path\util"
                            $UtilPath = "$PandoraPath\util"
                            $Util = Get-ChildItem -Path $OriginUtil
                            foreach ($File in $Util)
                            {
                                Write-Host "`t`tCopying: $OriginUtil\$($File.Name)"
                                Copy-Item -Path "$OriginUtil\$($File.Name)" -Destination "$UtilPath\$($File.Name)" -Force
                            }
                        }
                
                        "scripts"
                        {
                            $OriginScripts = "$Path\scripts"
                            $ScriptsPath = "$PandoraPath\scripts"
                            $Scripts = Get-ChildItem -Path $OriginScripts
                            foreach ($File in $Scripts)
                            {
                                Write-Host "`t`tCopying: $OriginScripts\$($File.Name)"
                                Copy-Item -Path "$OriginScripts\$($File.Name)" -Destination "$ScriptsPath\$($File.Name)" -Force
                            }
                        }
                    }
                }
            }
        }
        
        if ($Reconfigure)
        {
            Write-Host "`tReconfiguring Pandora FMS agent" -ForegroundColor Yellow
            $Config = Get-Content -Path "$PandoraPath\pandora_agent.conf"
            $Count = $Config.Count

            for ($i = 0; $i -lt $Count; $i++)
            {
                if ($Config[$i] -like "*powershell.exe*")
                {
                    $Stepback = $i - 1
                    $Config[$Stepback] = ""
                    $Config[$i] = ""
                    Set-Content -Value $Config -Path "$PandoraPath\pandora_agent.conf" -Force
                }
            }

            if ($Modules)
            {
                Write-Host "`tInserting modules into '$PandoraPath\pandora_agent.conf'" -ForegroundColor Yellow
                [System.Collections.ArrayList]$PandoraConfig = Get-Content -Path "$PandoraPath\pandora_agent.conf"
                $PandoraConfig.Add($Modules) | Out-Null
                Set-Content -Value $PandoraConfig -Path "$PandoraPath\pandora_agent.conf" -Force

                Write-Host "`tStarting 'Pandora Agent Service'" -ForegroundColor Yellow
                Start-Service -Name PandoraFMSAgent
            } else {
                Write-Host "`tStarting 'Pandora Agent Service'" -ForegroundColor Yellow
                Start-Service -Name PandoraFMSAgent
            }
        }

        if ($AddModule)
        {
            if ($Modules)
            {
                Write-Host "`tAdding selected modules to Pandora FMS agent"  -ForegroundColor Yellow
                [System.Collections.ArrayList]$PandoraConfig = Get-Content -Path "$PandoraPath\pandora_agent.conf"
                $PandoraConfig.Add($Modules) | Out-Null
                Set-Content -Value $PandoraConfig -Path "$PandoraPath\pandora_agent.conf" -Force

                Write-Host "`tStarting 'Pandora Agent Service'" -ForegroundColor Yellow
                Start-Service -Name PandoraFMSAgent
            } else {
                Write-Host "`tStarting 'Pandora Agent Service'" -ForegroundColor Yellow
                Start-Service -Name PandoraFMSAgent
            }
        }

        if ($New)
        {
            Write-Host "`tConfiguring Pandora FMS agent for the first time" -ForegroundColor Yellow
            $PandoraCfg = "C:\Temp\Pandora\pandora_agent.conf"
            Copy-Item -Path $PandoraCfg -Destination "$PandoraPath\pandora_agent.conf" -Force

            if ($Modules)
            {
                Write-Host "`tInserting modules into '$PandoraPath\pandora_agent.conf'" -ForegroundColor Yellow
                [System.Collections.ArrayList]$PandoraConfig = Get-Content -Path "$PandoraPath\pandora_agent.conf"
                $PandoraConfig.Add($Modules) | Out-Null
                Set-Content -Value $PandoraConfig -Path "$PandoraPath\pandora_agent.conf" -Force -InformationAction SilentlyContinue
                $IP = [System.Net.Dns]::GetHostAddresses($env:COMPUTERNAME) | Select-String "10.*" | Out-String
                $IP = $IP.trim()
                Write-Host "`t`tInserting server IP '$IP' into '$PandoraPath\pandora_agent.conf'" -ForegroundColor Yellow
            } else {
                $IP = [System.Net.Dns]::GetHostAddresses($env:COMPUTERNAME) | Select-String "10.*" | Out-String
                $IP = $IP.trim()
                Write-Host = "`t`tInserting server IP '$IP' into '$PandoraPath\pandora_agent.conf'"
            }

            $PandoraConfig = Get-Content -Path "$PandoraPath\pandora_agent.conf"
            $PandoraConfig[50] = "address $IP"
            Set-Content -Value $PandoraConfig -Path "$PandoraPath\pandora_agent.conf" -Force -InformationAction SilentlyContinue
    
            Write-Host "`tStarting 'Pandora Agent Service'" -ForegroundColor Yellow
            Start-Service -Name PandoraFMSAgent
        }

        Write-Host "`tCleaning up 'C:\Temp\Pandora'" -ForegroundColor Yellow
        Remove-Item -Path "C:\Temp\Pandora" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Pandora Agent has been successfully configured on '$Computer'" -ForegroundColor Green
    } else {
        Write-Error "No modules were selected. Please, ensure that you insert an array of modules that you want to configure for the agent."
    }
}

Write-Host "Starting Pandora FMS configuration on '$Computer'" -ForegroundColor Cyan

$Path = "\\$Computer\C$\Temp\Pandora"
$Artifacts = "\\PS-TASKS02\DSCResources\Pandora"    

if (!(Test-Path -Path $Path -ErrorAction SilentlyContinue))
{
    Write-Host "`tCopying Pandora FMS artifacts" -ForegroundColor Yellow
    New-Item -Path $Path -ItemType Directory | Out-Null
    $Pandora = Get-ChildItem -Path $Artifacts -Exclude "*.exe"
    foreach ($File in $Pandora)
    {
        Write-Host "`t `tCopying: $Artifacts\$($File.Name)"
        Copy-Item -Path "$Artifacts\$($File.Name)" -Destination "$Path\$($File.Name)" -Recurse -Force
    }
}

Invoke-Command -ComputerName $Computer -ScriptBlock $scriptBlock -ArgumentList $Computer,$Selections,$Reconfigure,$AddModule,$New
}
