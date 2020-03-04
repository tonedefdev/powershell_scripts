Import-Module ActiveDirectory
$ADComputers = Get-ADComputer -Filter {(Enabled -eq $True)} -Properties OperatingSystem,DNSHostName | where {($_.OperatingSystem -like "*Windows Server 2008*") -or ($_.OperatingSystem -like "*Windows Server 2012*") -or ($_.OperatingSystem -like "*Windows Server 2016*")}

$Array = @()

foreach ($Computer in $ADComputers)
{
    if (Test-Connection -ComputerName $Computer.Name -Count 1 -ea SilentlyContinue)
    {
        $Connection = $true
        $Path = "\\$($Computer.Name)\c$\Program Files\pandora_agent"

        Write-Host "Checking for Pandora installation on $($Computer.Name)"

        if (Test-Path -Path $Path -ErrorAction SilentlyContinue)
        {
            $PandoraInstall = $true
        } else {
            $PandoraInstall = $false
        }
    
        $Params = @{
            Computer = $Computer.Name
            Connected = $Connection
            PandoraInstalled = $PandoraInstall
        }

        $Object = New-Object -TypeName PSObject -Property $Params
        $Array += $Object

    } else {

        $Connection = $false
        $Params = @{
            Computer = $Computer.Name
            Connected = $Connection
            PandoraInstalled = ""
        }

        $Object = New-Object -TypeName PSObject -Property $Params
        $Array += $Object
    }
}

$Array | Select Computer,Connected,PandoraInstalled | Export-Csv -Path "C:\users\admin.aowens\Desktop\PandoraAgentInstall.csv" -NoTypeInformation