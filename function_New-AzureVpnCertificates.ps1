enum hashAlgorithim {
    MACTripleDES
    MD5
    RIPEMD160
    SHA1
    SHA256
    SHA384
    SHA512
}

function New-AzureVpnCertificates {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]$Subject,
        [ValidateNotNullOrEmpty()]
        [hashAlgorithim]$HashAlgorithim,
        [ValidateNotNullOrEmpty()]
        [int]$KeyLength,
        [ValidateNotNullOrEmpty()]
        [string]$ExportPath
    )
    
    begin {
        $certStoreLocation = "Cert:\CurrentUser\My"
        $publicParams = @{
            Type = "Custom"
            KeySpec = "Signature"
            Subject = $subject
            KeyExportPolicy = "Exportable"
            HashAlgorithm = $hashAlgorithim
            KeyLength = $keyLength
            CertStoreLocation = $certStoreLocation
            KeyUsageProperty = "Sign"
            KeyUsage = "CertSign"
        }

        if ($VerbosePreference -ne "SilentlyContinue")
        {
            $publicParams += @{Verbose = $true}
        }
    }
    
    process {
        $certPublic = New-SelfSignedCertificate @publicParams

        $clientParams = @{
            Signer = $certPublic
            Type = "Custom"
            KeySpec = "Signature"
            Subject = $subject
            KeyExportPolicy = "Exportable"
            HashAlgorithm = $hashAlgorithim
            KeyLength = $keyLength
            CertStoreLocation = $certStoreLocation
            TextExtension = @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")
        }

        if ($VerbosePreference -ne "SilentlyContinue")
        {
            $clientParams += @{Verbose = $true}
        }
        
        $certClient = New-SelfSignedCertificate @clientParams
    }
    
    end {
        $certPublic
        $certClient
    }
}