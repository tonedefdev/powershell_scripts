. "C:\users\aowens\desktop\SQL Licensing Project\Get-FileCSV.ps1"
Import-Module ActiveDirectory
$Computers = Get-FileCSV

$SourceFile = $Computers
$SourceHeadersDirty = Get-Content -Path $SourceFile -First 2 | ConvertFrom-Csv
$SourceHeadersCleaned = $SourceHeadersDirty.PSObject.Properties.Name.Trim(' ') -replace '\s' , ''
$SourceData = Import-CSV -Path $SourceFile -Header $SourceHeadersCleaned | Select-Object -Skip 1 | Select-Object -ExpandProperty DNSComputerName

$OU = Get-ADOrganizationalUnit -LDAPFilter "(name=.Support_Servers)" | Select-Object -ExpandProperty DistinguishedName

foreach ($Computer in $Sourcedata) {
    Get-ADComputer -Computer $Computer | Move-ADObject -TargetPath $OU -Verbose
}
