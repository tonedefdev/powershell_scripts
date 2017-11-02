$KaseyaServices = Get-Service | ? {$_.Name -like "Kaseya*"}
foreach ($Service in $KaseyaServices.Name) {
Start-Service -Name $Service -Verbose -ErrorAction Ignore -Force
}

