#
# TODO: 1. SSL Checks
#
#  Overview
#  =========================
#
#  This program is designed to pull down log information from the Office 365 API
#  at regular intervals.  It then processes the file to remove any duplicated log entries
#  that have already been processed.  If new entries are found, the script processes them
#  and forwards them along to Splunk for log ingestion.  
#  
#  The script is designed to be run via CRON entry at a specified interval.  The script
#  uses a cursor to keep track of processing and will continue to process files until
#  the cursor is brought current.  Hence, if the script is not run for a period of time,
#  it will try to collect all the missing log files between the last run and the current time
#  period.
# 
#
#  Installation Instructions
#  =========================
#
#     Module Installation:
#     --------------------
#     This script uses modules.  The modules required are listed below.
#     Simply run these powershell commands on the Hybrid-Worker to install
#     these modules
#
#        Install-Module Az -AllowClobber -Force
#        Install-Module AzureRmStorageTable -AllowClobber -Force
#        Install-Module AADRM -AllowClobber -Force
# 
#  Hybrid Worker Setup
#  =================== 
#  Script is intended to be run on hybrid-worker via Azure Automation.
#  As such, a few items must be setup for the script to run on the
#  hybrid-worker machine.
#
#
#     User-Account:
#     -------------
#     A local user account on the Hybrid-Worker machine must be created.
#     This user will be the account the script is run under and will contain the
#     Az profile information to connect to Azure Cloud.
#     
#     Setup Hybrid-Woker AzAccount cloud-profile.
#       1. Create Account (Domain or local) on Hybrid-Worker machine
#       2. Logon or assume new account credentials
#       3. Run Connect-AzAccount to generate profile with Subscription info
#
#     Azure Automation Config:
#     -----------------------
#     Azure automation needs to be made aware of local Hybrid-Worker Account.
#     You will need to create credentials in the Automation account for the new account
#     and you will need to assign the Hybrid-Worker group to run under those credentials.
#
#     *Note - Credentials will be the same that you generated locally or within AD.
#
#
#  Cloud Resources
#  ===============
#  This script relies on 2 cloud resources to perform its actions.  These
#  must be setup and information provided to script in order to properly run.
#
#     Azure Storage Account
#     ---------------------
#     An azure storage account must be provided to the script.  The
#     user will authenticate under the Connect-AzAccount profile information.  Hence, the Storage
#     Account must ensure that this user has full access to this storage account.
#     This script will attempt to generate two Azure Table Storage resources in this storage account
#     upon first run.  The storage account name must be provided in the User variable section under:
#
#        $storage_acct
#
#     Key Vault (Optional)
#     --------------------
#     The office 365 API requires a user that can access the AIP log informaiton.
#     This user must be provided to the script under the variable $aadrm_username.  You can choose to include
#     the password for this user in the script in the variable $aadrm_pass.
#
#     For enhanced security, it is recommended that you store the AIP credential informaiton in a Key Vault.
#     You must setup the key vault within Azure and allow the Automation Principle to access it.  In this case, 
#     the key vault name and key name are needed.  Those should be provided in the user variables:
#
#        $vault_name
#        $vault_key_name
#
#     The script will grab the credentials from the Key vault only if the variable $aadrm_pass is left blacnk.
#
#  Script Variables:
#  ================= 
#  The script requires additional cloud information to be provided.  Please ensure that 
#  the following information is provided:
#
#     REQUIRED VARIABLES
#     ==================
#     tenantid                  -> Azure Tenant ID
#     o365_tenantid             -> Office 365 TenantID.  May be same as TenantID.
#     automation_resource_group -> Resource Group that Azure Automation Account is setup under
#     automation_acct_name      -> Automation Account Name
#     automation_user           -> Automation Connection (User) to run the script
#     $storage_acct             -> Azure Storage Account where Dedupe/Cursor Tables stored
#     $aadrm_username           -> Username used to Connect to AADRM(AIP) API
#     $aadrm_pass               -> AADRM Password.  Leave blank to user Key Vault.
#     $splunk_auth_key          -> Authorization Key required by Splunk HTTP Event Collector
#     $splunk_httpurl           -> URL of Splunk Event Collector
#
#    OPTIONAL VARIABLES
#    ==================
#    $vault_name                -> Azure Vault Name with AADRM credentials
#    $vault_key_name            -> Azure Vault Key Name with password info
#
#
#    INTERVAL/TIMEOUT VARIABLES
#    ==========================
#    $check_interval            -> How often to process API logs (60 minutes default)
#    $sleep_interval            -> Second gap between interval checks if catch-up processing is needed
#    $purge_time                -> How long to hold onto DeDupe table before purging (2880 minutes default)

