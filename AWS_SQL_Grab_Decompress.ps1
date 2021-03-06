﻿Import-Module awspowershell

Function DeGZip-File{
    Param(
        $infile,
        $outfile = ($infile -replace '\.gz$','')
        )

    $input = New-Object System.IO.FileStream $inFile, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
    $output = New-Object System.IO.FileStream $outFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
    $gzipStream = New-Object System.IO.Compression.GzipStream $input, ([IO.Compression.CompressionMode]::Decompress)

    $buffer = New-Object byte[](1024)
    while($true){
        $read = $gzipstream.Read($buffer, 0, 1024)
        if ($read -le 0){break}
        $output.Write($buffer, 0, $read)
        }

    $gzipStream.Close()
    $output.Close()
    $input.Close()
}

$AWSProfile = "PS_SQL_ConversionService"
$Bucket = "nvanet"
$Key = "NVA.sql.gz"
$LocalFile = "E:\Idexx_Cornerstone\$Key"

Set-AWSCredentials -ProfileName $AWSProfile

Copy-S3Object -BucketName $Bucket -Key $Key -LocalFile $LocalFile 

DeGzip-File -infile $LocalFile

Remove-Item -Path $LocalFile