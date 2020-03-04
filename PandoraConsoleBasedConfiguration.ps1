[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [array]$Selections,
    [ValidateNotNullOrEmpty()]
    [array]$Computers,
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
    Write-Host "`t Stopping Pandora FMS services" -ForegroundColor Yellow
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

                "Domain Controller"
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

                "Exchange DB Monitor"
                {
                    $Path = "C:\Temp\Pandora\Exchange DB Monitor"
                    $Module = Get-Content -Path "$Path\ExchangeDBMonitor.txt"
                    $Modules += $Module
                }

                "InfoSec Apps"
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

		        "Microsoft SQL" 
		        {
			        $Path = "C:\Temp\Pandora\Microsoft SQL"
                    $Module = Get-Content -Path "$Path\Microsoft SQL.txt"
                    $Modules += $Module
                }
                
                "Script Logic" 
		        {
			        $Path = "C:\Temp\Pandora\Script Logic"
                    $Module = Get-Content -Path "$Path\Script Logic.txt"
                    $Modules += $Module
                }

                "Source One"
                {
                    $Path = "C:\Temp\Pandora\Source One"
                    $Module = Get-Content -Path "$Path\Source One.txt"
                    $Modules += $Module
                }
                
                "Veeam"
                {
                    $Path = "C:\Temp\Pandora\Veeam"
                }
            }
            
            $PandoraPath = "C:\Program Files\pandora_agent"

            if ($Path)
            {
                $Items = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue
            }

            if ($Items)
            {
                Write-Host "`t Copying selected modules" -ForegroundColor Yellow
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
                                Write-Host "`t `t Copying: $OriginUtil\$($File.Name)"
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
                                Write-Host "`t `t Copying: $OriginScripts\$($File.Name)"
                                Copy-Item -Path "$OriginScripts\$($File.Name)" -Destination "$ScriptsPath\$($File.Name)" -Force
                            }
                        }
                    }
                }
            }
        }
        
        if ($Reconfigure)
        {
            Write-Host "`t Reconfiguring Pandora FMS agent" -ForegroundColor Yellow
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
                Write-Host "`t `t Inserting modules into '$PandoraPath\pandora_agent.conf'" -ForegroundColor Yellow
                [System.Collections.ArrayList]$PandoraConfig = Get-Content -Path "$PandoraPath\pandora_agent.conf"
                $PandoraConfig.Add($Modules)
                Set-Content -Value $PandoraConfig -Path "$PandoraPath\pandora_agent.conf" -Force

                Write-Host "`t Starting 'Pandora Agent Service'" -ForegroundColor Yellow
                Start-Service -Name PandoraFMSAgent
            } else {
                Write-Host "`t Starting 'Pandora Agent Service'" -ForegroundColor Yellow
                Start-Service -Name PandoraFMSAgent
            }
        }

        if ($AddModule)
        {
            Write-Host "`t Adding selected modules to Pandora FMS agent" -ForegroundColor Yellow
            if ($Modules)
            {
                Write-Host "`t `t Inserting modules into '$PandoraPath\pandora_agent.conf'" -ForegroundColor Yellow
                [System.Collections.ArrayList]$PandoraConfig = Get-Content -Path "$PandoraPath\pandora_agent.conf"
                $PandoraConfig.Add($Modules)
                Set-Content -Value $PandoraConfig -Path "$PandoraPath\pandora_agent.conf" -Force

                Write-Host "`t Starting 'Pandora Agent Service'" -ForegroundColor Yellow
                Start-Service -Name PandoraFMSAgent
            } else {
                Write-Host "`t Starting 'Pandora Agent Service'" -ForegroundColor Yellow
                Start-Service -Name PandoraFMSAgent
            }
        }

        if ($New)
        {
            Write-Host "`t Configuring Pandora FMS agent for the first time" -ForegroundColor Yellow
            $PandoraCfg = "C:\Temp\Pandora\pandora_agent.conf"
            Copy-Item -Path $PandoraCfg -Destination "$PandoraPath\pandora_agent.conf" -Force

            if ($Modules)
            {
                Write-Host "`t `t Inserting modules into '$PandoraPath\pandora_agent.conf'" -ForegroundColor Yellow
                [System.Collections.ArrayList]$PandoraConfig = Get-Content -Path "$PandoraPath\pandora_agent.conf"
                $PandoraConfig.Add($Modules)
                Set-Content -Value $PandoraConfig -Path "$PandoraPath\pandora_agent.conf" -Force
                $IP = [System.Net.Dns]::GetHostAddresses($env:COMPUTERNAME) | Select-String "10.*" | Out-String
                $IP = $IP.trim()
                Write-Host "`t `t Inserting server IP '$IP' into '$PandoraPath\pandora_agent.conf'" -ForegroundColor Yellow
            } else {
                $IP = [System.Net.Dns]::GetHostAddresses($env:COMPUTERNAME) | Select-String "10.*" | Out-String
                $IP = $IP.trim()
                Write-Host = "`t `t Inserting server IP '$IP' into '$PandoraPath\pandora_agent.conf'"
            }

            $PandoraConfig = Get-Content -Path "$PandoraPath\pandora_agent.conf"
            $PandoraConfig[50] = "address $IP"
            Set-Content -Value $PandoraConfig -Path "$PandoraPath\pandora_agent.conf" -Force
    
            Write-Host "`t Starting 'Pandora Agent Service'" -ForegroundColor Yellow
            Start-Service -Name PandoraFMSAgent
        }

        Write-Host "`t Cleaning up 'C:\Temp\Pandora'" -ForegroundColor Yellow
        Remove-Item -Path "C:\Temp\Pandora" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Pandora Agent has been successfully configured" -ForegroundColor Green
    } else {
        Write-Error "No modules were selected. Please, ensure that you insert an array of modules that you want to configure for the agent."
    }
}

foreach ($Computer in $Computers)
{
    Write-Host "Starting Pandora FMS configuration on '$Computer'" -ForegroundColor Cyan

    $Path = "\\$Computer\C$\Temp\Pandora"
    $Artifacts = "\\PS-TASKS02\DSCResources\Pandora"    

    if (!(Test-Path -Path $Path -ErrorAction SilentlyContinue))
    {
        Write-Host "`t Copying Pandora FMS artifacts" -ForegroundColor Yellow
        New-Item -Path $Path -ItemType Directory | Out-Null
        $Pandora = Get-ChildItem -Path $Artifacts
        foreach ($File in $Pandora)
        {
            Write-Host "`t `t Copying: $Artifacts\$($File.Name)"
            Copy-Item -Path "$Artifacts\$($File.Name)" -Destination "$Path\$($File.Name)" -Recurse -Force
        }
    }

    Invoke-Command -ComputerName $Computer -ScriptBlock $scriptBlock -ArgumentList $Computer,$Selections,$Reconfigure,$AddModule,$New
}