Add-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.SnapIn

Get-OwaVirtualDirectory -Server $env:COMPUTERNAME | Set-OwaVirtualDirectory -InternalUrl "https://mail.are.com/owa" -ExternalUrl "https://mail.are.com/owa"
Get-EcpVirtualDirectory -Server $env:COMPUTERNAME | Set-EcpVirtualDirectory -InternalUrl "https://mail.are.com/ecp" -ExternalUrl "https://mail.are.com/ecp"
Get-WebServicesVirtualDirectory -Server $env:COMPUTERNAME | Set-WebServicesVirtualDirectory -InternalUrl "https://mail.are.com/EWS/Exchange.asmx" -ExternalUrl "https://mail.are.com/EWS/Exchange.asmx" -MRSProxyEnabled $true
Get-MapiVirtualDirectory -Server $env:COMPUTERNAME | Set-MapiVirtualDirectory -InternalUrl "https://mail.are.com/mapi" -ExternalUrl "https://mail.are.com/mapi"
Get-OabVirtualDirectory -Server $env:COMPUTERNAME | Set-OabVirtualDirectory -InternalUrl "https://webmail.are.com/OAB" -ExternalUrl "https://webmail.are.com/OAB"
Get-ActiveSyncVirtualDirectory -Server $env:COMPUTERNAME | Set-ActiveSyncVirtualDirectory -InternalUrl "https://mail.are.com/Microsoft-Server-ActiveSync" -ExternalUrl "https://mail.are.com/Microsoft-Server-ActiveSync"

Get-OwaVirtualDirectory -Server $env:COMPUTERNAME | Select Server,Internalurl,ExternalUrl
Get-EcpVirtualDirectory -Server $env:COMPUTERNAME | Select Server,Internalurl,ExternalUrl
Get-WebServicesVirtualDirectory -Server $env:COMPUTERNAME | Select Server,Internalurl,ExternalUrl
Get-MapiVirtualDirectory -Server $env:COMPUTERNAME | Select Server,Internalurl,ExternalUrl
Get-OabVirtualDirectory -Server $env:COMPUTERNAME | Select Server,Internalurl,ExternalUrl
Get-ActiveSyncVirtualDirectory -Server $env:COMPUTERNAME | Select Server,Internalurl,ExternalUrl