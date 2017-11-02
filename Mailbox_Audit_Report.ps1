Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
$User = "HDPhotos"
$Date = Get-Date

$LogHT = @()

$Logs = Search-MailboxAuditLog $User -StartDate $Date.AddHours(-3) -LogonType Delegate -ExternalAccess $False -ShowDetails

foreach ($Log in $Logs) { 

    $LogReport = New-Object System.Object
    $LogReport | Add-Member -Type NoteProperty -Name User -Value ( " " + $Log.LogonUserDisplayName + " ")
    $LogReport | Add-Member -Type NoteProperty -Name Subject -Value ( " " +  $Log.ItemSubject + " ")
    $LogReport | Add-Member -Type NoteProperty -Name Folder -Value ( " " + $Log.FolderPathName + " ")
    $LogReport | Add-Member -Type NoteProperty -Name ClientIP -Value ( " " + $Log.ClientIPAddress + " ")
    $LogReport | Add-Member -Type NoteProperty -Name AccessTime -Value ( " " + $Log.LastAccessed + " ")
    $LogReport | Add-Member -Type NoteProperty -Name ObjectAccessed -Value ( " " + $Log.MailboxOwnerUPN + " ")
    $LogReport | Add-Member -Type NoteProperty -Name Operation -Value ( " " + $Log.Operation + " ")
    $LogReport | Add-Member -Type NoteProperty -Name OperationResult -Value ( " " + $Log.OperationResult + " ")
    $LogReport | Add-Member -Type NoteProperty -Name LogonType -Value ( " " + $Log.LogonType + " ")
    $LogHT += $LogReport

}

$PermissionHT = @()

$Permissions = Get-MailboxPermission -Identity $User 

foreach ($Permission in $Permissions) {

    $PermissionReport = New-Object System.Object
    $PermissionReport | Add-Member -Type NoteProperty -Name Identity -Value ( " " + $Permission.Identity + " ")
    $PermissionReport | Add-Member -Type NoteProperty -Name User -Value ( " " + $Permission.User + " ")
    $PermissionReport | Add-Member -Type NoteProperty -Name AccessRights -Value ( " " +  $Permission.AccessRights + " ")
    $PermissionReport | Add-Member -Type NoteProperty -Name Deny -Value ( " " + $Permission.Deny + " ")
    $PermissionHT += $PermissionReport
    
}

$AddedHT = @()

$Date = $Date.AddDays(-30)

$Initial = Search-AdminAuditLog | ? {$_.RunDate -gt $Date}

$Change = $Initial | ? {$_.CmdletName -eq "Add-MailboxPermission"}

foreach ($Add in $Change) {

    $AdditionReport = New-Object System.Object
    $AdditionReport | Add-Member -Type NoteProperty -Name "Who" -Value (" " + $Add.Caller + " ")
    $AdditionReport | Add-Member -Type NoteProperty -Name "What" -Value ( " " + $Add.ObjectModified + " ")
    $AdditionReport | Add-Member -Type NoteProperty -Name "When" -Value (" " + $Add.RunDate + " ")
    $AdditionReport | Add-Member -Type NoteProperty -Name "Where" -Value (" " + $Add.OriginatingServer + " ")
    $AddedHT += $AdditionReport

}

$Date = Get-Date

$HTMLHead = "<style>"
$HTMLHead = $HTMLHead + "BODY{background-color:white;}"
$HTMLHead = $HTMLHead + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$HTMLHead = $HTMLHead + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}"
$HTMLHead = $HTMLHead + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}"
$HTMLHead = $HTMLHead + "</style>"

$NVALogo = "http://i.imgur.com/idZOZ2g.jpg"

$HTMLBody = "<body>"
$HTMLBody = $HTMLBody + "<img src=$NVALogo>"
$HTMLBody = $HTMLBody + "<H2>Mailbox Audit Report | $Date </H2>"
$HTMLBody = $HTMLBody + "<H3>Access Audit</H3>"
$HTMLBody = $HTMLBody + "</body>"

$HTMLPermBody = "<body>"
$HTMLPermBody = $HTMLPermBody + "<H3>Mailbox Permissions for $User</H3>"
$HTMLPermBody = $HTMLPermBody + "</body>"

$HTMLAddBody = "<body>"
$HTMLAddBody = $HTMLAddBody + "<H3>Mailbox Permissions Added in Last 30 Days</H3>"
$HTMLAddBody = $HTMLAddBody + "</body>"

$LogHT | Export-CSV -Path "C:\users\aowens\desktop\daily.csv"

$LogHT | ConvertTo-Html -Head $HTMLHead -body $HTMLBody | Out-File "C:\users\aowens\desktop\test.htm" -Append

$PermissionHT | ConvertTo-Html -Head $HTMLHead -Body $HTMLPermBody | Out-File "C:\users\aowens\desktop\test.htm" -Append

$AddedHT | ConvertTo-Html -Head $HTMLHead -Body $HTMLAddBody | Out-File "C:\users\aowens\desktop\test.htm" -Append