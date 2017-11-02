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