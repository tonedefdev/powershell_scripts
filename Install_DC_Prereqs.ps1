Set-ExecutionPolicy Remotesigned -Force
$ipif = (Get-NetAdapter).ifIndex
$ipaddress = "x.x.x.x"
$ipprefix = "24"
$ipgw = "x.x.x.x"
$ipdns = "x.x.x.x"

New-NetIPAddress -IPAddress $ipaddress -PrefixLength $ipprefix `
                 -InterfaceIndex $ipif -DefaultGateway $ipgw
Set-DnsClientServerAddress -InterfaceIndex $ipif -ServerAddresses $ipdns

$newname = "DC1"
Rename-Computer -NewName $newname -Force

Add-WindowsFeature -Name "AD-Domain-Services" -IncludeAllSubFeature -IncludeManagementTools
Add-WindowsFeature -Name "DNS" -IncludeAllSubFeature -IncludeManagementTools
Add-WindowsFeature -Name "GPMC" -IncludeAllSubFeature -IncludeManagementTools

Restart-Computer -Force