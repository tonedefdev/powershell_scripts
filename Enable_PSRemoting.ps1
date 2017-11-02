Import-Module ActiveDirectory 
$ADComputers = Get-ADComputer -Filter {(Enabled -eq $True)} -Properties OperatingSystem,DNSHostName | where {($_.OperatingSystem -like "*Windows Server 2008*") -or ($_.OperatingSystem -like "*Windows Server 2012*")} | Sort DNSHostName | Select-Object -ExpandProperty DNSHostName

foreach ($computer in $ADComputers) { C:\PsTools\PsExec.exe \\$computer -u "nva\itsupport" -p "M@rio22!" -h -d powershell.exe "enable-psremoting -force" ;
                                     $Session = New-PSSession -ComputerName $computer
                                     $ScriptBlock = {$env:COMPUTERNAME + "." + $env:USERDNSDOMAIN}
                                     $TestConnection = Invoke-Command -Session $Session -ScriptBlock $ScriptBlock

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