Function Create-Printer-Port {
[CmdletBinding()]
param ($PrinterIP, $PrinterPort, $PrinterPortName, $Computer)
    $wmi = [wmiclass]"\\$env:COMPUTERNAME\root\cimv2:win32_tcpipPrinterPort"
    $wmi.Psbase.Scope.Options.enablePrivileges = $true
    $Port = $wmi.createInstance()
    $Port.Name = $PrinterPortName
    $Port.HostAddress = $NewIP
    $Port.portNumber = "9100"
    $Port.SNMPEnabled = $false
    $Port.Protocol = 1
    $Port.Put()
}
        
$PrintRegistryValue = "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers\"
$Value = Get-ChildItem -Path $PrintRegistryValue | Select-Object -ExpandProperty Name
$PrintRegistry = $Value -match "(Test Printer)"
$PrintRegistryPath = $PrintRegistry -replace "^(HKEY_LOCAL_MACHINE)"
$PrintRegistryPath = "HKLM:" + $PrintRegistryPath

$Name = Get-ItemProperty -Path $PrintRegistryPath | Select-Object -ExpandProperty Name
$CurrentPort = Get-ItemProperty -Path $PrintRegistryPath | Select-Object -ExpandProperty Port
$NewIP = "10.1.1.212"
       
Write-Host "Computer: " -NoNewline
Write-Host $env:COMPUTERNAME -ForegroundColor Cyan
Write-Host "Printer Name: " -NoNewline
Write-Host $Name -ForegroundColor Cyan
Write-Host "Current Port: " -NoNewline
Write-Host $CurrentPort -ForegroundColor Cyan
        
"`n"
        
if(!(Get-Wmiobject Win32_tcpipprinterport | ? {$_.HostAddress -eq $NewIP})) {
        
    Write-Host "Creating printer port" $NewIP -ForegroundColor Yellow
            
    Create-Printer-Port -PrinterIP $NewIP -PrinterPort $NewIP -PrinterPortName $NewIP -Computer $env:COMPUTERNAME | Out-Null
            
        if(!(Get-Wmiobject Win32_tcpipprinterport | ? {$_.HostAddress -eq $NewIP})) {
                    
            Write-Host "Error creating printer port!" -ForegroundColor Red
            Return
                    
            } else { 
                    
            Write-Host "Printer port successfully created!" -ForegroundColor Green

            "`n"
        
            }
}
              
Set-ItemProperty -Path $PrintRegistryPath -Name Port -Value $NewIP -Force

Set-ItemProperty -Path $PrintRegistryPath -Name Description -Value $NewIP -Force

New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Print" -Name "SNMPLegacy" -PropertyType DWORD -Value "1" -Force | Out-Null
        
Stop-Service -DisplayName 'Print Spooler' -Force

Start-Service -DisplayName 'Print Spooler'
        
$CurrentPort = Get-ItemProperty -Path $PrintRegistryPath | Select-Object -ExpandProperty Port
        
Write-Host "Printer Name: " -NoNewline
Write-Host $Name -ForegroundColor Green
Write-Host "New Port: " -NoNewline
Write-Host $CurrentPort -ForegroundColor Green

"`n"