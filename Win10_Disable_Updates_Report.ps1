Function Add-HTMLTableAttribute
{
    Param
    (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $HTML,

        [Parameter(Mandatory=$true)]
        [string]
        $AttributeName,

        [Parameter(Mandatory=$true)]
        [string]
        $Value

    )

    $xml=[xml]$HTML
    $attr=$xml.CreateAttribute($AttributeName)
    $attr.Value=$Value
    $xml.table.Attributes.Append($attr) | Out-Null
    Return ($xml.OuterXML | out-string)
}

$List = "C:\PSScripts\Win10_Disable_Updates.csv"

$UpdateReportHT = @()

Import-CSV -Path $List | foreach {

    $Name = $_.Hostname
    $IP = $_.InternalIPAddress

        $ScriptTest = [bool](Test-WSMan -ComputerName $IP -ErrorAction SilentlyContinue)

        if ($ScriptTest -eq $true) {

            $UpdateFix = "Pass"

            Write-Host ($Name + ": " + $UpdateFix)

            "`n"

        } else {

            $UpdateFix = "Fail"

            Write-Host ($Name + ": " + $UpdateFix)

            "`n"

        }

    $UpdateReport = New-Object System.Object
    $UpdateReport | Add-Member -Type NoteProperty -Name Computer -Value $Name
    $UpdateReport | Add-Member -Type NoteProperty -Name IPAddress -Value $IP
    $UpdateReport | Add-Member -Type NoteProperty -Name Win10ScriptFix -Value $UpdateFix
    $UpdateReportHT += $UpdateReport

}

$CSS = @'

<style>

body {

    background-color:#4CAF50;
    padding: 25px;
    
}

p, h1, h2, h3 {

    font-family: Calibri;
    text-align: center;
    
}

img {
    
    display: block;
    margin: 0 auto;
    
}

div.background {
    
        margin: 0 auto;
        padding: 45px;
        display: table;
        overflow: hidden;
        height: 1%;
        border-style: solid;
        border-color: white;
        background-color: white;
        border-radius: 15px;
        box-shadow: 2px 2px 15px 1px black; 
        -moz-box-shadow: 2px 2px 15px 1px black;
        
}

div.footer {
    
        padding: 25px;
        text-align: center;
        font-family: Calibri;
    
}

table.Log {
    
    margin: 0px auto; 
    border-width: 1px; 
    border-style: solid; 
    border-color: white; 
    border-collapse: collapse; 
    border-spacing: 0; 
    box-shadow: 5px 5px 5px #999; 
    -moz-box-shadow: 5px 5px 5px #999
    
}

.Log th {
    
    font-family: Calibri; 
    text-align: center; 
    border-width: 1px; 
    padding: 5px; 
    border-style: solid; 
    border-color: white; 
    border-bottom: 1px solid #ddd; 
    background-color: #4CAF50; 
    color: white
    
}
    
.Log th:first-child {border-radius: 6px 0 0 0;}
.Log th:last-child {border-radius: 0 6px 0 0;}
.Log th:only-child {border-radius: 6px 6px 0 0;}

.Log td {

    font-family: Calibri; 
    text-align: left; 
    border-width: 1px;
    padding: 5px;
    border-style: solid;
    border-color: white; 
    border-bottom: 1px solid #ddd
    
}

.Log tr:nth-child(even) {background-color: #f2f2f2}
.Log tr:hover {background-color:#A9A9A9}

</style>
'@

$UpdateReportHT | Select-Object Computer,IPAddress,Win10ScriptFix | Export-Csv -Path "C:\Temp\Win10UpdateReport.csv" -Force

$NVALogo = "http://i.imgur.com/idZOZ2g.jpg"

$HTMLBody = "<div class='background'>"
$HTMLBody = $HTMLBody + "<img src=$NVALogo>"
$HTMLBody = $HTMLBody + "<H2>Win 10 Update Fix Report</H2>"
$HTMLBody = $HTMLBody + "</body>"

$HTMLFooter = "<div class='footer'>"
$HTMLFooter = $HTMLFooter + "<p>&copy 2017 National Veterinary Associates</p>"
$HTMLFooter = $HTMLFooter + "</div>"
$HTMLFooter = $HTMLFooter + "</div>"

$Report = $UpdateReportHT | ConvertTo-Html -Fragment | Out-String | Add-HTMLTableAttribute -AttributeName 'class' -Value 'Log'

ConvertTo-Html -Head $CSS -body ($HTMLBody + $Report + $HTMLFooter) | Out-File "C:\Temp\Win10UpdateReport.htm" -Force

$from = "helpdesk@nvanet.com"
$recipients = @("Alex Davis <adavis@nvanet.com>", "Alfonso Guardado <aguardado@nvanet.com>", "Anthony Owens <aowens@nvanet.com>", "Patrick Hong <phong@nvanet.com>")
$subject = "NVA Server Audit Report"
$SMTPServer = "nvaexch.nva.local"
$body = "See attached for Win 10 update script progress"
$attachments = @("C:\Temp\Wind10UpdateReport.csv", "C:\Temp\Wind10UpdateReport.htm")

if ($attachments -ne $null) {
    Send-MailMessage -From $from -To $recipients -Subject $subject -Body $body -Attachments $attachments -SmtpServer $SMTPServer 
}