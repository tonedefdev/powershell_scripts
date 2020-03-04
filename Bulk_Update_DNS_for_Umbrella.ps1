$testFunction = @'
function Test-DNSUmbrella {
    param(
        [array]$UmbrellaVAs,
        [array]$UmbrellaVAsServer2008
    )
    if ($umbrellaVAs)
    {
        $test = $false
        for ($i = 0; $i -lt $umbrellaVAs.Count; $i++)
        {
            Write-Host "[$($env:COMPUTERNAME)]: Testing connection to $($umbrellaVAs[$i])" -ForegroundColor Yellow
            $connection = [bool](Test-Connection -ComputerName $umbrellaVAs[$i] -ea Ignore)
            if ($connection)
            {
                $name = "google.com"
                Write-Host "[$($env:COMPUTERNAME)]: Ping received response from $($umbrellaVAs[$i])" -ForegroundColor Yellow
                Write-Host "[$($env:COMPUTERNAME)]: Testing external name resolution against $($umbrellaVAs[$i])" -ForegroundColor Yellow
                try
                {
                    $query = Resolve-DnsName -Name $name -Server $umbrellaVAs[$i] -ea Stop
                    if ($query.Section -eq "Answer")
                    {
                        Write-Host "[$($env:COMPUTERNAME)]: Successfully resolved '$name' against $($umbrellaVAs[$i])" -ForegroundColor Green
                        $test = $true
                    }
                }
                catch
                {
                    Write-Host "[$($env:COMPUTERNAME)]: Unable to resolve '$name' against $($umbrellaVAs[$i])" -ForegroundColor Red
                    $test = $false
                }

                $internal = "ES-DC1.labspace.com"
                Write-Host "[$($env:COMPUTERNAME)]: Testing internal name resolution against $($umbrellaVAs[$i])" -ForegroundColor Yellow
                try
                {
                    $query = Resolve-DnsName -Name $internal -Server $umbrellaVAs[$i] -ea Stop
                    if ($query.Section -eq "Answer")
                    {
                        Write-Host "[$($env:COMPUTERNAME)]: Successfully resolved '$internal' against $($umbrellaVAs[$i])" -ForegroundColor Green
                        $test = $true
                    }
                }
                catch
                {
                    Write-Host "[$($env:COMPUTERNAME)]: Unable to resolve '$internal' against $($umbrellaVAs[$i])" -ForegroundColor Red
                    $test = $false
                }
            }
            else 
            {
                Write-Host "[$($env:COMPUTERNAME)]: Test connection timed out against $($umbrellaVAs[$i])" -ForegroundColor Red
                $test = $false
            }
        }
        return $test
    }

    if ($UmbrellaVAsServer2008)
    {
        $test = $false
        for ($i = 0; $i -lt $umbrellaVAsServer2008.Count; $i++)
        {
            Write-Host "[$($env:COMPUTERNAME)]: Testing connection to $($umbrellaVAsServer2008[$i])" -ForegroundColor Yellow
            $connection = [bool](Test-Connection -ComputerName $umbrellaVAsServer2008[$i] -ea Ignore)
            if ($connection)
            {
                $name = "google.com"
                Write-Host "[$($env:COMPUTERNAME)]: Ping received response from $($umbrellaVAsServer2008[$i])" -ForegroundColor Yellow
                Write-Host "[$($env:COMPUTERNAME)]: Testing external name resolution against $($umbrellaVAsServer2008[$i])" -ForegroundColor Yellow
                $temp = "C:\Temp"
                if (!(Test-Path -Path $temp))
                {
                    New-Item -Path $temp -ItemType Directory -Force | Out-Null
                }
                nslookup $name $umbrellaVAsServer2008[$i] 2>&1 | Out-File "C:\Temp\dns.txt"
                $query = Get-Content "C:\Temp\dns.txt"
                if ($query -match "Non-authoritative answer")
                {
                    Write-Host "[$($env:COMPUTERNAME)]: Successfully resolved '$name' against $($umbrellaVAsServer2008[$i])" -ForegroundColor Green
                    $test = $true
                }
                else
                {
                    Write-Host "[$($env:COMPUTERNAME)]: Unable to resolve '$name' against $($umbrellaVAsServer2008[$i])" -ForegroundColor Red
                    $test = $false
                }

                $internal = "ES-DC1.labspace.com"
                Write-Host "[$($env:COMPUTERNAME)]: Testing internal name resolution against $($umbrellaVAsServer2008[$i])" -ForegroundColor Yellow
                nslookup $internal $umbrellaVAsServer2008[$i] 2>&1 | Out-File "C:\Temp\dns.txt"
                $query = Get-Content "C:\Temp\dns.txt"
                if ($query -match "Non-authoritative answer")
                {
                    Write-Host "[$($env:COMPUTERNAME)]: Successfully resolved '$internal' against $($umbrellaVAsServer2008[$i])" -ForegroundColor Green
                    $test = $true
                }
                else
                {
                    Write-Host "[$($env:COMPUTERNAME)]: Unable to resolve '$internal' against $($umbrellaVAsServer2008[$i])" -ForegroundColor Red
                    $test = $false
                }
            }
            else
            {
                Write-Host "[$($env:COMPUTERNAME)]: Test connection timed out against $($umbrellaVAsServer2008[$i])" -ForegroundColor Red
                $test = $false
            }
        }
        return $test
    }
}
'@

