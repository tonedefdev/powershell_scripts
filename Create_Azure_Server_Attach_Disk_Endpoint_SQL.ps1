$adminUser	= "[admin user name]"
$password	= "[admin password]"
$serviceName	= "[VM Service Name]"
$location	= "[Regional Location]"
$size		= "[VM Size]"
$vmName	        = "[VM Name]"

$imageFamily = "Windows Server 2012 R2 Datacenter"
$imageName   = Get-AzureVMImage |
                   where { $_.ImageFamily -eq $imageFamily } | 
                             sort PublishedDate -Descending  |
                    Select-Object -ExpandProperty ImageName -First 1

New-AzureVMConfig -Name $vmName `
                  -InstanceSize $size `
                  -ImageName $imageName |

Add-AzureProvisioningConfig -Windows `
                            -AdminUsername $adminUser `
                            -Password $password |

Add-AzureDataDisk -CreateNew `
                  -DiskSizeInGB 10 `
                  -LUN 0 `
                  -DiskLabel "data" |

Add-AzureEndpoint -Name "SQL" `
                  -Protocol tcp `
                  -LocalPort 1433 `
                  -PublicPort 1433 |

New-AzureVM -ServiceName $serviceName `
            -Location $location