param (
    [parameter(Mandatory=$false)][int]$check_interval = 60,
    [parameter(Mandatory=$false)][bool]$ignore_ssl = $false,
    [parameter(Mandatory=$false)][int]$purge_time = 2880
         
)

#######################
# User Variables     ##
#######################
#Cloud Info --
$tenantid = "7733d4d4-91f3-4dea-b063-9263633dbd9b"

#Office 365 Tenant ID
$o365_tenantid = "7733d4d4-91f3-4dea-b063-9263633dbd9b"

#Automation Acct Info
$automation_resource_group = "AREAutomation"
$automation_acct_name = "AREAutomation"
$automation_user = "AzureRunAsConnection" 

#Automation Credential to Pull for 0365 access
$aadrm_credential_name = "Office365"

#Storage Acct for all processing/cursor info to be stored
$storage_acct = "arehybridworkers"

#AADRM Credentials
$aadrm_username = "automation@are.com"
#Leave aadrm_pass blank if you want to retrieve credentials from Key Vault
$aadrm_pass = ""

#Splunk Info
$splunk_auth_key = 'e9ff03c1-6751-42f0-861c-3673fdd5d02c'
$splunk_httpurl = "https://es-pspkdply1.labspace.com:8088"

###
### Timeout/Interval Values

#Sleep interval (seconds)
$sleep_interval = 5



##################################################################################                               
############### Do Not Edit Below This Line ######################################
###############                             ######################################

##################################################################################
# Modules
##################################################################################
#Import-Module AzureRM
Import-Module Az.Accounts
Import-Module Az.Storage
Import-Module Az.KeyVault
Import-Module AzureRmStorageTable
Import-Module AADRM
#Import-Module CosmosDB

##################################################################################
# Script Variables
##################################################################################
$scriptname ="AadrmUsageLogs"
$cursor_table_name = $scriptname + "CURSOR1"
$dedupe_table_name = $scriptname + "DEDUPE"

#File Download Path
$mypath = $env:TEMP

# Turn off this algorithm 
[System.Net.ServicePointManager]::UseNagleAlgorithm = $false 

#Force Log Process - Developer Debugging - Keep this at FALSE unless
#you know what you are doing
$force_file_process = $false

#Splunk Update Error Count
$splunk_update_error_cnt = 0

#Running in cloud flag
$running_in_cloud = 2

##################################################################################
# Script Validations
##################################################################################

$mymod_name = @("Az.Storage","Az.KeyVault","AzureRmStorageTable","AADRM")

foreach ($my_mod_name in $mymod_name) {

    if ((Get-InstalledModule -Name "$my_mod_name") -eq $null) {
     Write-Output "Missing Module $my_mod_name.  Please Install"
     exit
    }
}
if ($check_interval -lt 1) {
    Write-Output "\$check_interval should be greater than 0."
    exit
}
if ($sleep_interval -lt 1) {
    Write-Output "\$sleep_interval should be greater than 0."
    exit
}
if ($purge_time -lt 0) {
    Write-Output "\$purge_time should be 0 or greater."
    exit
}
if ($storage_acct -eq $null) {
    Write-Output "Storage Acct cannot be NULL"
    exit
}
if ($mypath -eq $null) {
    Write-Output "File Download Path cannot be NULL"
    exit
}
if ($splunk_auth_key -eq $null) {
    Write-Output "Splunk Auth Key cannot be NULL"
    exit
}
if ($splunk_httpurl -eq $null) {
    Write-Output "Splunk URL cannot be NULL"
    exit
}




##################################################################################
# Functions
##################################################################################
function Ignore-Ssl
{
    # Ignores ALL SSL errors in the current PS instance
    add-type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }                       
"@
    $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
    [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}