$dnsFunction = @'
function Update-DNSToUmbrella {
param(
    [array]$UmbrellaVAs,
    [array]$UmbrellaVAsServer2008,
    [object]$Computer
)
    switch -Wildcard ($computer.OperatingSystem)
    {
        'Windows Server 201*'
        {
            $netAdapter = Get-WMIObject win32_NetworkAdapterConfiguration | ? {$_.IPAddress -like "10.*" -and $_.DefaultIPGateway -ne $null}
            $dns = $netAdapter | Get-DnsClientServerAddress
            $initCompare = Compare-Object -ReferenceObject $dns.ServerAddresses -DifferenceObject $umbrellaVAs
            if ($initCompare)
            {
                Write-Host "[$($env:COMPUTERNAME)]: Adding Umbrella VAs: $($umbrellaVAs[0]), $($umbrellaVAs[1])" -ForegroundColor Cyan
                $netAdapter | Set-DnsClientServerAddress -ServerAddresses ($umbrellaVAs[0],$umbrellaVAs[1]) -Confirm:$false
            
                $checkDNS = $netAdapter | Get-DnsClientServerAddress
                $checkCompare = Compare-Object -ReferenceObject $checkDNS.ServerAddresses -DifferenceObject $umbrellaVAs
                if (-not $checkCompare)
                {
                    Write-Host "[$($env:COMPUTERNAME)]: Successfully added Umbrella VAs: $($umbrellaVAs[0]), $($umbrellaVAs[1])" -ForegroundColor Green
                    return $true
                } 
                else 
                {
                    Write-Host "[$($env:COMPUTERNAME)]: Unsuccessfully added Umbrella VAs: $($umbrellaVAs[0]), $($umbrellaVAs[1])" -ForegroundColor Red
                    Write-Host "[$($env:COMPUTERNAME)]: Current DNS servers:"
                    for ($i = 0; $i -lt $checkDNS.ServerAddresses.Count; $i++)
                    {
                        Write-Host "[$($env:COMPUTERNAME)]: $($checkDNS.ServerAddresses[$i])"
                    }
                    Write-Host "[$($env:COMPUTERNAME)]: Ending process" -ForegroundColor Cyan
                    return $false
                }
            }            
            else 
            {
                Write-Host "[$($env:COMPUTERNAME)]: Skipping as Umbrella VAs are already configured on this machine" -ForegroundColor Green    
            }
        }

        'Windows Server 2008*'
        {
            $netAdapters = Get-WMIObject win32_NetworkAdapterConfiguration | ? {$_.IPAddress -like "10.*" -and $_.DefaultIPGateway -ne $null}
            foreach ($netAdapter in $netAdapters)
            {
                $initCompare = Compare-Object -ReferenceObject $netAdapter.DNSServerSearchOrder -DifferenceObject $umbrellaVAsServer2008
                if ($initCompare)
                {
                    Write-Host "[$($env:COMPUTERNAME)]: Adding Umbrella VAs: $umbrellaVAsServer2008" -ForegroundColor Cyan
                    $netAdapter.SetDNSServerSearchOrder($umbrellaVAsServer2008) | Out-Null
            
                    $checkDNS = Get-WMIObject win32_NetworkAdapterConfiguration | ? {$_.Index -eq $netAdapter.Index}
                    $checkCompare = Compare-Object -ReferenceObject $checkDNS.DNSServerSearchOrder -DifferenceObject $umbrellaVAsServer2008
                    
                    if (-not $checkCompare)
                    {
                        Write-Host "[$($env:COMPUTERNAME)]: Successfully added Umbrella VAs: $($umbrellaVAsServer2008)" -ForegroundColor Green
                        return $true
                    }
                    else 
                    {
                        Write-Host "[$($env:COMPUTERNAME)]: Unsuccessfully added Umbrella VAs: $($umbrellaVAsServer2008)" -ForegroundColor Red
                        Write-Host "[$($env:COMPUTERNAME)]: Current DNS servers:"
                        for ($i = 0; $i -lt $checkDNS.DNSServerSearchOrder.Count; $i++)
                        {
                            Write-Host "[$($env:COMPUTERNAME)]: $($checkDNS.DNSServerSearchOrder[$i])"
                        }
                        Write-Host "[$($env:COMPUTERNAME)]: Ending process" -ForegroundColor Cyan
                        return $false
                    }
                }
                else
                {
                    Write-Host "[$($env:COMPUTERNAME)]: Skipping as Umbrella VAs are already configured on this machine" -ForegroundColor Green
                }
            }
        }
    }
}
'@

