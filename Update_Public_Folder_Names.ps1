Add-PSSnapin Microsoft.Exchange.v2010
Import-Module ActiveDirectory

$publicFolders = Import-Csv -Path "C:\users\admin.aowens\desktop\NewPublicFolderNames.csv"

foreach ($folder in $publicFolders)
{
    Set-PublicFolder -Identity $folder.Identity -Name $folder.NewName -Verbose -WhatIf
}