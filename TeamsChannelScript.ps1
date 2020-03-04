$UserCredential = Get-AutomationPSCredential -Name 'Office365'
$ExchangeOnlineSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-Module (Import-PSSession -Session $ExchangeOnlineSession -AllowClobber -DisableNameChecking) -Global

$GroupTemplate = (Get-AzureADDirectorySettingTemplate | ? {$_.DisplayName -eq "Group.Unified.Guest"})
$Groups = (Get-UnifiedGroup -ResultSize Unlimited | ? {$_.Classification -eq "Company Proprietary" -or $_.Classification -eq 'PII' })
 
foreach ($Group in $Groups) 
{
   $GroupSettings = Get-AzureADObjectSetting -TargetType Groups -TargetObjectId $Group.ExternalDirectoryObjectId 
   if ($GroupSettings) 
   {
      # Policy settings already exist for the group - so update them
      $GroupSettings["AllowToAddGuests"] = $False
      Set-AzureADObjectSetting -Id $GroupSettings.Id -DirectorySetting $GroupSettings -TargetObjectId $Group.ExternalDirectoryObjectId -TargetType Groups
      Write-Host "External Guest accounts prohibited for" $Group.DisplayName 
   } else {
      # Settings do not exist for the group - so create a new settings object and update
      $Settings = $GroupTemplate.CreateDirectorySetting()
      $Settings["AllowToAddGuests"] = $False
      New-AzureADObjectSetting -DirectorySetting $Settings -TargetObjectId $Group.ExternalDirectoryObjectId -TargetType Groups
      Write-Host "External Guest accounts blocked for"$Group.DisplayName 
   }
}