function Update-UmbrellaDNS {
param(
    [array]$UmbrellaDNS,
    [array]$UmbrellaDNS2008,
    [object]$Computer,
    $TestFunction,
    $DnsFunction
)
    $connection = Test-Connection -ComputerName $computer.DNSHostName -Count 1 -ea Ignore
    if ($connection)
    {
        switch -Wildcard ($computer.OperatingSystem)
        {
            "Windows Server 201*"
            {
                $testScriptBlock = {
                param (
                    $computer,
                    $testFunction,
                    $umbrellaDNS,
                    $umbrellaDNS2008
                )
                    Invoke-Expression $testFunction
                    Test-DNSUmbrella -UmbrellaVAs $umbrellaDNS
                }

                $setScriptBlock = {
                param(
                    $computer,
                    $dnsFunction,
                    $umbrellaDNS,
                    $umbrellaDNS2008
                )
                    Invoke-Expression $dnsFunction
                    Update-DNSToUmbrella -Computer $computer -UmbrellaVAs $umbrellaDNS
                }
            }

            "Windows Server 2008*"
            {
                $testScriptBlock = {
                param (
                    $computer,
                    $testFunction,
                    $umbrellaDNS,
                    $umbrellaDNS2008
                )
                    Invoke-Expression $testFunction
                    Test-DNSUmbrella -UmbrellaVAsServer2008 $umbrellaDNS2008 
                }

                $setScriptBlock = {
                param(
                    $computer,
                    $dnsFunction,
                    $umbrellaDNS,
                    $umbrellaDNS2008
                )
                    Invoke-Expression $dnsFunction
                    Update-DNSToUmbrella -Computer $computer -UmbrellaVAsServer2008 $umbrellaDNS2008 
                }
            }
        }
        $set = Invoke-Command -ComputerName $computer.DNSHostName -ScriptBlock $setScriptBlock -ArgumentList $computer,$dnsFunction,$umbrellaDNS,$umbrellaDNS2008
        if ($set)
        {
            $test = Invoke-Command -ComputerName $computer.DNSHostName -ScriptBlock $testScriptBlock -ArgumentList $computer,$testFunction,$umbrellaDNS,$umbrellaDNS2008
        }

        $report = @()
        if ($test)
        {
            $hash = [ordered]@{
                Server = $computer.DNSHostName
                DNSServersAdded = $true
                UmbrellaVerified = $true
            }

            $object = New-Object -TypeName PSObject -Property $hash
            $report += $object
        }
        else 
        {
            $hash = [ordered]@{
                Server = $computer.DNSHostName
                DNSServersAdded = $false
                UmbrellaVerified = $false
            }

            $object = New-Object -TypeName PSObject -Property $hash
            $report += $object
        }
    }
    return $report
}

