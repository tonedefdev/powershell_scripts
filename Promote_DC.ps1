Import-Module ADDSDeployment

$pathNTDS = "C:\Windows\NTDS"
$pathSYSVOL = "C:\Windows\SYSVOL"

Install-ADDSDomainController `
-NoGlobalCatalog:$false `
-CreateDNSDelegation:$false `
-Credential (Get-Credential) `
-CriticalreplicationOnly:$false `
-DatabasePath $pathNTDS `
-DomainName "domain.com"
-InstallDns:$False `
-LogPath $pathNTDS `
-NoRebootOnCompletion:$false `
-ReplicationSourceDC "dc.domain.com"
-SiteName "Default-First-Site-Name"
-SysvolPath $pathSYSVOL
-Force:$true
