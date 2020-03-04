Import-Module ActiveDirectory

$addToGroup = Import-Csv -Path "C:\users\admin.aowens\Documents\UnifierSSO.csv"
$server = "PS-DC01.labspace.com"
$group = "Unifier SSO"

foreach ($user in $addToGroup)
{
    $username = $user.Username
    Write-Host "Adding $username to group..."
    $userAccount = Get-ADUser -Filter {anr -eq $username}
    $userAccount | Add-ADPrincipalGroupMembership -MemberOf $group -Verbose
}