# Add sign in event to splunk
function Add-AADSigninEventToSplunk
{
    param(
        $signinevent,
        $url,
        $auth
    )

    #Parse our event
    $w3c_hash = w3c_parse($signinevent)

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Splunk $auth")

    $body = @{
                event = $w3c_hash
             } | ConvertTo-Json
              
                
    $restoutput = Invoke-RestMethod -TimeoutSec 10 -Uri "$url/services/collector/event" -Method Post -Headers $headers -Body $body
    if(!$?)    {
        #Unable to Upload to Splunk
        #Write-Output "failed splunk"
        return [int]"0"
    } else {
        #Success in uploading to Splunk
        #Write-Output "Splunk good"
        return [int]"1"
    }

}

function Purge-DeDupeTable
{
    param([Object]$ddt)
    
    #Write-Output "In Process-DeDupeTable()"

    #Get Our time to purge
    #Gather Current Time
    $nowtime = [DateTime]::UtcNow | get-date
    $mytspan = new-timespan -min $purge_time
    $purgedate = $nowtime - $mytspan
    Write-Verbose ("Purgedate: " + $purgedate)
    $unixEpochStart = new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)
    $unix_sec_search = [int64]((Get-date $purgedate)- $unixEpochStart).TotalSeconds
    Write-Verbose ("Unixtime: " + $unix_sec_search)
    [string]$filter1 = [Microsoft.Azure.Cosmos.Table.TableQuery]::GenerateFilterCondition("Splunk_Sent",[Microsoft.Azure.Cosmos.Table.QueryComparisons]::Equal,"yes")
    #[string]$filter2 = [Microsoft.Azure.Cosmos.Table.TableQuery]::GenerateFilterCondition("Timestamp",[Microsoft.Azure.Cosmos.Table.QueryComparisons]::LessThan,(Get-date $purgedate -Format "u"))
    [string]$filter2 = [Microsoft.Azure.Cosmos.Table.TableQuery]::GenerateFilterConditionForDate("Timestamp",[Microsoft.Azure.Cosmos.Table.QueryComparisons]::LessThanOrEqual,$purgedate)
    [string]$finalFilter = [Microsoft.Azure.Cosmos.Table.TableQuery]::CombineFilters($filter1,"and",$filter2)
 
    #Get our Rows Needing Splunk UploadingSee if hash already exists in our table
    $ddt_row = Get-AzTableRow -table $ddt -customFilter $finalFilter
    
    $iter = 0
    $deleted = 0    
    foreach ($row in $ddt_row) {
        $iter++
        #Write-Output "ROW RESULT: $row.event "
        $rowremove_result = $row | Remove-AzureStorageTableRow -table $ddt    
        if(!$?) {
            print "Cound not Delete Row - " ($row.Result).md5sum
            continue
        }   
        $deleted++
    }

    return ,@("$iter","$deleted")
}

function Process-DeDupeTable
{
    param([Object]$ddt)
    
    #Write-Output "In Process-DeDupeTable()"

    #Get our Rows Needing Splunk UploadingSee if hash already exists in our table
    $ddt_row = Get-AzTableRow -table $ddt -columnName "Splunk_Sent" -value "no" -operator Equal
    
    $iter = 0    
    $splunk_success_cnt = 0
    $splunk_error_cnt = 0

    foreach ($row in $ddt_row) {
        $iter++
        #Write-Output "ROW RESULT: $row.event "
        #$row
            
        #Send Log to Splunk
        #First Check to see if there are too many splunk errors.  If so, then skip splunk as it is having problems
        if ($splunk_update_error_cnt -ge 10) {
            Write-Error "Skipping Splunk Updates - Too Many Splunk Update Errors" 
            $splunk_error_cnt++
            return
        }

        $splunk_result = Add-AADSigninEventToSplunk -signinevent $row.event -url $splunk_httpurl -auth $splunk_auth_key
        #Write-Output "Splunk-Result: $splunk_result"

        if($splunk_result -eq 1) {
            $splunk_success_cnt++
            #Update our table
            $row.Splunk_Sent = "yes"
            $rowupdate_result = $row | Update-AzureStorageTableRow -table $ddt  
            if(!$?) {
                Write-Error "Couldn't not Update DeDupeTable - Splunk will likely have duplicate logs"
                exit
            }
        } else {
            $splunk_update_error_cnt++
            $splunk_error_cnt++
            Write-Error ("Could Not Upload to Splunk - " + $row.md5sum)
            continue

        }      
    }

    Write-Output "Events Processed: $iter Splunk_Updates: $splunk_success_cnt Splunk_Errors: $splunk_error_cnt"
}

