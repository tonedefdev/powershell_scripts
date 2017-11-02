$Computers = Get-Content -Path "C:\users\aowens\desktop\servers.txt"

foreach ($Computer in $Computers) {

        if ((Test-Connection -Count 2 -Computer $Computer) -eq $false) {
        Write-Log -Level "ERROR" -Path $LogPath -Variable $Computer -Message "Unable to connect to server"
        Write-Host "Unable to connect to server" -ForegroundColor Red
        Continue

        } else {

    $ScriptBlock = {
        Function Write-Log {
            [CmdletBinding()]
            Param(
            [Parameter(
                Mandatory=$False)]
            [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
            [String]
            $Level = "INFO",

            [Parameter(
                Mandatory=$True)]
            [string]$Message,
            
            [Parameter(
                Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True)]
            [string]$Variable,

            [Parameter(
            Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
            [string]$Path
            )

            $Stamp = (Get-Date).toString("MM/dd/yyyy HH:mm:ss")
            $Line = "$Stamp $Level - $Variable : $Message"
            If($Path) {
                Add-Content $Path -Value $Line
            }
            Else {
                Write-Output $Line
            }
        }

        $LogPath = "\\10.252.70.3\PrinterErrorLogs\Errors.txt"
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
        $PrintRegistry = $Value -match "(Call Center)"
        $PrintRegistryPath = $PrintRegistry -replace "^(HKEY_LOCAL_MACHINE)"
        $PrintRegistryPath = "HKLM:" + $PrintRegistryPath

        if (!(Test-Path -Path ($PrintRegistryValue + "Call Center"))) {
            Write-Log -Level "ERROR" -Path $LogPath  -Variable $env:COMPUTERNAME -Message "Call Center printer not found. Printer IP address change aborted."
            Write-Host "Call Center printer not found. Printer IP address change aborted" -ForegroundColor Red
            "`n"
            Continue
        }

        $Name = Get-ItemProperty -Path $PrintRegistryPath | Select-Object -ExpandProperty Name
        $CurrentPort = Get-ItemProperty -Path $PrintRegistryPath | Select-Object -ExpandProperty Port
        $NewIP = "10.1.4.22"
       
        Write-Host "Computer: " -NoNewline
        Write-Host $env:COMPUTERNAME -ForegroundColor Cyan
        Write-Host "Printer Name: " -NoNewline
        Write-Host $Name -ForegroundColor Cyan
        Write-Host "Current Port: " -NoNewline
        Write-Host $CurrentPort -ForegroundColor Cyan
        
        "`n"
        
        if (!(Get-Wmiobject Win32_tcpipprinterport | ? {$_.HostAddress -eq $NewIP})) {
        
            Write-Host "Creating printer port" $NewIP -ForegroundColor Yellow
            
            Create-Printer-Port -PrinterIP $NewIP -PrinterPort $NewIP -PrinterPortName $NewIP -Computer $env:COMPUTERNAME | Out-Null
            
                if (!(Get-Wmiobject Win32_tcpipprinterport | ? {$_.HostAddress -eq $NewIP})) {

                    Write-Log -Level "ERROR" -Path $LogPath  -Variable $env:COMPUTERNAME -Message "Unable to create new printer port. Printer IP address change aborted"
                    Write-Host "Error creating printer port!" -ForegroundColor Red
                    "`n"
                    Continue
                    
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

    }

        Invoke-Command -ComputerName $Computer -ScriptBlock $Scriptblock

        }

}
