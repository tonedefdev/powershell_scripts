. "C:\PSScripts\Get_SQLVersion.ps1"
. "C:\PSScripts\Get_Time_Function.ps1"
. "C:\PSScripts\Get_DHCPCount.ps1"
. "C:\PSScripts\Get_FileName.ps1"

$Computers = Get-Content -Path (Get-FileName -ErrorAction SilentlyContinue) -ErrorAction SilentlyContinue

$timeStart = (Get-Time)

$ObjectHT = @()

foreach ($Computer in $Computers) {

    $OSVersion = (Get-WmiObject -ComputerName $Computer -Class Win32_OperatingSystem).Caption

    $CPUS = Get-WmiObject -ComputerName $Computer -class Win32_processor | Select -ExpandProperty NumberOfLogicalProcessors -First 1

    $HostCount = Get-DHCPCount -Computer $Computer

    $SQLVersion = Get-SQLVersion -Computer $Computer

    $OfficeVersion = Get-WmiObject -ComputerName $Computer -Class Win32_Product | where { ($_.name -like '*office standard*') -or ($_.name -like '*office professional*') }

    $AuditReport = New-Object System.Object
    $AuditReport | Add-Member -Type NoteProperty -Name Server -Value $Computer
    $AuditReport | Add-Member -Type NoteProperty -Name OperatingSystem -Value $OSVersion
    $AuditReport | Add-Member -Type NoteProperty -Name DeviceCALs -Value $HostCount.HostCount
    $AuditReport | Add-Member -Type NoteProperty -Name CPUCores -Value $CPUS
    $AuditReport | Add-Member -Type NoteProperty -Name SQLVersion -Value $SQLVersion
    $AuditReport | Add-Member -Type NoteProperty -Name OfficeVersion -Value $OfficeVersion.Name
    $ObjectHT += $AuditReport

}

$timeEnd = (Get-Time)

$HTMLHead = "<style>"
$HTMLHead = $HTMLHead + "BODY{background-color:white;}"
$HTMLHead = $HTMLHead + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$HTMLHead = $HTMLHead + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}"
$HTMLHead = $HTMLHead + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}"
$HTMLHead = $HTMLHead + "</style>"

$NVALogo = "http://i.imgur.com/idZOZ2g.jpg"

$HTMLBody = "<body>"
$HTMLBody = $HTMLBody + "<img src=$NVALogo>"
$HTMLBody = $HTMLBody + "<H2>MS Licensing Audit</H2>"
$HTMLBody = $HTMLBody + "<H3>Audit Started: $timeStart | Audit Completed: $timeEnd</H3>"
$HTMLBody = $HTMLBody + "</body>"

$ObjectHT | ConvertTo-Html -Head $HTMLHead -body $HTMLBody | Out-File "C:\Temp\MS_Licensing.htm"
$OBjectHT | Export-CSV -Path "C:\Temp\MS_Licensing.csv"

$From = "helpdesk@nvanet.com"
$Recipients = @("Alex Davis <adavis@nvanet.com>", "Anthony Owens <aowens@nvanet.com>")
$Subject = "NVA Microsoft Licensing Audit"
$SMTPServer = "nvaexch.nva.local"
$Body = Get-Content "C:\Temp\MS_Licensing.htm" | Out-String
$Attachments = @("C:\Temp\MS_Licensing.csv")

#if ($Body -ne $null) {
#   Send-MailMessage -From $From -To $Recipients -Subject $Subject -BodyAsHTML $Body -Attachments $Attachments -SmtpServer $SMTPServer 
#}