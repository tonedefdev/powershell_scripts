function New-RandomPassword {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [int]$Length
    )
    
    begin {
        $CharacterArray =  @('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','!','@','#','%','&','*','1','2','3','4','5','6','7','8','9','0')
        $SymbolArray =  @('!','@','#','%','&','*')
        $NumberArray = @('1','2','3','4','5','6','7','8','9','0')
    }
    
    process {
        $GeneratedPassword = ""
        for ($i = 0; $i -lt ($Length - 2); $i++)
        {
            $Character = Get-Random -InputObject $CharacterArray
            $GeneratedPassword += $Character
        }
    }
    
    end {

        if ($GeneratedPassword -notcontains $SymbolArray)
        {
            $Character = Get-Random -InputObject $SymbolArray
            $GeneratedPassword += $Character
        }

        if ($GeneratedPassword -notcontains $NumberArray)
        {
            $Character = Get-Random -InputObject $NumberArray
            $GeneratedPassword += $Character
        }

        if ($GeneratedPassword.Length -lt $Length)
        {
            $Character = Get-Random -InputObject $CharacterArray
            $GeneratedPassword += $Character
        }

        return $GeneratedPassword
    }
}