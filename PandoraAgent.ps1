Set-Location "C:\users\$env:USERNAME\Documents\"
$DscPath = "C:\users\$env:USERNAME\Documents\PandoraAgent"

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = "localhost"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            RebootNodeIfNeeded = $true
        }
    )
}

$AdminCredentials = Get-Credential "admin.aowens"

Configuration PandoraAgent 
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        File CreateTemp
        {
            Ensure                              = "Present"
            DestinationPath                     = "C:\Temp"
            Type                                = "Directory"
            Force                               = $true
        }

        Script PandoraInstall
        {
            SetScript = 
            {
                Start-Process -FilePath "C:\Temp\Pandora FMS Windows Agent v7.0NG.727_x86_64.exe" -ArgumentList "/S" -Verb runas
            }

            TestScript = 
            {
                $Regkey = [bool](Get-Item -Path HKLM:\\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\PandoraFMS_Agent)
                if ($Regkey)
                {
                    return $true
                } else {
                    return $false
                }
            }

            GetScript = 
            {
                @{Result = (Write-Verbose "Pandora Installed")}
            }
            DependsOn = "[Script]CopyPackages"
            PsDscRunAsCredential = $using:AdminCredentials
        }

        Script CopyPackages
        {
            SetScript =
            {
                Copy-Item -Path "\\PS-TASKS02\DSCResources\Pandora FMS Windows Agent v7.0NG.727_x86_64.exe" -Destination "C:\Temp\Pandora FMS Windows Agent v7.0NG.727_x86_64.exe" -Verbose
            }
            TestScript =
            {
                $Pandora = Get-ChildItem -Path "C:\Temp\Pandora FMS Windows Agent v7.0NG.727_x86_64.exe" -ErrorAction SilentlyContinue
                if ($Pandora.Length -eq 26806994) 
                {
                    return $true
                } else {
                    return $false
                }
            }
            GetScript =
            {
                @{Result = (Write-Verbose "Copied packages successfully")}
            }
            DependsOn = "[File]CreateTemp"
        }

    }
}

PandoraAgent -ConfigurationData $ConfigurationData

Start-DscConfiguration -Path $DscPath -Wait -Force -Verbose