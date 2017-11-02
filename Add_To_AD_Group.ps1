Import-Module ActiveDirectory
$group = "NVA_Reporting"
$list = "C:\users\$env:username\desktop\resortmanagers.txt"
Write-Host "Adding users..." -ForegroundColor Yellow
"`n"
Import-CSV -Path "C:\Users\$env:username\desktop\Reporting.csv" | foreach {
$i = $_.Name
    try {
        Get-ADUser -Identity $i | Add-ADPrincipalGroupMembership -MemberOf $group
        Write-Host $i":" -NoNewline
        Write-Host " Added to the group" -ForegroundColor Green
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        Write-Host $i":" -NoNewline
        Write-Host " The user could not be found" -ForegroundColor Red
    }
    catch [Microsoft.ActiveDirectory.Management.ADException] {
        Write-Host "You must run this script with elevated privileges!!!" -Background Red ; 
        $exitCMD = Read-Host "Enter [C] to close out of current session"
        if ($exitCMD -eq "C") {Exit}
    }
}
"`n"
Write-Host "Running verification checks..." -ForegroundColor Yellow 
"`n"
Import-CSV -Path "C:\Users\$env:username\desktop\resortmanagers.csv" | foreach {
$i = $_.Name
        $verify = Get-ADUser -Identity $i | Get-ADPrincipalGroupMembership | where {($_.Name -like $group)}
            if ($verify.name -eq $group) {
                Write-Host $i":" -NoNewline
                Write-Host " Confirmed user was successfully added" -ForegroundColor Green 
            }
            else {
                Write-Host $i":" -NoNewline
                Write-Host " User was not successfully added" -ForegroundColor Red
            }
}
"`n"
Write-Host "Press any key to end script" -ForegroundColor Magenta
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")