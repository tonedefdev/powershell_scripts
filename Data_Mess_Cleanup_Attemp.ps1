$privateContacts = Import-Csv -Path "C:\users\aowens\OneDrive - ARE\desktop\Private Contacts.csv"

$ordered = @()
foreach ($contact in $privateContacts)
{
    foreach ($entry in $contact.Contacts)
    {
        $firstName = ""
        $lastName = ""
        $email = ""

        $entry = ([regex]::Split($entry, '\n')).Trim()

        $emailArray = @()
        for ($i = 0; $i -lt $entry.Count; $i+=1)
        {
            if (-not [string]::IsNullOrWhiteSpace($entry[$i]))
            {
                $companyName = $contact.'Company Name'.Trim()
                if ($entry[$i] -match '^[A-Z0-9a-z._]+@+[A-Z0-9a-z]+\.[A-Za-z]{3}')
                {
                    $email = $entry[$i]
                    $hash = [ordered]@{
                        CompanyName = $companyName
                        Email = $email
                    }

                    $object1 = New-Object -TypeName PSObject -Property $hash
                    $emailArray += $object1
                }
            }
        }

        $nameArray = @()
        for ($i = 0; $i -lt $entry.Count; $i+=2)
        {
            if (-not [string]::IsNullOrWhiteSpace($entry[$i]))
            {
                if ($entry[$i] -match '\s+\-+\s')
                {
                    $contactSplit = ([regex]::Split($entry[$i], '\s+\-+\s')).Trim()
                    $name = $contactSplit.Split(' ')
                    $firstName = $name[0]
                    $lastName = $name[1].Replace(',', '')
                    $title = $contactSplit[1]
                }

                $hash = [ordered]@{
                    FirstName = $firstName
                    LastName = $lastName
                    Title = $title
                }

                $object2 = New-Object -TypeName PSObject -Property $hash
                $nameArray += $object2
            }
        }

        for ($i = 0; $i -lt $nameArray.Count; $i++)
        {
            if ($nameArray.Count -eq 1)
            {
                $hash = [ordered]@{
                    CompanyName = $emailArray.CompanyName
                    FirstName = $nameArray.FirstName
                    LastName = $nameArray.LastName
                    Title = $nameArray.Title
                    Email = $emailArray.Email
                }
            }
            else 
            {
                $hash = [ordered]@{
                    CompanyName = $emailArray.CompanyName[$i]
                    FirstName = $nameArray.FirstName[$i]
                    LastName = $nameArray.LastName[$i]
                    Title = $nameArray.Title[$i]
                    Email = $emailArray.Email[$i]
                }
            }

            $object3 = New-Object -TypeName PSObject -Property $hash
            $ordered += $object3
        }

        <#
        $contact.'Company Name'.Trim()
        foreach ($item in $contactSplit)
        {

            if ($item -match "^[a-z ,.'-]+$")
            {
                $item = $item.Replace(',','')
                $name = $item.Split(' ')
                $firstName = $name[0]
                $lastName = $name[1]
                $firstName
                $lastName
                break
            }
        }
        #>

        <#

        $contactSplit = $contactSplit.Split('')
        $contactSplit = $contactSplit.Trim()
        $firstName = $contactSplit[0]
        $lastName = $contactSplit[1]

        for ($i = 0; $i -lt $contactSplit.Count; $i++)
        {
            
            if ($contactSplit[$i] -match '\s+[a-zA-Z]\.+\s')
            {
                $middleName = $contactSplit[$i]
            }

            if ($contactSplit[$i].Trim() -match '\(+[0-9]{3}\)\s[0-9]{3}\-[0-9]{4}')
            {
                $mobilePhone = $contactSplit[$i]
            }

            if ($contactSplit[$i] -match '^[A-Z0-9a-z._]+@+[A-Z0-9a-z]+\.[A-Za-z]{3}')
            {
                $email = $contactSplit[$i]
            }
        }

        $hash = [ordered]@{
            Salutation = ""
            FirstName = $firstName
            LastName = $lastName
            MiddleName = $middleName
            Suffix = ""
            AccoundId = $contact.'Company Name'
            Interest = ""
            Title = $contactSplit[2]
            Phone = ""
            MobilePhone = $mobilePhone
            Email = $email
            ARE_Region__c = ""
            AssistantName = ""
            ARE_AssistantEmail__c = ""
            AssistantPhone = ""
        }

        $object = New-Object -TypeName PSObject -Property $hash
        $ordered += $object
        #>
    }
}

$ordered | Export-Csv -Path "C:\Temp\SalesForce.csv" -NoTypeInformation
