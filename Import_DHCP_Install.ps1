Import-Module ServerManager
$Server = Read-Host "Enter DHCP server name to import settings from"
$Path = Read-Host "Enter path to export settings file to"
$DHCP = Get-WindowsFeature -Name "DHCP"

if (!($DHCP.Installed))
{
    Add-WindowsFeature -Name "DHCP" -IncludeManagementTools -Verbose
}

if (!(Test-Path -Path "C:\DhcpBackup\"))
{
    New-Item -ItemType Directory -Path "C:\DhcpBackup" -Force -Verbose
}

Export-DhcpServer -ComputerName $Server -File "$($Path)\dhcpscopes.xml" -Leases -Verbose
Import-DhcpServer -ComputerName $env:COMPUTERNAME -File "$($Path)\dhcpscopes.xml" -Leases -BackupPath "C:\DhcpBackup\" -Verbose