Import-Module -Name ExchangeModule

$UserCredential = Get-AutomationPSCredential -Name 'Office365'

$ExchangeOnlineSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-Module (Import-PSSession -Session $ExchangeOnlineSession -AllowClobber -DisableNameChecking) -Global

Get-Mailbox -ResultSize Unlimited `
-Filter {RecipientTypeDetails -eq "UserMailbox" -or RecipientTypeDetails -eq "SharedMailbox" -or RecipientTypeDetails -eq "RoomMailbox" -or RecipientTypeDetails -eq "DiscoveryMailbox"} `
| Set-Mailbox -AuditEnabled $true `
-AuditLogAgeLimit 365 `
-AuditAdmin Update, MoveToDeletedItems, SoftDelete, HardDelete, SendAs, SendOnBehalf, Create `
-AuditDelegate Update, SoftDelete, HardDelete, SendAs, Create, MoveToDeletedItems, SendOnBehalf `
-AuditOwner Create, SoftDelete, HardDelete, Update, MoveToDeletedItems `
-Verbose

Get-PSSession | Remove-PSSession