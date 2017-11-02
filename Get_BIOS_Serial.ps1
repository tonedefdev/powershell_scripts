$filepath = "C:\Users\$env:username\Desktop"
$currentPath = Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path 
do 
    {
        Clear-Host
        "========================================"
        
        Write-Host "Type the word [EXIT] to quit at anytime " -BackgroundColor DarkGreen
        
        "========================================"
        "`n"
        $a = Read-Host "Please enter the computer name"
        if ($a -ne "Exit")
        {
            try 
                {
                "`n" + $a + "`n" + "=========================="; Get-WMIObject Win32_BIOS -computername $a -ErrorAction Stop
                }
            catch [System.Runtime.InteropServices.COMException]
                {
                Write-Host $a":" "No computer found or a connection to the specified computer could not be established" -Background Red;
                $exitCMD = Read-Host "To rerun script enter [Y], or choose [C] to cancel session"
                if ($exitCMD -eq "Y") {& $currentPath\Get_BIOS_Serial.ps1}
                elseif ($exitCMD -eq "C") {Exit}
                }
         [console]::ForegroundColor="white"
         [console]::BackgroundColor="blue"
         $export = Read-Host "If you wish to export enter [E] choose [Y] to rerun script or select [X] to exit"
         [console]::ResetColor()
         if ($export -eq "E") {Get-WMIObject Win32_BIOS -computername $a | Out-File $filepath\computerinfo.txt}
         elseif ($export -eq "Y") {& $currentPath\Get_BIOS_Serial.ps1}
         elseif ($export -eq "X") {Exit}
        }
    } 
while ($a -ne "Exit")