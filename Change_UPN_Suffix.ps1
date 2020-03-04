$ou = "OU=Non_User_Accounts,DC=labspace,DC=com"
$Users = Get-ADUser -SearchBase $ou -Filter * | Select-Object -ExpandProperty SamAccountName

foreach ($User in $Users) {
    $newSuffix = $user + "@" + "are.com"
    Set-ADUser -Identity $User -UserPrincipalName $newSuffix -Verbose
}