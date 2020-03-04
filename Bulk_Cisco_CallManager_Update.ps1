Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
$list = "C:\users\admin.aowens\desktop\forSMTP.csv"
$voicemailList = Import-Csv -Path $list
$headers = $voicemailList[0].psobject.Properties.name

$updateSMTPRelay = @()
foreach ($user in $voicemailList)
{
    if (-not $user.RelayAddress)
    {
        try 
        {
            $toBeAdded = (Get-Mailbox -Identity $user.Alias -ea Stop | Select-Object -ExpandProperty PrimarySmtpAddress).Address
        }
        catch 
        {
            $relayAddress = $user.SmtpProxyAddresses.Split(',')
            for ($i = 0; $i -lt $relayAddress.Count; $i++)
            {
                if ($relayAddress[$i] -like '*are.com')
                {
                    $toBeAdded = $relayAddress[$i]
                    Break
                }
            }
        }
    }
    else 
    {
        $toBeAdded = $user.RelayAddress
    }

    $hash = [ordered]@{}

    for ($i = 0; $i -lt $headers.Count; $i++)
    {
        $key = $headers[$i]
        $value = $user[0].$key
        switch ($key)
        {
            "VoiceMailAction" {$value = 3}
            "RelayAddress" {$value = $toBeAdded}
            "SmtpProxyAddresses" {$value = ""}
        }
        $hash.Add($key, $value)
    }
    $object = New-Object -TypeName PSObject -Property $hash
    $updateSMTPRelay += $object
}
$updateSMTPRelay | Export-Csv "C:\users\admin.aowens\desktop\updateSMTPRelay_Test.csv" -NoTypeInformation