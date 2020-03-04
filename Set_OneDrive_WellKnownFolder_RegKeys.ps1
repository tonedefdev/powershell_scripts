$user = "creyes"
$sid = "S-1-5-21-2076719491-258226757-709122288-26366"
$pathShellFolders = ".\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
$pathUserShellFolders = ".\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"

New-PSDrive -Name HKU -PSProvider Registry -Root HKU\$sid
Set-Location HKU:

Set-ItemProperty -Path $pathShellFolders -Name MyPictures -Value "C:\users\$user\OneDrive - ARE\Pictures" -WhatIf
Set-ItemProperty -Path $pathShellFolders -Name Personal -Value "C:\users\$user\OneDrive - ARE\Documents" -WhatIf
Set-ItemProperty -Path $pathUserShellFolders -Name MyPictures -Value "C:\users\$user\OneDrive - ARE\Pictures" -WhatIf
Set-ItemProperty -Path $pathUserShellFolders -Name Personal -Value "C:\users\$user\OneDrive - ARE\Documents" -WhatIf