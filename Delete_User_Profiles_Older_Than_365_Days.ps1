﻿Get-WmiObject -Class Win32_UserProfile | where {(!$_.Special) -and ($_.LocalPath -notlike "*administrator*") -and ($_.LocalPath -notlike "*citrix*") -and ($_.LocalPath -notlike "*classic*")-and ($_.ConvertToDateTime($_.LastUseTime) -lt (Get-Date).AddDays(-365))} | Remove-WmiObject