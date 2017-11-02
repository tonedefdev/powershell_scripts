$filePath = "C:\Users\ittowens\desktop"
Get-ADUser -Filter {Enabled -eq $true} | Format-List Name,SamAccountName,DistinguishedName >> "$filePath\activeusers.txt"
