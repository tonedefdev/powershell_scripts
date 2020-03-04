Function Add-HTMLTableAttribute
{
    Param
    (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $HTML,

        [Parameter(Mandatory=$true)]
        [string]
        $AttributeName,

        [Parameter(Mandatory=$true)]
        [string]
        $Value

    )

    $xml=[xml]$HTML
    $attr=$xml.CreateAttribute($AttributeName)
    $attr.Value=$Value
    $xml.table.Attributes.Append($attr) | Out-Null
    Return ($xml.OuterXML | out-string)
}


$Servers = @(

    "ps-sql-bi-1a",
    "ps-sql-bi-1b"
                  
)

$ScriptBlock = {

    Set-Location -Path "Cert:\LocalMachine\My"
    Get-Item * 

}

$CertReportArray = @()
$Threshold  = (Get-Date).AddDays(30)

foreach ($Server in $Servers) {

    $SSL = Invoke-Command -ComputerName $Server -ScriptBlock $ScriptBlock | Select-Object Server,Issuer,Subject,NotAfter,Thumbprint  
                                
        foreach ($Cert in $SSL) {
                                                               
            "`n"

            if (($Cert.NotAfter) -ge $Threshold) {

                Write-Host "Server: " $Server 
                Write-Host "Issuer: " $Cert.Issuer
                Write-Host "Thumbprint: " $Cert.ThumbPrint
                Write-Host "Subject: " $Cert.Subject
                Write-Host "Expiration: " -NoNewline
                Write-Host $Cert.NotAfter -ForegroundColor Green
                                                                        
                Continue

            } else {
                                                                    
                Write-Host "Server: " $Server
                Write-Host "Issuer: " $Cert.Issuer
                Write-Host "Thumbprint: " $Cert.ThumbPrint
                Write-Host "Subject: " $Cert.Subject
                Write-Host "Expiration: " -NoNewline
                Write-Host $Cert.NotAfter -ForegroundColor Red

                $Hash = @{
                    Server = $Server
                    Issuer = $Cert.Issuer
                    Thumbprint = $Cert.Thumbprint
                    Subject = $Cert.Subject
                    Expiration = $Cert.NotAfter
                }
                                        
                $CertReport = New-Object PSObject -Property $Hash 
                $CertReportArray += $CertReport

            }
      }
}

