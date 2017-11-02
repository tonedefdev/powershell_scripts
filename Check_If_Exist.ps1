Import-Module ActiveDirectory
. "C:\Users\$env:username\Desktop\Write_Log_Function.ps1"
$host.ui.rawui.WindowTitle = "Enabled User Check"
$ADVMList = "C:\Users\$env:username\Desktop\ADVM.csv"
$logfile = "C:\Users\$env:username\Desktop\NoAccount.log"
$createlog = New-Item $logfile -Type File
if ((Test-Path -Path $logfile -Type Leaf) -eq $false)
	{
		$createlog
	}
Import-CSV $ADVMList | Foreach {
$DisplayName = $_.DisplayName
$FindUser = Get-ADUser -Filter {Name -like $DisplayName} | Select-Object -ExpandProperty Enabled
if ($FindUser -eq $true) {
        Write-Host $DisplayName ":" "Account already exists" -BackgroundColor DarkBlue ;
        Get-ADUser -Filter {Name -like $DisplayName} | Select-Object -ExpandProperty Name | Out-File "C:\Users\$env:username\Desktop\Enabled.txt" -Append
                         }
elseif ($FindUser -ne $true) {
        Write-Host $DisplayName ":" "Account does not exist" -BackgroundColor Red ; 
        Write-Log ERROR -DisplayName $DisplayName -Message "The user does not exist in the directory"
}
}
Write-Host "Press any key to end script" -BackgroundColor DarkMagenta
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


