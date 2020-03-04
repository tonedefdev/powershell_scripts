$VMCount = 1
$ComputerNumber = 3
$RGName = "LL_SQL_Test"
$StorageAccountName = "llsqltestdisks886"
$ComputerNamePrefix = "LLSQL"
$ImageURL = "https://llsqltestdisks886.blob.core.windows.net/vhds/LLSQL220180621090257.vhd"
$Location = "West US"
$VNetName = "SQL_Cluster_Test"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $RGName
$StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $RGName -Name $StorageAccountName
$AvailSet = Get-AzureRmAvailabilitySet -Name "SQL_Availability_Set_Test" -ResourceGroupName LL_SQL_Test
$Credentials = Get-Credential

for ($i = 0; $i -lt $VMCount; $i++) {

    $ComputerName = $ComputerNamePrefix + $ComputerNumber
    $VMName = $ComputerNamePrefix + $ComputerNumber
    $OSDiskName = $ComputerName.ToLower() + "os"

    $NICname1 = $ComputerName + "Internal"
    $NICname2 = $ComputerName + "Heartbeat"

    $NIC1 = New-AzureRmNetworkInterface -Name $NICname1 -ResourceGroupName $RGName -Location $Location -SubnetId $VNet.Subnets[0].Id
    #$NIC2 = New-AzureRmNetworkInterface -Name $NICname2 -ResourceGroupName $RGName -Location $Location -SubnetId $VNet.Subnets[2].Id
     
    $VM = New-AzureRmVMConfig -VMName $VMName -VMSize "Standard_DS2_v2" -AvailabilitySetId $AvailSet.Id

    $VM = Set-AzureRmVMOperatingSystem -VM $VM -ComputerName $ComputerName -Credential $Credentials -ProvisionVMAgent -EnableAutoUpdate -Windows
    $VM = Set-AzureRmVMBootDiagnostics -VM $VM -Disable
    $VM = Add-AzureRmVMNetworkInterface -VM $VM -Id $NIC1.Id
    #$VM = Add-AzureRmVMNetworkInterface -VM $VMConfig -Id $NIC2.Id

    $VM = Set-AzureRmVMOSDisk -VM $VM -CreateOption FromImage -Windows -SourceImageUri $ImageURL -StorageAccountType Standard_LRS -Caching ReadWrite -DiskSizeInGB 127

    New-AzureRmVM -ResourceGroupName $RGName -Location $Location -VM $VM -LicenseType "Windows_Server" -Debug

    $ComputerNumber++
}