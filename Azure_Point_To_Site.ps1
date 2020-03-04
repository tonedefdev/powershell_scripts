#####################################################################################
############################### Point to site connection ############################
######################### tested with AzureRM module 6.3.0  #########################
#####################################################################################
#Import-Module AzureRm
#Login-AzureRmAccount
Import-Module PKIClient
Clear
$certificatename="LaunchLabsCert"
$Path="C:\cert"
$CertPath="$Path\$certificatename.cer"
$vnet=Get-AzureRmVirtualNetwork -Name SQL_Cluster_Test  -ResourceGroupName LL_SQL_Test
Add-AzureRmVirtualNetworkSubnetConfig -Name GatewaySubnet -VirtualNetwork $vnet -AddressPrefix 10.2.1.0/24
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
$gwsubnet = Get-AzureRMVirtualNetworkSubnetConfig –Name “GatewaySubnet” –virtualnetwork $vnet
$pip = New-AzureRMPublicIPAddress –Name SQL_VPN_IP –ResourceGroupName LL_SQL_Test -AllocationMethod Dynamic -Location "West US"
$ipconfig= New-AzureRmVirtualNetworkGatewayIPConfig –Name GWIPConfig –Subnet $gwsubnet –PublicIPAddress $pip
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
#-----------------------------------------------------------[create self signing root cert on the client side]
$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature -Subject "CN=$certificatename" -KeyExportPolicy Exportable -HashAlgorithm sha256 -KeyLength 2048 -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign
#-----------------------------------------------------------[Export self signing root cert as file]
$RootCertThumbprint=(Get-ChildItem -path "cert:\currentuser\my"|where {$_.subject -like "*$certificatename*"}).Thumbprint
$CertContent=[convert]::tobase64string((get-item cert:\currentuser\my\$RootCertThumbprint).RawData)
Set-Content -Path $CertPath -Value $CertContent -Encoding ascii
#-----------------------------------------------------------[following commands will convert the certificate to the proper format for azure]
$adatumRootCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($CertPath)
$adatumRootCertBase64 = [System.Convert]::ToBase64String($adatumRootCert.RawData)
$adatumVPNRootCert = New-AzureRmVpnClientRootCertificate -Name ‘LaunchLabsCert’ -PublicCertData $adatumRootCertBase64
#-----------------------------------------------------------[generate the client certificate]
New-SelfSignedCertificate -Type Custom -KeySpec Signature -Subject "CN=LaunchLabsCert" -KeyExportPolicy Exportable -HashAlgorithm sha256 -KeyLength 2048 -CertStoreLocation "Cert:\CurrentUser\My" -Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")
#-----------------------------------------------------------[configure the gateway]
New-AzureRmVirtualNetworkGateway -Name SQL_VPN_GW -ResourceGroupName LL_SQL_Test -Location "West US" -IpConfigurations $ipconfig -GatewayType Vpn -VpnType RouteBased -EnableBgp $false -GatewaySku VpnGw1 -VpnClientAddressPool "172.16.0.0/24" -VpnClientRootCertificates $adatumVPNRootCert -VpnClientProtocol SSTP
#-----------------------------------------------------------[download VPN Client]
$VPNClientURL=Get-AzureRmVpnClientPackage -ResourceGroupName LL_SQL_Test -VirtualNetworkGatewayName SQL_VPN_GW -ProcessorArchitecture Amd64
$outpath = "$Path/VPNClient.exe"
Invoke-WebRequest $VPNClientURL.Replace('"','') -OutFile $outpath 
#-----------------------------------------------------------[install VPN Client]
Start-Process -Filepath "$outpath"
#-----------------------------------------------------------[connect to VPN manually] 
