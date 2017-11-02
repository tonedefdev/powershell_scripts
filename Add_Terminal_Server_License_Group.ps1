Import-Module ActiveDirectory
$computers = Get-Content -Path "C:\Users\$env:USERNAME\Desktop\rdsgroup.txt"
d$rdsGroup = "Terminal Server License Servers"
foreach ($i in $computers) {
    try {
        Get-ADComputer $i | Add-ADPrincipalGroupMembership -MemberOf "$rdsGroup"
        Write-Host $i":" "Added successfully to the group" -BackgroundColor DarkBlue 
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        Write-Host $i":" "The computer could not be found" -Background Red
    }
    catch [Microsoft.ActiveDirectory.Management.ADException] {
        Write-Host "You must run this script with elevated privileges!!!" -Background Red ; 
        $exitCMD = Read-Host "Enter [C] to close out of current session"
        if ($exitCMD -eq "C") {Exit}
    }
}