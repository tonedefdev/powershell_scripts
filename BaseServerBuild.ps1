Set-Location "C:\users\$env:USERNAME\Documents\"
$DscPath = "C:\users\$env:USERNAME\Documents\BaseServerBuild"

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

Configuration BaseServerBuild
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

        Archive FireEyeUnzip
        {
            Destination                         = "C:\Temp\FireEye"
            Path                                = "C:\Temp\fireeye.zip"
            Force                               = $true
            Ensure                              = "Present"
            DependsOn                           = "[Script]CopyPackages"
        }

        Archive SymantecUnzip
        {
            Destination                         = "C:\Temp\Symantec"
            Path                                = "C:\Temp\symantec.zip"
            Force                               = $true
            Ensure                              = "Present"
            DependsOn                           = "[Script]CopyPackages"
        }

        Archive RsaUnzip
        {
            Destination                         = "C:\Temp\Rsa"
            Path                                = "C:\Temp\rsa.zip"
            Force                               = $true
            Ensure                              = "Present"
            DependsOn                           = "[Script]CopyPackages"
        }

        Package FireEyeInstall
        {
            Name                                = "FireEye Endpoint Agent"
            Path                                = "C:\Temp\fireeye\xagtSetup_26.21.10_universal.msi"
            ProductID                           = "B0039443-C643-44FC-9B05-844F59D66900"
            Arguments                           = "/qn"
            Ensure                              = "Present"
            DependsOn                           = "[Archive]FireEyeUnzip"
        }

        Package SymantecInstall
        {
            Name                                = "Symantec Endpoint Protection"
            Path                                = "C:\Temp\Symantec\setup.exe"
            ProductID                           = "2B448775-6A9D-4594-A59F-5F3076B67309"
            Ensure                              = "Present"
            DependsOn                           = "[Archive]SymantecUnzip"
        }

        Script CopyPackages
        {
            SetScript =
            {
                Copy-Item -Path "\\PS-TASKS02\DSCResources\fireeye.zip" -Destination "C:\Temp\fireeye.zip" -Verbose
                Copy-Item -Path "\\PS-TASKS02\DSCResources\symantec.zip" -Destination "C:\Temp\symantec.zip" -Verbose
                Copy-Item -Path "\\PS-TASKS02\DSCResources\rsa.zip" -Destination "C:\Temp\rsa.zip" -Verbose
                Copy-Item -Path "\\PS-TASKS02\DSCResources\Client_Install.bat" -Destination "C:\Temp\Client_Install.bat" -Verbose

            }
            TestScript =
            {
                $Fireeye = Get-ChildItem -Path "C:\Temp\fireeye.zip" -ErrorAction SilentlyContinue
                $Symantec = Get-ChildItem -Path "C:\Temp\symantec.zip" -ErrorAction SilentlyContinue
                $Rsa = Get-ChildItem -Path "C:\Temp\rsa.zip" -ErrorAction SilentlyContinue
                $Sccm = Get-ChildItem -Path "C:\Temp\Client_Install.bat" -ErrorAction SilentlyContinue
                if (($Fireeye.Length -eq 21222647) -and ($Symantec.Length -eq 216651516) -and ($Rsa.Length -eq 258613411) -and ($Sccm.Length -eq 64)) {
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

BaseServerBuild -ConfigurationData $ConfigurationData

Start-DscConfiguration -Path $DscPath -Wait -Force -Verbose