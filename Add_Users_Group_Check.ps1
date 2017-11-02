Import-Module ActiveDirectory

$Group = "NVA Dentistry Program Hospital MDVMs"

Import-CSV -Path "C:\users\$env:username\desktop\sortinglistmdvm.csv" | foreach {

    $Username = $_.Username
    $Name = $_.Name

    Get-ADUser -Identity $Username | Add-ADPrincipalGroupMembership -MemberOf $Group -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

}

$CheckList = Get-ADGroupMember -Identity $Group

Import-CSV -Path "C:\users\$env:username\desktop\sortinglistmdvm.csv" | foreach {

    $Username = $_.Username
    $Name = $_.Name

    if ($CheckList.Name -eq $Name) {
        
        Write-Host $Username " was added to the group" -ForegroundColor Green
            
        } else {
            
        Write-Host $Username " was not added" -ForegroundColor Red

        }
}