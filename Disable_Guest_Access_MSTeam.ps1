
$GroupTemplate = (Get-AzureADDirectorySettingTemplate | ? {$_.DisplayName -eq "Group.Unified.Guest"})
$Groups = (Get-UnifiedGroup -ResultSize Unlimited | Where {$_.Classification -eq "Company Proprietary" or $_.Classification -eq 'PII' })
 
ForEach ($Group in $Groups) {
    $GroupSettings = Get-AzureADObjectSetting -TargetType Groups -TargetObjectId 
              $Group.ExternalDirectoryObjectId 
    if($GroupSettings) {
       # Policy settings already exist for the group - so update them
       $GroupSettings["AllowToAddGuests"] = $False
       Set-AzureADObjectSetting -Id $GroupSettings.Id -DirectorySetting $GroupSettings
                 -TargetObjectId $Group.ExternalDirectoryObjectId -TargetType Groups
       Write-Host "External Guest accounts prohibited for" $Group.DisplayName 
    }
    Else
    {
       # Settings do not exist for the group - so create a new settings object and update
       $Settings = $GroupTemplate.CreateDirectorySetting()
       $Settings["AllowToAddGuests"] = $False
       New-AzureADObjectSetting -DirectorySetting $Settings -TargetObjectId 
               $Group.ExternalDirectoryObjectId -TargetType Groups
       Write-Host "External Guest accounts blocked for"$Group.DisplayName 
    }
}