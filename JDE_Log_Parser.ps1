function Get-Simple-Time {
    $hour =  (Get-Date).Hour

    $minute = (Get-Date).Minute

$date = "$hour" + "_" + "$minute"
$date
}

function Get-Simple-Date {
    $day =  (Get-Date).Day

    $month = (Get-Date).Month

    $year = (Get-Date).Year

$date = "$month" + "_" + "$day" + "_" + "$year"
$date
} 

Do {
    $Servers = @("PS-PJDE-UBE","PS-PJDE-APP1","PS-PJDE-APP2")

    foreach ($Server in $Servers) {    
        $JDE = "\\$Server\D$\JDEdwardsPPack\E920\log"
        $Logs = Get-ChildItem -Path $JDE | ? {$_.LastWriteTime -ge (Get-Date).AddDays(-7)}

        $Array = @()

        foreach ($Log in $Logs) {
            $Log = $Log.Name
            $Path = "$JDE\$Log"

            if ($Path -like "*.lck") {
                Continue
            }

            if ($Path -like "*jdedebug*") {
                Continue
            }

            $Content = Get-Content -Path $Path -ErrorAction SilentlyContinue
            $Count = $Content.Count

            for ($i = 0; $i -lt $Count; $i++) {
                if ($Content[$i] -match "ODB0000162 - Connection lost during earlier operation.") {
                    $Array += $Server
                    $StepBack = $i - 1
                    $Array += $Content[$StepBack]
                    $Array += $Content[$i]
                    $StepForward = $i + 10
                    $Range = ($i + 1)..$StepForward
                
                    foreach ($i in $Range) {
                        $Array += $Content[$i]
                    }
                }
            }
        }
    }

    if ($Array.Count -ge 1) {
        $Date = Get-Simple-Date
        $Time = Get-Simple-Time
        $Full = $Date + "." + $Time
        $Array | Out-File -FilePath "C:\Temp\JDE\$Full.JDELog.log"
        $JDELog = "C:\Temp\JDE\$Full.JDELog.log"

        Send-MailMessage -SmtpServer "PS-EXCH01" -Subject "JDE DB Disconnect Alert" -Attachments $JDELog -From "JDE_Log_Parser@are.com" -To "SysAdmins@are.com" -CC "skhalatian@are.com" -Priority High
    }

    Start-Sleep -Seconds 300
}
While([bool](Test-Connection -Count 2 "localhost") -eq $true)
