$CurrentPath = Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path
. "$CurrentPath\Get_SQLVersion.ps1"
$ObjectHT = @()

Import-CSV -Path "$CurrentPath\ms_licensing_iland.csv" | foreach {

$_.ComputerName = $Computer

$OSVersion = (Get-WmiObject -ComputerName $Computer -Class Win32_OperatingSystem).Caption

$CPUS = (Get-WmiObject -ComputerName $Computer -Class Win32_Processor)
$CPUCount = @() 
foreach ($CPU in $CPUS.Caption) {
$CPUCount += 1
}

$SQLVersion = Get-SQLVersion -Computer $Computer

$OfficeVersion = Get-WmiObject -ComputerName $Computer -Class Win32_Product | where { $_.name -like '*office standard*' }

$AuditReport = New-Object System.Object
$AuditReport | Add-Member -Type NoteProperty -Name Server -Value $Computer
$AuditReport | Add-Member -Type NoteProperty -Name OperatingSystem -Value $OSVersion
$AuditReport | Add-Member -Type NoteProperty -Name CPUCores -Value $CPUCount.Count
$AuditReport | Add-Member -Type NoteProperty -Name SQLVersion -Value $SQLVersion
$AuditReport | Add-Member -Type NoteProperty -Name OfficeVersion -Value $OfficeVersion.Name
$ObjectHT += $AuditReport

}

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
$HTMLBody = $HTMLBody + "</body>"

$ObjectHT | ConvertTo-Html -Head $HTMLHead -body $HTMLBody | Out-File "C:\Temp\MS_Licensing.htm"
$OBjectHT | Export-CSV -Path "C:\Temp\MS_Licensing.csv"