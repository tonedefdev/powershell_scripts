﻿Get-ADComputer -Filter {Enabled -eq $true} -Properties CanonicalName, Name, LastLogonDate | ? {($_.Name -like "*dental*")} | Sort-Object Name | Export-CSV -Path "C:\users\$env:username\desktop\dental.csv" -Append