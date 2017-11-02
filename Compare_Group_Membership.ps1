Import-Module ActiveDirectory
. "C:\Users\$env:username\Desktop\Write_Log_Function.ps1"
$host.ui.rawui.WindowTitle = "Group Membership Comparison"
$ADVMList = "C:\Users\$env:username\Desktop\ADVM.csv"
$logfile = "C:\Users\$env:username\Desktop\ADGroupMissing.log"
$createlog = New-Item $logfile -Type File
$group = "NVA Associate DVM"
if ((Test-Path -Path $logfile -Type Leaf) -eq $false)
	{
		$createlog
	}
Import-CSV $ADVMList | ForEach-Object {
$DisplayName = $_.DisplayName
$ADMember = Get-ADGroupMember -Identity $group | Where-Object {$_.name -eq"$DisplayName"} | Select-Object -ExpandProperty Name
if ($ADMember -like $DisplayName) {
        Write-Host $DisplayName ":" "is part of the group" -BackgroundColor DarkBlue ;
        $ADMember | Out-File "C:\Users\$env:username\Desktop\ADGroupEnabled.txt" -Append
                                }
elseif ($ADMember -ne $DisplayName) {
        Write-Host $DisplayName ":" "is not part of the group" -BackgroundColor Red ;
        Get-ADUser -Filter {Name -eq $DisplayName} -Properties Description | Select-Object Name,Description | Format-List | Out-File $logfile -Append
                                    }         
}
Write-Host "Press any key to end script" -BackgroundColor DarkMagenta
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")