. "C:\users\aowens\desktop\SQL Licensing Project\Get_FileCSV.ps1"

Import-Module ActiveDirectory

$Path = Get-FileName

Import-CSV -Path $Path | foreach {
$User = $_.Name
Get-ADUser -Identity $User | Disable-ADAccount
}

