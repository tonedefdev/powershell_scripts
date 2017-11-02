. "C:\users\aowens\desktop\SQL Licensing Project\Get_FileCSV.ps1"

Import-Module ActiveDirectory

$Path = Get-FileName

Import-CSV -Path $Path | foreach {
$User = $_.Name
$Disabled = Get-ADUser -Identity $User | Select-Object -ExpandProperty Enabled
if ($Disabled -eq $false) {
    Write-Host $User ": [" -NoNewline
    Write-Host "Disabled" -NoNewline -ForegroundColor Green
    Write-Host "]" -NoNewline
    "`n"   
} else {
    Write-Host $User ": [" -NoNewline
    Write-Host "Enabled" -NoNewline -ForegroundColor Red
    Write-Host "]" -NoNewline
}
}