function w3c_parse 
{
    param ($line)
    
    $rethash = @{}
         
    [regex]$rx = "^(?<date>\S+)\s+(?<time>\S+)\s+(?<rowid>\S*)\s+(?<requesttype>\S*)\s+\'(?<userid>[^\']*)\'\s+\'(?<result>[^\']*)\'\s+(?<correlationid>\S*)\s+(?<contentid>\S*)\s+\'(?<owneremail>[^\']*)\'\s+\'(?<issuer>[^\']*)\'\s+(?<templateid>\S*)\s+\'(?<filename>[^\']*)\'\s+\'(?<datepublished>[^\']*)\'\s+\'(?<cinfo>[^\']*)\'\s+(?<cip>\S*)\s+\'(?<adminaction>[^\']*)\'\s+\'(?<actingasuser>[^\']*)\'"
    $m = $rx.Match($line)
   
    foreach ($g in $m.groups) {
        $name = $g.Name
        $val = $g.Value

        if ($g.Name -eq "0" ) {
            $name = "raw"
        }    
        #Write-Output $name ": " $val
        $rethash.add($name,$val)

    } 

    return $rethash

}

function Process-File 
{
    param(  [String]$file,
            [Object]$ddt)

    $myline_count = 0
    $dup_count = 0
    $dedupe_adds = 0
    $splunk_adds = 0
        
    #Return if there is no file to process
    if ((Test-Path -Path "$file" -PathType leaf) -eq $false) {
        Write-Verbose "File-Does not Exist - $file"
        return ,@($myline_count, $dedupe_adds, $splunk_adds, $dup_count)
    }

    $splunk_update_error_flag = 0
    foreach ($line in Get-Content "$file") {

        if ($line -match "^#" -or $line -eq "") {
            #This is a comment or blank line
            #Write-Output "SKIPPING LINE: " $line
            continue
        }
        $myline_count++
        #Write-Output "LINE: " + $line

     
        #Hash our line
        $md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
        $utf8 = new-object -TypeName System.Text.UTF8Encoding
        $md5hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($line)))

        #Write-Output "MD5Hash: $md5hash"

        #See if hash already exists in our table
        $ddt_row = Get-AzTableRow -table $ddt -columnName "md5sum" -value $md5hash -operator Equal
        
        if ($ddt_row -ne $null) {
            $dup_count++
            Write-Verbose "Duplicate Entry - $md5hash"
            continue
         }

         ################
         #  New Entry   #
         ################
         Write-Verbose "Adding Row to Storage Table - $md5hash"
         $guid = [guid]::NewGuid()

         #$myaddrow = Add-AzTableRow -table $ddt -partitionKey "MAIN" -rowKey ($guid.tostring()) -property @{ "md5sum"="$md5hash"; "InsertTime"="$nowtime"; "event"="$line" ; "Splunk_Sent"="no" }
         $myaddrow = Add-AzTableRow -table $ddt -partitionKey "MAIN" -rowKey ($guid.tostring()) -property @{ "md5sum"="$md5hash"; "InsertTime"="$nowtime"; "event"="$line" ; "Splunk_Sent"="no" }

         if(!$?) {
             Write-Error "Couldn't write to Azure storage - Table - $ddt"
             continue
         } else {
             $dedupe_adds++
         }
      
         #####################
         #Send Log to Splunk##
         #####################

         #First Check to see if there are too many splunk errors.  If so, then skip splunk as it is having problems
         Write-Debug "Splunk_Update_Error_Cnt: $splunk_update_error_cnt"

         if ($splunk_update_error_cnt -ge 10) {
            if ($splunk_update_error_flag -eq 0) {
                Write-Error "Skipping Splunk Update - Too Many Splunk Update Errors"
                $splunk_update_error_flag = 1
             } 
             continue
         }

         $splunk_result = Add-AADSigninEventToSplunk -signinevent "$line" -url $splunk_httpurl -auth $splunk_auth_key
         if($splunk_result -ne 1) {
             Write-Error "Could Not Upload to Splunk"
             $splunk_update_error_cnt++
             continue
         } else {
             #############################
             ### SPLUNK UPDATE SUCCESSFUL
             #############################
             #Count it
             $splunk_adds++
            
             #Get our Row
             $justadded_row = Get-AzTableRow -table $ddt -columnName RowKey -Value ($guid.toString()) -operator Equal

             #Remove our line if user wants instant delete
             if ( $purge_time -eq 0 ) {
                 #User wants to immediately purge DeDupe Table entries
                 $delete_result = $justadded_row | Remove-AzureStorageTableRow -table $ddt    
                 if(!$?) {
                     Write-Error "Cound not Delete Row - " $justadded_row.md5sum
                     continue
                 } else {
                     Write-Verbose "Immediate DeDupe Delete for ($justadded_row).md5sum"
                 }
             } else {
                 #Just update for Splunk Sent
                 $justadded_row.Splunk_Sent = "yes"
                 $rowupdate_result = $justadded_row | Update-AzureStorageTableRow -table $ddt  
                 if(!$?) {
                     Write-Error  "Couldn't not Update DeDupeTable - Splunk will likely have duplicate logs"
                 }
                         
             }
                
        }             
                       

    } #Foreach Line

    return @("$myline_count", "$dedupe_adds", "$splunk_adds", "$dup_count")
}

