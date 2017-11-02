$Computers = Get-Content "C:\users\itsupport\desktop\computers.txt"

foreach ($Computer in $Computers) {
    C:\PsTools\PsExec.exe \\$computer -u "hospital\itsupport" -p "M@rio22!" -h -d powershell.exe "enable-psremoting -force" ;
    $ScriptBlock = {$env:COMPUTERNAME + "." + $env:USERDNSDOMAIN}
    $TestConnection = Invoke-Command -ComputerName $computer -ScriptBlock $ScriptBlock

        if ($TestConnection -eq $computer) {
            Write-Host $computer": " -NoNewline
            Write-Host "PSRemoting Enabled!" -ForegroundColor Green -NoNewline
            }

        elseif ($TestConnection -ne $computer) {
            Write-Host $computer": " -NoNewline
            Write-Host "PSRemoting was not enabled, check settings and try again" -ForegroundColor Red -NoNewline
            }
}

Write-Host "Press any key to end script" -BackgroundColor DarkMagenta
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")