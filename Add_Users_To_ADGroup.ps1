Import-Module ActiveDirectory
$list = Get-Content -Path "C:\Users\$env:USERNAME\Desktop\Reporting.txt"
$group = "NVA_Reporting"
foreach ($i in $list) {
    try {
        Get-ADUser -Identity $i | Add-ADPrincipalGroupMembership -MemberOf $group 
        Write-Host $i ":" "Added successfully to the group" -BackgroundColor DarkBlue 
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        Write-Host $i ":" "The user could not be found" -Background Red
    }
    catch [Microsoft.ActiveDirectory.Management.ADException] {
        Write-Host "You must run this script with elevated privileges!!!" -Background Red ; 
        $exitCMD = Read-Host "Enter [C] to close out of current session"
        if ($exitCMD -eq "C") {Exit}
    }
}

Write-Host "Press any key to end script" -BackgroundColor DarkMagenta
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")