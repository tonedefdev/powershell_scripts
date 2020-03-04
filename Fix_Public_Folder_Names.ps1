$CSV = Import-Csv -Path "C:\users\aowens\desktop\pfswithslashes.csv"
$Count = $CSV.Length
$Array = @()

for ($i = 0; $i -lt $Count; $i++)
{
    if ($CSV[$i] -match "\/")
    {
        $Identity = $CSV[$i].Identity
        $NewName = $CSV[$i].Name -replace "\/", "-"
        $Hash = @{
            Identity = $Identity
            NewName = $NewName
        }
        $Object = New-Object -TypeName PSObject -Property $Hash
        $Array += $Object
    }
}

for ($i = 0; $i -lt $Count; $i++)
{
    if ($CSV[$i] -match "\\")
    {
        $Identity = $CSV[$i].Identity
        $NewName = $CSV[$i].Name -replace "\\", "-"
        $Hash = @{
            Identity = $Identity
            NewName = $NewName
        }
        $Object = New-Object -TypeName PSObject -Property $Hash
        $Array += $Object
    }
}

$Array | Select Identity,NewName | Sort | Export-Csv -Path "C:\users\aowens\desktop\NewPublicFolderNames.csv" -NoTypeInformation