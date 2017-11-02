Import-Module ActiveDirectory
do 
    {    
        $Group = Read-Host ("`n" + "Please, enter the Active Directory group name")
        if ($Group -ne "") 
        {
            try 
            {
                "`n" + $Group + "`n" + "==============================================================================" + "`n" ; 
                Write-Host "Searching for " -NoNewline 
                Write-Host $Group -NoNewline -ForegroundColor Green
                Write-Host " if found a list of users will be exported to desktop" -NoNewline
                "`n" + "`n" + "==============================================================================" ; 
                Get-ADGroupMember -Identity $Group -ErrorAction Stop | Select-Object -ExpandProperty name | Sort name | Out-File C:\Users\$env:username\Desktop\$Group.csv
            }
            catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
            {
                Write-Host $Group ":" " The Active Directory group name was not found" -Background Red ; Remove-Item -Path C:\Users\$env:username\Desktop\$Group.csv
            }
        } 
    }
while ($Group -ne "")