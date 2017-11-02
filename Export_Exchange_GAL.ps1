$filter = "((Alias -ne `$null) -and (HiddenFromAddressListsEnabled -ne `$true) -and (((ObjectClass -eq 'user') -or (ObjectClass -eq 'contact') -or (ObjectClass -eq 'msExchSystemMailbox')))"

Get-Recipient -RecipientPreviewFilter $filter -ResultSize Unlimited | Select-Object Name,PrimarySmtpAddress | Export-CSV c:\GAL.csv -NoTypeInformation