function Cloud-Connect
{

    if (Get-Command "Get-AutomationConnection" -errorAction SilentlyContinue) {

        #This is being run from the cloud
        Write-Output "Running in Cloud"
        Set-Variable -Name running_in_cloud -Value 1 -Scope Global
        
        $connection = Get-AutomationConnection -name $automation_user
        $myout = Connect-AzAccount `
    	-ApplicationId $connection.ApplicationId `
    	-Tenant $connection.TenantId `
    	-Subscription $connection.SubscriptionId `
        -CertificateThumbprint $connection.CertificateThumbprint
        

    } else {
        #This is being run locally
        Write-Output "Running Locally"
        Set-Variable -Name running_in_cloud -Value 0 -Scope Global
                
        #See if we are AZ Acct connected
        try {
            #let see if we are cloud connectioned
            $subscription = Get-AzSubscription
        } 
        catch {
            Write-Output "Not Cloud Connected.  Ask the User"
            Connect-AzAccount 
        }

        $connection = Get-AzAutomationConnection -ResourceGroup $automation_resource_group -AutomationAccountName $automation_acct_name -Name $automation_user

    }

    if($connection -eq $null) {
        throw "Couldn't Get Cloud Subscription"
        exit
    } else {
            Write-Output "Azure Cloud Connected"
    }
}

function AADRM-Connect
{

    #$aadrm_cred = Get-AutomationPSCredential -Name $aadrm_credential_name
    
    #$aadrm_pass = $aadrm_cred.Password | ConvertFrom-SecureString
    #$aadrm_pass = $aadrm_cred.GetNetworkCredential().Password 
    #$aadrm_username = $aadrm_cred.Username

    #if ($aadrm_pass -eq "" -or $aadrm_pass -eq $null) {
    #    #Get the key from the key vault if NULL
    #    Write-Verbose "  - Getting Keys from vault"
    #    $aadrm_pass = (Get-AzKeyVaultSecret -VaultName $vault_name -Name "aadrm-pass").SecretValueText
    #}

    #Disconnect if holding to previous session for any reason
    Disconnect-AadrmService | Out-Null
    
    #Connect to Aadrm
    #$my_secpasswd =  ConvertTo-SecureString -String "$aadrm_pass" -AsPlainText -Force
    #$aadrm_cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $aadrm_username,$my_secpasswd

    
    if ($running_in_cloud -eq 1) {
        #Get Credential from automation
        $aadrm_cred = Get-AutomationPSCredential -Name $aadrm_credential_name
    } else {
        #Get Credential from local or key vault
        if ($aadrm_pass -eq "" -or $aadrm_pass -eq $null) {
            #Get the key from the key vault if NULL
            Write-Verbose "  - Getting Keys from vault"
            $aadrm_pass = (Get-AzKeyVaultSecret -VaultName $vault_name -Name "aadrm-pass").SecretValueText
        }
        #Generate Credential from Vault Info
        $my_secpasswd =  ConvertTo-SecureString -String "$aadrm_pass" -AsPlainText -Force
        $aadrm_cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $aadrm_username,$my_secpasswd
    }

    $output = Connect-AadrmService -TenantId $o365_tenantid -Credential $aadrm_cred
    if ($output -ne "A connection to the Microsoft Azure AD Rights Management (AADRM) service was opened.") {
       Write-Output "Could Not Connect to AADRM service -- $output"
       Write-Output "Exiting Script"
       exit
    } else {
       Write-Output "Connected to AADRM"
    }


}

