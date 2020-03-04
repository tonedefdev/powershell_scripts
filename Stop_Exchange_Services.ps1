$ExchangeServices = Get-Service | ? {$_.DisplayName -like "Microsoft Exchange*"}
foreach ($Service in $ExchangeServices) {Stop-Service -DisplayName $Service.DisplayName -Force -Verbose}