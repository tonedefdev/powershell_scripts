Import-Module ActiveDirectory
$pfObjects = Get-Content "C:\users\admin.aowens\Desktop\pfobjectstoremove.txt"

foreach ($pf in $pfObjects)
{
    Get-ADObject -Identity $pf | Remove-ADObject -Confirm:$false
}