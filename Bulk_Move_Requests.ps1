Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
Import-Module ActiveDirectory
. "C:\Program Files\WindowsPowerShell\function-Get_FileName.ps1"

$CSV = Get-FileName

Import-Csv -Path $CSV | foreach {
    $User = $_.Email
    $DB = $_.Database

    switch ($DB)
    {
        "DB01" {$EDB = "DB01_16"}
        "DB02" {$EDB = "DB02_16"}
        "DB03" {$EDB = "DB03_16"}
        "DB05" {$EDB = "DB05_16"}
    }

    New-MoveRequest -Identity $User -TargetDatabase $EDB -DomainController "PS-DC01.labspace.com" -BadItemLimit 30 -Priority High -PreventCompletion:$true -AllowLargeItems -Verbose
}