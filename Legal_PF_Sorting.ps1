$Massaged = @()

Import-CSV -Path "C:\users\admin.aowens\Desktop\legal_pf.csv" | foreach {

    $Root = $_.Root
    $Child = $_.Child
    $Subfolder = $_.Subfolder

    $Hash = @{
        Root = $Root
        Child = $Child.TrimEnd()
        Subfolder = $Subfolder
    }

    $Object = New-Object -Type PSObject -Property $Hash
    $Massaged += $Object
}

$Massaged | Select-Object Root,Child,Subfolder | Export-Csv -Path "C:\users\admin.aowens\desktop\legal_pf_sorted.csv" -NoTypeInformation