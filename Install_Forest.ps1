$domainname = "domain.com"
$netBIOSName = "DC1"
$pathNTDS = "C:\Windpws\NTDS"
$pathSYSVOL = "C:\Windows\SYSVOL"

Import-Module ADDSDeployment
Install-ADDSforest -CreateDNSDelegation:$false `
    -DatabasePath $pathNTDS `
    -DomainMode "Win2012" `
    -DomainName $domainname `
    -DomainNetbiosName $netBIOSName `
    -ForestMode "Win2012" `
    -InstallDNS:$true `
    -LogtPath $pathNTDS `
    -NoRebotOnCompletion:$false `
    -SysvolPath $pathSYSVOL `
    -Force:$true   