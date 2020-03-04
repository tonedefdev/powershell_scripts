<#

#NAME: VM_Deployment_v2.ps1
#AUTHOR: Michael Carreon
#DATE: 06/20/2017
#DESCRIPTION: This Powershell script is to deploy VMs based on .csv file

#>

## Add PowerCLI bits
Add-PSSnapin -Name "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue

## Get vSphere Server name and connect
$viservername = Read-Host -Prompt "Enter name of the vSphere Server: "

## Connect to vSphere server
try
{
    Connect-VIServer -Server $viservername -ErrorAction Stop
}

catch
{
    Write-Host "Unable to connect to '$viServerName' with the provided host name" -ForegroundColor Red
    Break
}

## Set Mail variables
$smtpServer = "es-16exch01.labspace.com"
$EmailTo = "SysAdmins <sysadmins@are.com>"
$EmailFrom = "VMware Automation <VMware-no-reply@are.com>"

## Explain script to user
Write-Host "This script will deploy VMs based on a .CSV file"
Write-Host "Please select the .CSV file you want to use"

## Syntax and sample for CSV File:
## vmname,vmcluster,datastore,cpu,memory,dvpg,ipaddress,subnet,gateway,pdns,sdns,template,customspecfile
## Pop-up window message for selecting CSV
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("Please select a CSV file to use for deployment",0,"",0x0)


## Prompt user for .CSV Location and import the list
Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}
  
$inputfile = Get-FileName "C:\"

$vmlist = Import-CSV $inputfile

Read-Host 'Please Review the .CSV Output and Press Enter to continue...' | Out-Null
 
foreach($item in $vmlist)
{

## Map variables
	$vmname = $item.vmname
	$vmcluster = $item.vmcluster
	$datastore = $item.datastore
	$cpu = $item.cpu
	$memory = $item.memory
	$dvpg = $item.dvpg
    $ipaddr = $item.ipaddress
    $subnet = $item.subnet
    $gateway = $item.gateway
    $pdns = $item.pdns
    $sdns = $item.sdns
    $template = $item.template
    $customspecfile = $item.customspecfile
     
    
    ## Find host with most available memory
    $BestHost = Get-Cluster $vmcluster | Get-VMHost | select name,MemoryUsageMB,@{Name="availmem"; Expression = {($_.MemoryTotalMB - $_.MemoryUsageMB)}} | Sort-Object 'availmem' -Descending | Select-Object -first 1 | % {$_.Name} 

    #Build Email Body
    $body = @"
    VM Name: $vmname
    Memory (in GB): $memory
    vCPU Count: $cpu
    Cluster: $vmcluster
    ESXi Host: $BestHost
    Datastore: $datastore
    OS Template: $template
    OS Customization: $customspecfile
    IP Address: $ipaddr
    Subnet Mask: $subnet
    Default Gateway: $gateway
    Primary DNS: $pdns
    Secondary DNS: $sdns
    Network: $dvpg
"@

    # Verify Datastore has at least 200GB available before proceeding
    if (Get-Datastore -Name $datastore | Select FreeSpaceMB | Where {$_.FreeSpaceMB -gt 204800})
    {
        try 
        {
            ## Deal with customization spec file
            Get-OSCustomizationSpec $customspecfile | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIp `
            -IpAddress $ipaddr -SubnetMask $subnet -DefaultGateway $gateway -Dns $pdns,$sdns -ErrorAction Stop
  
            ## Deploy the VM based on the template with the adjusted Customization Specification
            New-VM -Name $vmname -Template $template -Datastore $datastore -VMHost $BestHost -OSCustomizationSpec $customspecfile -ErrorAction Stop

            ## Set CPU and RAM
            Get-VM $vmname | Set-VM -MemoryGB $memory -NumCpu $cpu -Confirm:$false -ErrorAction Stop

            ## Set the Port Group Network Name (Match PortGroup names with the VLAN name)
            Get-VM -Name $vmname | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $dvpg -Confirm:$false -ErrorAction Stop
            Get-VM -Name $vmname | Get-NetworkAdapter | Set-NetworkAdapter -StartConnected:$true -Confirm:$false -ErrorAction Stop

            ## Power on VM  
            Start-VM $vmname -Confirm:$false -ErrorAction Stop

            ## Send email notification
            Send-Mailmessage -To $EmailTo -From $EmailFrom -Subject "VM Build is Complete - $vmname"  -SmtpServer $smtpServer -Body $body -ErrorAction Stop
        }

        catch
        {
            $errorCount = $Error.Count
            for ($i = 0; $i -lt $errorCount; $i++)
            {
                Write-Host $error[$i] -ForegroundColor Red
            }
        }

    } else {
        ## If datastore has less than 250GB available, don't build the VM and notify Administrators
        Send-Mailmessage -To $EmailTo -From $EmailFrom -Subject "VM Build Failed - $vmname - $cluster Requires Additional Datastore Space"  -SmtpServer $smtpServer -Body $body
    }
}