Import-Module ActiveDirectory
$computers = @()
$adComputers = Get-ADComputer -Filter {Enabled -eq $true} -Properties OperatingSystem | ? {($_.OperatingSystem -like "*Windows Server 2008*") -or ($_.OperatingSystem -like "*Windows Server 2012*") -or ($_.OperatingSystem -like "*Windows Server 2016*")}
foreach ($computer in $adComputers)
{
    if ($computer.Name -like "*EXCH*")
    {
        continue
    }
    elseif ($computer.Name -match "DC\d\d")
    {
        continue
    }
    elseif ($computer.Name -match "DC\d")
    {
        continue
    }
    elseif ($computer.Name -match "AD\d")
    {
        continue
    }   
    else 
    {
        $computers += $computer   
    }
}

$report = @()
foreach ($computer in $computers)
{
    switch -Regex ($computer.DNSHostName)
    {
        '^MB'
        {
            $job = Update-UmbrellaDNS -UmbrellaDNS @("10.1.74.137","10.0.4.137") -UmbrellaDNS2008 "10.1.74.137","10.0.4.137" -Computer $computer -TestFunction $testFunction -DnsFunction $dnsFunction
            $report += $job
        }

        '^MD'
        {
            $job = Update-UmbrellaDNS -UmbrellaDNS @("10.1.89.27","10.1.65.47") -UmbrellaDNS2008 "10.1.89.27","10.1.65.47" -Computer $computer -TestFunction $testFunction -DnsFunction $dnsFunction
            $report += $job
        }

        '^PS'
        {
            $job = Update-UmbrellaDNS -UmbrellaDNS @("10.1.65.47","10.1.65.48") -UmbrellaDNS2008 "10.1.65.47","10.1.65.48" -Computer $computer -TestFunction $testFunction -DnsFunction $dnsFunction
            $report += $job
        }

        '^RTP'
        {
            $job = Update-UmbrellaDNS -UmbrellaDNS @("10.1.97.27","10.1.65.47") -UmbrellaDNS2008 "10.1.97.27","10.1.65.47" -Computer $computer -TestFunction $testFunction -DnsFunction $dnsFunction
            $report += $job
        }

        '^SD'
        {
            $job = Update-UmbrellaDNS -UmbrellaDNS @("10.1.101.7","10.0.4.137") -UmbrellaDNS2008 "10.1.101.7","10.0.4.137" -Computer $computer -TestFunction $testFunction -DnsFunction $dnsFunction
            $report += $job
        }
    
        '^SEA'
        {
            $job = Update-UmbrellaDNS -UmbrellaDNS @("10.1.85.137","10.0.4.137") -UmbrellaDNS2008 "10.1.85.137","10.0.4.137" -Computer $computer -TestFunction $testFunction -DnsFunction $dnsFunction
            $report += $job
        }

        '^TS'
        {
            $job = Update-UmbrellaDNS -UmbrellaDNS @("10.1.81.37","10.1.65.47") -UmbrellaDNS2008 "10.1.81.37","10.1.65.47" -Computer $computer -TestFunction $testFunction -DnsFunction $dnsFunction
            $report += $job
        }

        '^TX'
        {
            $job = Update-UmbrellaDNS -UmbrellaDNS @("10.1.65.47","10.1.65.48") -UmbrellaDNS2008 "10.1.65.47","10.1.65.48" -Computer $computer -TestFunction $testFunction -DnsFunction $dnsFunction
            $report += $job
        }

        '^NY'
        {
            $job = Update-UmbrellaDNS -UmbrellaDNS @("10.1.65.47","10.1.65.48") -UmbrellaDNS2008 "10.1.65.47","10.1.65.48" -Computer $computer -TestFunction $testFunction -DnsFunction $dnsFunction
            $report += $job
        }
    }
}

if ($report)
{
    $report | Export-Csv -Path "C:\users\$env:USERNAME\desktop\UmbrellaDNSUpdateReport.csv" -NoTypeInformation
}