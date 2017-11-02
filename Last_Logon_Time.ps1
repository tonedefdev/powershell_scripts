$Computer = $env:COMPUTERNAME
 
$Profiles = gwmi win32_userprofile -ComputerName $Computer | Where-Object {($_.SID -notmatch "^S-1-5-\d[18|19|20]$")} # ignore system account profiles
 
# Empty Array of Profiles
$colProfiles = @()
 
foreach ($Profile in $Profiles)
{
Try{
# Get the SID of the account who had logged in
$UserSID = New-Object System.Security.Principal.SecurityIdentifier($Profile.SID)
 
# Get the Domain\Username details from the SID
$User = $UserSID.Translate([System.Security.Principal.NTAccount])
 
# Get the DateTime values
$Time = ([WMI] '').ConvertToDateTime($Profile.LastUseTime)
$LogonTime = $Time.ToShortTimeString()
$LogonDate = $Time.ToShortDateString()
 
# Create an Object with the $User, $LogonDate &amp; $LogonTime properties
$LastLogons = New-Object system.object
$LastLogons | Add-Member -MemberType noteproperty -Name UserName -Value $User
$LastLogons | Add-Member -MemberType noteproperty -Name LastLogonDate -Value $LogonDate
$LastLogons | Add-Member -MemberType noteproperty -Name LastLogonTime -Value $LogonTime
 
# Populate the properties of the $LastLogons object with User, Logon Date and Time from the profiles
$colProfiles += $LastLogons 
}
 
Catch [System.Exception]
{
"Cannot query a local account's SID against the Domain"
}
 
Finally {}
}
 
$colProfiles | Sort LastLogonDate | ft -AutoSize | Out-File "C:\Users\$env:username\Desktop\LastLogonTime.txt"