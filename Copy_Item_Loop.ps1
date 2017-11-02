Import-Module ActiveDirectory 

$ADComputers = Get-ADComputer -Filter {(Enabled -eq $True)} -Properties OperatingSystem,DNSHostName | where {($_.OperatingSystem -like "*Windows Server 2008*") -or ($_.OperatingSystem -like "*Windows Server 2012*") -or ($_.OperatingSystem -like "*Windows Server 2016*")} | Sort DNSHostName | Select-Object -ExpandProperty DNSHostName

$Win10Scripts = "C:\Win10 Disable Update Scripts"

foreach ($Computer in $ADComputers) {

    $Destination = "\\$Computer\C$\Installs"
    $FinalPath = "\\$Computer\C$\Installs\Win10 Disable Update Scripts"

    if ([bool](Test-Connection -ComputerName $Computer -Count 2)) { 
    
        if (Test-Path $Destination) {

            Copy-Item -Path $Win10Scripts -Destination $Destination -Recurse -Force

                if (Test-Path $FinalPath) {

                    Write-Host "Scripts successfully transferred to: " -NoNewline
                    Write-Host "$Computer" -ForegroundColor Green

                } else {

                    Write-Host "There was an issue transferring to: " -NoNewline
                    Write-Host "$Computer" -ForegroundColor Red
                    Continue

                }

        } else {

            Write-Host "$Destination doesn't exist!" -ForegroundColor Red
            Continue

        }

    } else {

        Write-Host "Unable to connect to: " -NoNewline
        Write-Host "$Computer" -ForegroundColor Red
        Continue

    }

}