Function Get-Cursor 
{
    param($sa_name)
    #Get the Storage Account Curser
    $ctx = (Get-AzStorageAccount).where{$_.storageaccountname -eq "$sa_name"}.context
    if ($ctx -eq $null) {
       throw "Couldn't Get Azure Storage Context - $sa_acct"
       exit
    }

    $c_table = (Get-AzStorageTable -Context $ctx -Name "$cursor_table_name" -ErrorVariable $cmd_output_error ).CloudTable
    if ($c_table -eq $null) {
       #Table May not exist.  Try to create once
       Write-Verbose "Could not find cursor table - Attempting to create"
       $c_table = (New-AzStorageTable –Name "$cursor_table_name" –Context $ctx -ErrorVariable $cmd_output_error).CloudTable
       if ($c_table -eq $null) {
        throw "Couldn't Create Cursor Table - $cursor_table_name"
        throw "Exiting"
        exit
       } else {
        #We Just created our Cursor Table
        Write-Verbose "Created Cursor Table on-the-fly"
        sleep(10)
       }
    }

    $c_row = Get-AzTableRow -table $c_table 
    #Add cursor if it comes back as null
    if ($c_row -eq $null) {
        
        #Set Initial Cursor Time 2 hours back
        #$ntime = [DateTime]::UtcNow | get-date -Format "MM/dd/yyyy HH:mm:ss"
        $ntime = [DateTime]::UtcNow | get-date
        $tspan = new-timespan -min 120
        $initial_time = $ntime - $tspan
        $my_i_time = Get-Date -date $initial_time -Format "MM/dd/yyyy HH:mm:ss"
        Write-Verbose "Initializing Cursor value - $my_i_time"
        Add-AzTableRow -table $c_table -PartitionKey main -rowKey ([guid]::NewGuid().tostring()) -property @{"CursorDate"="$my_i_time"} | Out-Null
        Sleep(10)
        $c_row = Get-AzTableRow -table $c_table
    }
    if ($c_row -eq $null -or $c_row -eq "") {
        #Exit out, can't get cursor
        Write-Error "Can't get Cursor for log processing"
        exit
    }

    return $c_row,$c_table

}

Function Get-DedupeTable 
{
    param($sa_name)

    #Get the Storage Account Curser
    $ctx = (Get-AzStorageAccount).where{$_.storageaccountname -eq "$sa_name"}.context
    
    $mydedup_table = (Get-AzStorageTable -Context $ctx -Name "$dedupe_table_name").CloudTable
    if($mydedup_table -eq $null) {
       #Table May not exist.  Try to create once
       Write-Verbose "Creating DeDupe Table on-the-fly"
       $mydedup_table = (New-AzStorageTable –Name $dedupe_table_name –Context $ctx).CloudTable
       if ($mydedup_table -eq $null) {
        throw "Couldn't Create DeDupe Table - $dedupe_table_name"
        exit
       }
    }

    return $mydedup_table

}

#################################################################
### MAIN
##################################################################

if ($ignore_ssl -ne $false) {
    Write-Verbose "Running Ignore-Ssl()"
    Ignore-Ssl
}

Write-Output "Program Setup"
Write-Output "#############"

Cloud-Connect
AADRM-Connect

#Get Vault Credentials
#if ($aadrm_pass -eq "" -or $aadrm_pass -eq $null) {
#    #Get the key from the key vault if NULL
#    Write-Output "  - Getting Keys from vault"
#    $aadrm_pass = (Get-AzKeyVaultSecret -VaultName $vault_name -Name "aadrm-pass").SecretValueText
#}
#AADRM-Connect "$aadrm_username" "$aadrm_pass"



