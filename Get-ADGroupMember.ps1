Import-Module Active Directory
$Group = "Terminal Server License Servers"
Get-ADGroupMember -Identity $Group | Select-Object -ExpandProperty Name | Out-File "C:\Users\$env:username\Desktop\$Group.txt"