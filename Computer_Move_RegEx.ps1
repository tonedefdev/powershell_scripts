Import-Module ActiveDirectory

$Computers = Get-ADComputer -SearchBase "CN=Computers,DC=NVA,DC=local" -Filter {Enabled -eq $True} | Select-Object -ExpandProperty Name | Sort-Object

$Computers = $Computers -match '^[0-9]{3}'

$OUs = Get-ADOrganizationalUnit -Filter * | Sort-Object

$OUs = $OUs.Name -match '(\d{3})'

$List = @()

foreach ($Computer in $Computers) {
        
    $Replaced = $Computer -replace '([A-Z])'
    $Replaced = $Replaced -match  '(\d{3})'
            
    $OT = New-Object System.Object
    $OT | Add-Member -Type NoteProperty -Name ComputerName -Value $Computer
    $OT | Add-Member -Type NoteProperty -Name Match -Value $Matches.Values
    $List += $OT

}

$Report = @()

foreach ($Item in $List) {

    $Reg = ($Item.Match | Get-Unique) + "*"
    
    foreach ($OU in $OUs) {

        if ($OU -like $Reg) {
                
                $OT1 = New-Object System.Object
                $OT1 | Add-Member -Type NoteProperty -Name ComputerName -Value $Item.ComputerName
                $OT1 | Add-Member -Type NoteProperty -Name OUMatch -Value $OU
                $Report += $OT1

        }
    }
}

$Report | Export-CSV "C:\users\aowens\desktop\serversnotinou.csv"