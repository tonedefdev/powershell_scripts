Import-Module ActiveDirectory

$Users = Get-ADUser -Filter {Enabled -eq $true} -Properties Department | ? {$_.Department -eq "Corporate Finance"}

$Array = @()

foreach ($User in $Users) {
    $Membership = Get-ADPrincipalGroupMembership -Identity $User.SamAccountName

    $Hash = @{
        User = $User.Name
        Membership = (@($Membership.Name) -join ',')
    }

    $Object = New-Object -Type PSObject -Property $Hash
    $Array += $Object
}

$Array | Sort User | Export-CSV -Path "C:\users\$env:username\desktop\test.csv"

