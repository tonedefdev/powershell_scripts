$badges = Import-Csv -Path "C:\users\aowens\desktop\allcards.csv"

$array = @()

foreach ($badge in $badges)
{
    if ($badge.Badge -match '\d\d\d\d\d\d\d')
    {
        $hash = @{
            Badge = $badge.Badge
            Name = $badge.Name
        }

        $object = New-Object -TypeName PSObject -Property $hash
        $array += $object
    }
}

$array | Sort-Object Name | Export-Csv -Path "C:\users\aowens\desktop\sortedbadges.csv" -NoTypeInformation