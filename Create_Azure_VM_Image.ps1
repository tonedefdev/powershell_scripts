$ResourceGroup = ""
$VM = ""
$Location = ""
$ImageName = ""

Import-Module AzureRm
Login-AzureRmAccount
$Image = Get-AzureRmVM -ResourceGroupName LL_SQL_Test -Name LLSQL2
$Image | Stop-AzureRmVM -Force
$Image | Set-AzureRmVm -Generalized
$ImageConfig = New-AzureRmImageConfig -Location "West US" -SourceVirtualMachineId $Image.Id
New-AzureRmImage -Image $ImageConfig -ImageName "LL_SQL_IMG" -ResourceGroupName LL_SQL_Test