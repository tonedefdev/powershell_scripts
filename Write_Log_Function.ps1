Function Write-Log {
    [CmdletBinding()]
    Param(
    [Parameter(
	    Mandatory=$False)]
    [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
    [String]
    $Level = "INFO",

    [Parameter(
        Mandatory=$True)]
    [string]$Message,
    
    [Parameter(
        Mandatory=$True,
        ValueFromPipeline=$True,
	    ValueFromPipelineByPropertyName=$True)]
    [string]$Variable,

    [Parameter(
	Mandatory=$True,
	ValueFromPipeline=$True,
	ValueFromPipelineByPropertyName=$True)]
    [string]$Path
    )

    $Stamp = (Get-Date).toString("MM/dd/yyyy HH:mm:ss")
    $Line = "$Stamp $Level - $Variable : $Message"
    If($Path) {
        Add-Content $Path -Value $Line
    }
    Else {
        Write-Output $Line
    }
}