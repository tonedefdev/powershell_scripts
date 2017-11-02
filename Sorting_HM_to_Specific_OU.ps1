Import-Module ActiveDirectory

$OUs = Get-ADOrganizationalUnit -Filter * | Sort-Object

$OUs = $OUs.Name -match '(\d{3})'

$List = @()

Import-CSV -Path "C:\users\aowens\desktop\ous.csv" | foreach {

    $Number = $_.No
    $Hospital = $_.Hospital

    $Number = $Number + "*"

        foreach ($OU in $OUs) {

            if ($OU -like $Number) { 
            
                $OT = New-Object System.Object
                $OT | Add-Member -Type NoteProperty -Name OU -Value $OU
                $OT | Add-Member -Type NoteProperty -Name No -Value $Number
                $List += $OT
                
            }

        }
}

$Users = Get-ADUser -Filter {Enabled -eq $True} -Properties Description | ? {$_.Description -like "*Hospital Manager*"}

$Report = @()

foreach ($OU in $List) {

    $Number = "#" + $OU.No

    foreach ($User in $Users) {

        if ($User.Description -like $Number) {

            $OT1 = New-Object System.Object
            $OT1 | Add-Member -Type NoteProperty -Name Name -Value $User.Name
            $OT1 | Add-Member -Type NoteProperty -Name Username -Value $User.SamAccountName
            $OT1 | Add-Member -Type NoteProperty -Name Description -Value $User.Description
            $OT1 | Add-Member -Type NoteProperty -Name OU -Value $OU.OU
            $Report += $OT1

        }

    }

}

$Report | Export-CSV -Path "C:\users\$env:username\desktop\sortinglisthm.csv" -NoTypeInformation