Write-Output "  - Gathering Azure Cloud Tables"
#$cursor_row,$cursor_table = Get-Cursor $storage_acct
$ret_array01 = Get-Cursor $storage_acct
$cursor_row = $ret_array01[0]
$cursor_table = $ret_array01[1]

$dedup_table = Get-DedupeTable ($storage_acct)


#Gather Current Time
$nowtime = [DateTime]::UtcNow | get-date -Format "MM/dd/yyyy HH:mm:ss"

#Get Cursor Previous Date
$myprevdate = Get-Date -date ($cursor_row).CursorDate
#"PrevDate Cursor - " + $myprevdate

#Setup Time Interval
$mytspan = new-timespan -min $check_interval
$newtime = $myprevdate + $mytspan

#Write-Output "Current Timestamp: $nowtime --- Cursor-Timestamp: $myprevdate --- Check-Interval: $check_interval"
 
#Process Intervals
$iterations = 0

Write-Output ""
Write-Output "ITERATING OVER LOG FILES"
Write-Output "########################"


while ($newtime -lt $nowtime) {
    $iterations++
         
    #Grab AAdrm logsf
    #Write-Output "Get-AadrmUserLog  -Path $mypath -Verbose -FromDate $myprevdate -ToDate $newtime -Force"
    #Get-AadrmUserLog  -Path $mypath -Verbose -FromDate $myprevdate -ToDate $newtime -Force
    Write-Output "Pulling AADRM Log - $myprevdate <--> $newtime"
    $cmdoutput = $(Get-AadrmUserLog  -Path $mypath -FromDate $myprevdate -ToDate $newtime -Force -Verbose) 4>&1
    if(!$?) {
       #Problem Downloading File
       Write-Output "There was a problem downloading Log"
       exit
    }
    
    #Write-Output "FILE DOWNLOAD OUTPUT: $cmdoutput"
    #Write-Output "CMDOUTPUT: $cmdoutput" 
    if ($cmdoutput -notmatch "there was no activity on that date\." -or $force_file_process -eq $true ) {

        if ( $force_file_process -eq $true) {
            Write-Output "Forcing File Processing"
        }
        #Process download
        $dl_filepath = "$mypath" + "\rmslog-" +  (Get-Date -date $newtime -format "yyyy-MM-dd") + ".log"
    
        #Process-File Download
        $retarray = Process-File $dl_filepath $dedup_table
    
        if ($retarray -ne $null) {
            Write-Output  ("Lines Processesed: " + $retarray[0] + " ---  Duplicates: " + $retarray[3] + " --- TableUpdates: " + $retarray[1] + " --- SplunkUpdates: " + $retarray[2])
        }
        Write-Output ""
        
    } else {

        #Download had no data
        Write-Output "No logs for the time period.  Moving to next iteration"
        Write-Output ""
               
    }

    ##################################
    ### CLEANUP for next Iteration ###
    ##################################
    ##Update Cursor with new date
    $cursor_row.CursorDate = "$newtime"
    $cursor_row | Update-AzureStorageTableRow -table $cursor_table | Out-Null

    #Add Timespan and check again
    $myprevdate = $newtime
    $newtime = $newtime + $mytspan

    #Update the cursor row
    $cursor_row = Get-AzTableRow -table $cursor_table
    
    #Wait 30  seconds before next round of processing
    sleep($sleep_interval)


}

if ($iterations > 0) {
    Write-Output "---------------------"
    Write-Output "Total Iterations: $iterations"
    Write-Output ""
} else {
    Write-Output "Cursor is current."
    Write-Output ""
}
# Splunk Events should fire into HTTP collector in realtime.  
# This is a belt & suspenders here to ensure 
# that any single events missed are re-processed
Write-Output "Processing Any Missed Splunk Updates"
Write-Output "####################################"
Process-DeDupeTable $dedup_table
Write-Output ""

##Now Process and Delete any DeDupeRows that have been uploaded
##That are older than 7 days
Write-Output "Purge Old Table Data"
Write-Output "####################"
$purge_array = Purge-DeDupeTable $dedup_table
Write-Output ("Lines Processed: " + $purge_array[0] + " Purge Cnt: " + $purge_array[1] )
