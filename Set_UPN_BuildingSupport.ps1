Import-Module ActiveDirectory

$Server = "buildingsupport.labspace.com"

$Users = Get-ADUser -Server $Server -SearchBase "OU=Engineers,DC=buildingsupport,DC=labspace,DC=com" -Filter {Enabled -eq $true}

foreach ($User in $Users)
{
    $UPN = "$($User.SamAccountName)@buildingsupport.net"
    Set-ADUser -Server $Server -Identity $User.SamAccountName -UserPrincipalName $UPN -Verbose
}