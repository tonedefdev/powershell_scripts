﻿$cer = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$cer.Import(“C:\users\aowens\desktop\es-ise01.cer”)
$bin = $cer.GetRawCertData()
$base64Value = [System.Convert]::ToBase64String($bin)
 
$bin = $cer.GetCertHash()
$base64Thumbprint = [System.Convert]::ToBase64String($bin)
 
$keyid = [System.Guid]::NewGuid().ToString()